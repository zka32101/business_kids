# 実装設計書：① じょうれんさん（常連顧客システム）

> **バージョン**: v1.0.1  
> **優先度**: 🥇 最高（ゲーム体験の深化）  
> **実装予定期間**: 3〜4日  
> **担当**: Haiku（設計・簡単部分）→ Sonnet（複雑ロジック）

---

## 概要

NPC 客に「購買履歴」と「好感度」を付与し、適正価格で継続購入すると「常連さん」化。高値掴みや不誠実な値付けをすると来店頻度が低下する。子どもが「信用」という経営コンセプトを体験的に学ぶ。

**学習概念**: 新規追加 `trust`（信用）= 第 9 番目の習熟度指標

---

## 実装サイズ

| 範囲 | 規模 |
|------|------|
| データモデル変更 | NpcModel + GameSessionModel 拡張 |
| ロジック変更 | game_logic_service.dart 拡張 |
| UI 変更 | day_result_card.dart に「常連さん」表示追加 |
| Firestore スキーマ | gameSessions の sales[] に好感度フィールド追加 |

---

## 実装ステップ

### Step 1: データモデル拡張 ✅ Haiku

#### 1-1. ⚠️ NpcModel の設計修正（const クラスは拡張しない）

**現状**
NpcModel は `const` 修飾子の immutable クラス。NPCの性格（name, preferredMaxPrice 等）は変わらない。

**新規アプローチ**
常連化の状態（purchaseHistory, favoriteScore, isRegular）は NpcModel 外で管理：

**A. セッション中（メモリ）:**
ゲーム中は `GameSessionModel` の extension または `SessionNpcState` DTO で管理
```dart
class SessionNpcState {
  final String npcId;
  final int favoriteScore;          // この日のスコア (0-100)
  final List<PurchaseRecord> dailyHistory;  // 本日の購入履歴
  final bool isBringingFriend;      // 今日友達を連れてくるか
  
  const SessionNpcState({...});
}
```

**B. セッション終了後（永続化）:**
`npcStates/{childUid}/npc/{npcId}` コレクション（Step 5 の通り）に保存

**変わらない部分**
- NpcModel は const のまま（性格属性：name, emoji, preferredMaxPrice など）
- game_logic_service で SessionNpcState を操作する

**変更理由**
- NpcModel を const のまま保つ→ DefaultNpcs の static const リスト変更不要
- 状態管理を分離→ ゲーム中の一時状態と永続データを明確に分離
- 拡張性→ 同じ NPC が複数日登場する時、日ごとに favoriteScore が異なる

#### 1-2. `SaleRecord` に NPC 追跡情報を追加

**現在のSaleRecord** （`game_session.dart` より）
```dart
class SaleRecord {
  final String productId;
  final String productName;
  final int costPrice;
  final int sellingPrice;
  final int quantity;
  final bool customerBought;
  final DateTime timestamp;
  // ... profit, revenue getters
}
```

**変更後**
```dart
class SaleRecord {
  // ... 既存フィールド（変更なし）...
  
  // ★ 新規フィールド
  final String? customerNpcId;           // 対応した NPC ID
  final int npcFavoriteScoreDelta;       // NPC 好感度の変化量（±5 など）
  final bool npcBecameRegular;           // この販売で常連化したか
}
```

**実装上の注意**
- `customerNpcId` は `SessionNpcState` と紐付け（Step 1-1 で定義）
- `npcFavoriteScoreDelta` は game_logic_service で計算
  - 適正価格（仕入れ値の1.2〜1.5倍）で購入 → +5
  - 高すぎる価格で見送り → -3
  - 高すぎる価格での購入後、次回も高値 → -10（失望）
- `npcBecameRegular` = npcFavoriteScore が 70 以上になった瞬間

---

### Step 2: game_logic_service.dart にロジック追加 ⚙️ Sonnet 推奨

#### 2-1. 新規メソッド：`updateNpcFavorite()`

```dart
/// NPC の好感度を更新
/// 返値: (favoriteScoreChange, becameRegular)
(int, bool) updateNpcFavorite(
  NpcModel npc,
  int sellingPrice,
  int costPrice,
  bool willBuy,
  int level,
) {
  int change = 0;
  bool becameRegular = false;
  
  // ロジック例：
  // 1. 適正範囲判定 → favoriteScore += 5
  // 2. 高すぎる → favoriteScore -= 3 (見送り時) / -5 (購入時)
  // 3. 常連さん優遇：好感度70以上なら+10%マージン許容
  
  // 返値例: (change=+5, becameRegular=false)
  return (change, becameRegular);
}
```

#### 2-2. 新規メソッド：`shouldBringFriend()`

```dart
/// 常連さんが友達を連れてくるか判定
bool shouldBringFriend(NpcModel npc, int level) {
  if (!npc.isRegular) return false;
  // レベルに応じた確率：L1:0%, L2:15%, L3:25%
  final chance = switch (level) {
    1 => 0.0,
    2 => 0.15,
    3 => 0.25,
    _ => 0.0,
  };
  return _rng.nextDouble() < chance;
}
```

#### 2-3. 既存メソッド拡張：`willCustomerBuy()`

現在:
```dart
bool willCustomerBuy(NpcModel customer, int sellingPrice, int costPrice, int level) {
  // 価格だけで判定
}
```

変更後:
```dart
bool willCustomerBuy(NpcModel customer, int sellingPrice, int costPrice, int level) {
  // ★ 好感度による判定確率の調整
  double baseProbability = _calculateBaseProbability(sellingPrice, costPrice);
  
  // 常連さんは10%割増し許容
  if (customer.isRegular) {
    baseProbability += 0.1;
  }
  
  // 嫌い度が高いと購入確率DOWN
  if (customer.favoriteScore < 30) {
    baseProbability *= 0.5;
  }
  
  return _rng.nextDouble() < baseProbability;
}
```

---

### Step 3: game_session_provider 修正 ✅ Haiku

#### 3-1. `startDay()` 時に NPC リストを初期化

現在は毎回ランダムな NPC を生成していると推定。

変更後：
```dart
void startDay(ChildModel child) {
  // Firestore から過去の常連データを読み込む
  final regularCustomers = _firestore.getPreviousNpcs(child.uid);
  
  // 常連 + 新規客の混合でその日の客リストを生成
  final dailyCustomers = _generateDailyCustomerList(
    level: child.currentLevel,
    regulars: regularCustomers,
    newCustomerCount: _calculateNewCustomerCount(child.currentLevel),
  );
  
  gameSession = gameSession?.copyWith(npcList: dailyCustomers);
}
```

---

### Step 4: UI 変更（day_result_card.dart） ✅ Haiku

#### 4-1. 日報に「常連さん」セクション追加

```dart
class DayResultCard extends StatelessWidget {
  // ...
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // 既存：売上・利益・利益率
          _buildRevenueSection(),
          _buildProfitSection(),
          
          // ★ 新規：常連さん
          _buildRegularCustomersSection(),
          
          // その他...
        ],
      ),
    );
  }
  
  Widget _buildRegularCustomersSection() {
    final regulars = session.sales
        .where((s) => s.becameRegular)
        .map((s) => s.customerNpcId)
        .toSet()
        .length;
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('👥 常連さんと新しい友達', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('きょう新しく常連さんになった人: $regulars人'),
          SizedBox(height: 4),
          Text('合計常連さん: ${session.totalRegularCount}人', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}
```

---

### Step 5: Firestore スキーマ更新 ✅ Haiku

#### 5-1. gameSessions/{sessionId} の更新

```json
{
  "childUid": "...",
  "date": "2026-06-10",
  "level": 2,
  "totalRevenue": 1500,
  "totalProfit": 350,
  "totalSalesCount": 15,
  "averageProfitMargin": 0.23,
  "totalRegularCount": 4,              // ★ 新規
  "sales": [
    {
      "productId": "lemonade",
      "productName": "レモネード",
      "quantity": 1,
      "sellingPrice": 120,
      "profit": 70,
      "customerBought": true,
      "customerNpcId": "npc_001_takashi",
      "npcFavoriteScoreChange": 5,      // ★ 新規
      "becameRegular": false             // ★ 新規
    },
    // ...
  ],
  "createdAt": "..."
}
```

#### 5-2. npcStates/{childUid}/npc/{npcId} の新規コレクション（オプション）

常連データを永続化する場合：

```json
{
  "npcId": "npc_001_takashi",
  "name": "たかしくん",
  "favoriteScore": 65,
  "isRegular": false,
  "lastVisitDate": "2026-06-10",
  "totalPurchases": 8,
  "purchaseHistory": [
    {
      "date": "2026-06-08",
      "productId": "lemonade",
      "sellingPrice": 100,
      "bought": true
    },
    // ...
  ],
  "updatedAt": "..."
}
```

---

### Step 6: 概念習熟度に `trust` を追加 ✅ Haiku

#### 6-1. ConceptKeys に新規キー追加

```dart
class ConceptKeys {
  ConceptKeys._();

  static const String costPrice = 'cost_price';
  static const String profit = 'profit';
  static const String revenue = 'revenue';
  static const String priceSet = 'price_setting';
  static const String inventory = 'inventory';
  static const String profitMargin = 'profit_margin';
  static const String competition = 'competition';
  static const String tax = 'tax';
  static const String trust = 'trust';  // ★ 新規
}
```

#### 6-2. ConceptMasteryModel の更新

```dart
class ConceptMasteryModel {
  // ...
  
  static const Map<String, String> conceptNames = {
    ConceptKeys.costPrice: '仕入れ値',
    ConceptKeys.profit: '利益',
    ConceptKeys.revenue: '売上',
    ConceptKeys.priceSet: '値段設定',
    ConceptKeys.inventory: '在庫',
    ConceptKeys.profitMargin: '利益率',
    ConceptKeys.competition: '競合',
    ConceptKeys.tax: '消費税',
    ConceptKeys.trust: '信用',  // ★ 新規
  };
  
  static const List<String> allConcepts = [
    ConceptKeys.costPrice,
    ConceptKeys.profit,
    ConceptKeys.revenue,
    ConceptKeys.priceSet,
    ConceptKeys.inventory,
    ConceptKeys.profitMargin,
    ConceptKeys.competition,
    ConceptKeys.tax,
    ConceptKeys.trust,  // ★ 新規
  ];
}
```

---

### Step 7: Cloud Functions 更新 ⚙️ Sonnet 推奨

#### 7-1. onGameSessionCompleted の拡張

セッション完了時に `trust` スコアを計算・更新：

```typescript
// calcConceptDeltas() 内
const trustDelta = calculateTrustDelta(session, previousRegularCount);
scores[ConceptKeys.trust] = Math.min(100, 
  (previousScores[ConceptKeys.trust] ?? 0) + trustDelta
);
```

**calcTrustDelta のロジック例**
- 常連さん新規獲得 1 人 → +5
- 常連さん喜流出 1 人 → -8
- 月 1 回「常連さんが友達を連れてくる」 → +10

---

## テスト項目

| # | テスト項目 | 期待動作 |
|---|----------|--------|
| 1 | NPC 購入後の好感度加算 | 適正価格で購入 → +5 |
| 2 | 高値見送りの好感度減少 | 高すぎる価格 → -3 |
| 3 | 常連化の条件判定 | favoriteScore >= 70 → isRegular = true |
| 4 | 常連さんの購入確率 | 好感度ボーナス（+10%）が適用 |
| 5 | 日報の常連表示 | totalRegularCount が正確に表示 |
| 6 | trust スコア計算 | 常連増加に応じてスコアUP |
| 7 | NPCデータ永続化 | セッション終了後、Firestore に保存される |
| 8 | 常連さんが友達連れ | isRegular && shouldBringFriend() → 翌日新NPCが登場 |

---

## 実装難度

| 項目 | 難度 | 理由 |
|------|------|------|
| データモデル拡張 | 低 | 単なるフィールド追加 |
| ロジック実装 | 中→高 | 好感度変動の確率ロジック複雑 → **Sonnet推奨** |
| UI 表示 | 低 | day_result_card に 1 セクション追加 |
| Firestore スキーマ | 低 | 既存構造への拡張のみ |
| Cloud Functions | 中 | trust スコア計算ロジック |

---

## 依存性

- ❌ AI 実装なし（ロジックベース）
- ✅ 既存 NpcModel / GameSessionModel を拡張
- ✅ game_logic_service が中核
- ✅ Cloud Functions onGameSessionCompleted を拡張

---

## デプロイチェックリスト

- [ ] NpcModel / SaleRecord / PurchaseRecord の型定義確認
- [ ] game_logic_service のロジック単体テスト実施
- [ ] day_result_card.dart で新セクション表示確認
- [ ] Firestore セキュリティルール更新確認
- [ ] Cloud Functions デプロイ確認
- [ ] エミュレータで 1 セッション プレイしてデータ確認
- [ ] 親ダッシュボード → 概念習熟度 に `trust` が表示される確認

---

*設計書完成。Step 2（ロジック）と Step 7（Cloud Functions）は複雑なため Sonnet で対応推奨。*
