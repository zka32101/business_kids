# 実装設計書：② AIコーチ因果解説（売れた理由・売れなかった理由の言語化）

> **バージョン**: v1.0.1  
> **優先度**: 🥈 高（学習体験の深化）  
> **実装予定期間**: 2〜3日  
> **担当**: Haiku（プロンプト改善・UI）  
> **AI 方針**: claude_api_service.dart のプロンプト改善のみ。新規 API 呼び出し追加なし。

---

## 概要

既実装の AI コーチ（Claude Haiku）のプロンプトを拡張し、毎日の日報から「売れた理由」「売れなかった理由」を分析・言語化。単なる激励ではなく、**因果関係を説明する**コメントを生成し、翌日の意思決定へ誘導する。

**現在の状態**:
- `claude_api_service.dart` で 1 日 1 回の励ましコメント生成 ✅
- プロンプトはシンプル＆汎用的 ← **ここを改善**

**改善後の状態**:
```
【現在】
「きょうもよくがんばったね！」

【改善後】
「きょう、レモネード2個しか売れなかったのは
 雨の日☔に150円だったからかも。
 雨の日はあたたかいコーヒーが人気だよ。
 あしたはコーヒーの値段を110円にしてみたら？」
```

---

## 実装サイズ

| 範囲 | 規模 |
|------|------|
| プロンプト改善 | claude_api_service.dart の generateCoachComment 関数 |
| UI 変更 | home_screen.dart または game_tab.dart に「作戦メモ」表示 |
| Firestore | gameSessions に coachCommentReasoning フィールド追加（オプション） |

---

## 実装ステップ

### Step 1: claude_api_service.dart のプロンプト再設計 ✅ Haiku

#### 1-1. 現在のメソッド構造を確認

```dart
class ClaudeApiService {
  // ...
  
  Future<String> generateCoachComment(
    GameSessionModel session,
    ChildModel child,
    int consecutiveDaysUsed,
  ) async {
    // 既実装：シンプルな励ましコメント生成
  }
}
```

#### 1-2. メソッドを拡張

**現在のプロンプト（想定）**
```
"きょうもよくがんばったね！"
"${child.name}のお店は今日も大繁盛だね"
```

**改善後のプロンプト** （context を拡張）

```dart
Future<String> generateCoachCommentWithCausality(
  GameSessionModel session,
  ChildModel child,
  ConceptMasteryModel? conceptMastery,
  List<SaleRecord>? previousSessionData,  // 前日比較用
) async {
  final prompt = '''
あなたは小学生向けのコンビニ経営ゲームのAIコーチです。
プレイヤー「${child.name}」が今日の店舗経営の結果を見ています。

【きょう1日の経営結果】
- 売上: ¥${session.totalRevenue}
- 利益: ¥${session.totalProfit}
- 利益率: ${(session.averageProfitMargin * 100).toStringAsFixed(1)}%
- 販売件数: ${session.totalSalesCount}件
- ベスト商品: ${_topSellingProduct(session)}

【販売詳細】
${_formatSalesBreakdown(session.sales)}

【プレイヤーの得意概念（習熟度）】
${_formatConceptMastery(conceptMastery)}

【前日との比較】（もしあれば）
${_formatPreviousComparison(previousSessionData, session)}

【タスク】
プレイヤーの視点で、今日の結果を「なぜそうなったのか」の視点から
分析・説明するコメントを生成してください。

ルール:
1. 単なる励まし（「がんばったね」だけ）は禁止
2. 因果関係を説明する（「〜だから、〜が売れた」「〜だったので、〜が見送った」）
3. 明日への提案を含める（「明日は〜を試してみたら？」）
4. 小学生向けの易しい言葉を使う
5. 絵文字を適度に使う（文字数の10%まで）
6. 1段落 50-80 字程度（合計 200-300 字以内）
7. 実際のデータに基づいた推測のみ（確実でないことは「かもしれない」で留める）

【出力例】
「きょう、レモネードが1個も売れなかったのは、
150円に値上げしたからかも。仕入れ値が50円だから
2倍以上の値段になっちゃったね。
レモネードが得意なっぽいプレイヤーさんには
110円くらいがちょうどいいかもです。
明日試してみたらどうでしょう？」

【実際の条件】
- プレイヤーレベル: ${child.currentLevel}
- 連続プレイ日数: $consecutiveDaysUsed日
- ゲーム難度: ${_levelName(child.currentLevel)}

コメントを生成してください。
  ''';

  final response = await _client.messages.create(
    model: AppConstants.claudeModel,
    maxTokens: AppConstants.claudeMaxTokens,
    messages: [
      Message(
        role: MessageRole.user,
        content: prompt,
      ),
    ],
  );

  return _extractText(response);
}
```

#### 1-3. ヘルパー関数を追加

```dart
String _formatSalesBreakdown(List<SaleRecord> sales) {
  final byProduct = <String, (int count, int quantity)>{};
  
  for (final s in sales) {
    if (byProduct.containsKey(s.productName)) {
      final (cnt, qty) = byProduct[s.productName]!;
      byProduct[s.productName] = (
        s.customerBought ? cnt + 1 : cnt,
        qty + (s.customerBought ? s.quantity : 0),
      );
    } else {
      byProduct[s.productName] = (
        s.customerBought ? 1 : 0,
        s.customerBought ? s.quantity : 0,
      );
    }
  }
  
  return byProduct.entries
      .map((e) => '- ${e.key}: ${e.value.$2}個売れた（${e.value.$1}人が購入）')
      .join('\n');
}

String _formatConceptMastery(ConceptMasteryModel? mastery) {
  if (mastery == null) return '(データなし)';
  
  final sorted = mastery.scores.entries
      .where((e) => e.value > 50)
      .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  
  if (sorted.isEmpty) return '(まだ得意な概念はありません)';
  
  return sorted
      .take(3)  // Top 3
      .map((e) => '- ${ConceptMasteryModel.conceptNames[e.key]}: ${e.value}点')
      .join('\n');
}

String _formatPreviousComparison(
  List<SaleRecord>? prev,
  GameSessionModel current,
) {
  if (prev == null) return '(初日のためなし)';
  
  final prevRevenue = prev
      .where((s) => s.customerBought)
      .map((s) => s.profit)
      .fold(0, (a, b) => a + b);
  
  final diff = current.totalRevenue - prevRevenue;
  final diffStr = diff > 0 ? '📈 +¥$diff' : '📉 ¥$diff';
  
  return '前日: ¥$prevRevenue → きょう: ¥${current.totalRevenue} ($diffStr)';
}

String _levelName(int level) => switch (level) {
  1 => 'はじめてのお店',
  2 => 'お店をひろげるモード',
  3 => 'プロの店長モード',
  _ => '不明',
};
```

---

### Step 2: home_screen.dart に「作戦メモ」UI を追加 ✅ Haiku

#### 2-1. 現在の構造確認

```dart
class HomeScreen extends ConsumerStatefulWidget { ... }

// BottomNavigationBar で GameTab / LedgerTab / ProfileTab を切り替え
```

#### 2-2. 朝のコーチコメント表示を追加

**オプション A**: ゲーム開始時の「今日の目標」として表示

```dart
class GameTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(gameSessionProvider);
    final coachCommentAsync = ref.watch(
      todaysCoachCommentProvider(childUid),
    );
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // ★ 新規：AIコーチの「作戦メモ」
          coachCommentAsync.when(
            data: (comment) => _buildCoachMemoCard(comment),
            loading: () => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(height: 120, color: Colors.grey[300]),
            ),
            error: (err, st) => SizedBox.shrink(),
          ),
          
          // 既存：店舗ビジュアル・商品・接客
          StoreDisplay(...),
          ...
        ],
      ),
    );
  }
  
  Widget _buildCoachMemoCard(String comment) {
    return Card(
      margin: EdgeInsets.all(16),
      color: Color(0xFFFFF9E6),  // 薄い黄色（メモっぽい）
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🎓', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text('きょうの作戦メモ', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            SizedBox(height: 12),
            Text(comment,
              style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black87)),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text('― AIコーチより',
                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic)),
            ),
          ],
        ),
      ),
    );
  }
}
```

**オプション B**: 日報モーダルの下部に表示

```dart
// day_result_card.dart 内
void _showDayResultModal(BuildContext context, GameSessionModel session) {
  showModalBottomSheet(
    context: context,
    child: SingleChildScrollView(
      child: Column(
        children: [
          // 既存：売上・利益・概念習熟度
          _buildRevenueSection(),
          _buildProfitSection(),
          
          // ★ 新規：AIコーチ因果解説
          _buildCoachAnalysisSection(session),
        ],
      ),
    ),
  );
}

Widget _buildCoachAnalysisSection(GameSessionModel session) {
  return Container(
    padding: EdgeInsets.all(16),
    color: Color(0xFFFFF9E6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🎓 AIコーチからのコメント', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text(session.coachCommentReasoning ?? '',
          style: TextStyle(fontSize: 13, height: 1.6)),
      ],
    ),
  );
}
```

---

### Step 3: GameSessionModel に coachCommentReasoning を追加 ✅ Haiku

```dart
class GameSessionModel {
  // ... 既存フィールド ...
  
  final String? coachCommentReasoning;  // ★ 新規：AI因果解説コメント
  
  factory GameSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameSessionModel(
      // ... 既存フィールド復元 ...
      coachCommentReasoning: data['coachCommentReasoning'] as String?,
    );
  }
  
  Map<String, dynamic> toFirestore() => {
    // ... 既存フィールド ...
    'coachCommentReasoning': coachCommentReasoning,
  };
}
```

---

### Step 4: Provider 作成 ✅ Haiku

```dart
// ai_coach_provider.dart を拡張

final todaysCoachCommentProvider = FutureProvider.autoDispose
    .family<String, String>((ref, childUid) async {
  final sessionAsync = ref.watch(gameSessionProvider);
  final masteryAsync = ref.watch(
    conceptMasteryProvider.family(childUid),
  );
  
  return sessionAsync.when(
    data: (session) {
      if (session == null) return '';
      
      return masteryAsync.when(
        data: (mastery) {
          final service = ref.read(claudeApiServiceProvider);
          return service.generateCoachCommentWithCausality(
            session,
            ref.read(currentChildProvider).value!,
            mastery,
            null,  // previousSessionData は今回はスキップ
          );
        },
        loading: () => '',
        error: (e, st) => 'コメント読込中…',
      );
    },
    loading: () => '',
    error: (e, st) => '',
  );
});
```

---

### Step 5: Cloud Functions で永続化（オプション） ✅ Haiku

セッション完了時に AI コメントを事前生成して Firestore に保存：

```typescript
// onGameSessionCompleted 内

// ★ 新規：AIコーチコメントを生成して保存
const coachComment = await generateCoachCommentWithCausality(
  sessionData,
  childData,
  conceptMasteryData,
);

await sessionRef.update({
  coachCommentReasoning: coachComment,
});
```

---

## テスト項目

| # | テスト項目 | 期待動作 |
|---|----------|---------|
| 1 | プロンプト実行 | セッションデータから因果関係コメント生成 |
| 2 | コメント内容 | 「〜だから」「〜が売れた」など因果関係を含む |
| 3 | UI 表示 | GameTab に「作戦メモ」カード表示 |
| 4 | 複数セッション | 異なる結果で異なるコメント生成 |
| 5 | エラーハンドリング | API 失敗時も画面が止まらない |
| 6 | トークン使用量 | 1 回の呼び出しで Claude API の費用が許容範囲内 |

---

## 実装難度

| 項目 | 難度 | 理由 |
|------|------|------|
| プロンプト設計 | 中 | 因果関係を正確に説明させるコツが必要 |
| ヘルパー関数 | 低 | データフォーマット処理のみ |
| UI 実装 | 低 | Card とテキスト表示のシンプル構成 |
| Provider | 低 | 既存パターンの応用 |
| Cloud Functions | 低〜中 | 既存の onGameSessionCompleted 拡張 |

---

## プロンプト改善ポイント

### 現在の課題

```
「きょうもよくがんばったね！」
→ 小学生が「なぜ売れた？なぜ売れなかった？」の因果を読めない
```

### 改善のコツ

1. **具体的な数字を含める**
   - 悪い例: 「売上が少なかったね」
   - 良い例: 「レモネード2個 vs コーヒー5個。コーヒーが人気ですね」

2. **価格と購入の因果を明示**
   - 「150円に上げたら、お客さんが『高い』と言って見送った」

3. **「かもしれない」で推測を留める**
   - 確実でない仮説は「かも」で柔らかく提示

4. **翌日への行動提案**
   - 「明日は 110 円で試してみたら？」← 実行可能なアクション

5. **得意概念を活かした助言**
   - 子どもが「利益率」が得意 → 「利益率を 20%まで高められたね」

---

## 依存性

- ✅ 既実装の `claude_api_service.dart` を活用
- ✅ `GameSessionModel` / `ConceptMasteryModel` を参照
- ✅ Claude Haiku API（1 回/日、トークン使用量：100-200 程度）
- ❌ AI の新規実装なし（プロンプト改善のみ）

---

## デプロイチェックリスト

- [ ] プロンプト文字列が正確か確認
- [ ] generateCoachCommentWithCausality 関数実装・テスト
- [ ] ヘルパー関数が正確に動作
- [ ] UI カード（_buildCoachMemoCard）が表示される
- [ ] Provider が daily で AI API を呼び出す
- [ ] Firestore に coachCommentReasoning が保存される
- [ ] エミュレータで複数セッション実施してコメント内容確認
- [ ] API 費用モニタリング（1 セッション 50 トークン程度を想定）

---

## 補足：プロンプトのチューニング

実装後、子どもの反応に応じて以下の点をチューニング：

- コメント長（現在 200-300 字）を短縮 / 延長
- 絵文字の数を増減
- 難しい言葉の言い換え（「利益率」→「もうかり具合」など）
- 推奨アクションの具体性レベル

---

*設計書完成。プロンプト改善が主体で、実装難度は全体的に低い。*
