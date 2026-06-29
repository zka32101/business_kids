import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/child.dart';
import '../models/game_session.dart';
import '../models/concept_mastery.dart';

class ClaudeApiService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _apiVersion = '2023-06-01';

  final String _apiKey;

  ClaudeApiService(this._apiKey);

  Future<String> getCoachAdvice(ChildModel child, GameSessionModel session) async {
    final summary = session.dailySummary;
    final prompt = '''
子どもの経営データ:
名前: ${child.name}
レベル: ${child.currentLevel}
今日の売上: ¥${summary.totalRevenue}
今日の利益: ¥${summary.totalProfit}
利益率: ${(summary.averageProfitMargin * 100).toInt()}%
売上件数: ${summary.totalSalesCount}件
失敗した販売: ${summary.failedSales}件
${session.topSellingProduct != null ? '一番売れた商品: ${session.topSellingProduct}' : ''}
${session.topProfitProduct != null ? '一番利益が高い商品: ${session.topProfitProduct}' : ''}

80文字以内でアドバイスを1つだけ書いてください。
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 200,
          'system': 'あなたは小学生向けの優しいコンビニ経営コーチです。短く、わかりやすく、ひらがなを多めに使って、子どもが理解できる言葉でアドバイスしてください。',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List;
        return content.first['text'] as String? ?? '今日もよく頑張ったね！明日もがんばろう！';
      }
      return '今日もよく頑張ったね！明日もがんばろう！';
    } catch (_) {
      return '今日もよく頑張ったね！明日もがんばろう！';
    }
  }

  Future<String> getWeeklyReport(ChildModel child, List<GameSessionModel> weekSessions) async {
    final totalRevenue = weekSessions.fold(0, (sum, s) => sum + s.dailySummary.totalRevenue);
    final totalProfit = weekSessions.fold(0, (sum, s) => sum + s.dailySummary.totalProfit);
    final avgMargin = totalRevenue > 0 ? totalProfit / totalRevenue : 0.0;

    final prompt = '''
子どもの週間経営データ:
名前: ${child.name}
レベル: ${child.currentLevel}
今週プレイした日数: ${weekSessions.length}日
今週の合計売上: ¥$totalRevenue
今週の合計利益: ¥$totalProfit
平均利益率: ${(avgMargin * 100).toInt()}%

100文字以内で週間レポートとアドバイスを書いてください。
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 300,
          'system': 'あなたは小学生の保護者に向けて、子どもの学習進捗を報告する教育コーチです。',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List;
        return content.first['text'] as String? ?? '今週もよく頑張りました！';
      }
      return '今週もよく頑張りました！';
    } catch (_) {
      return '今週もよく頑張りました！';
    }
  }

  /// AIコーチ因果解説：セッション結果から「売れた理由」「売れなかった理由」を分析
  Future<String> generateCoachCommentWithCausality(
    GameSessionModel session,
    ChildModel child,
    ConceptMasteryModel? conceptMastery,
  ) async {
    final summary = session.dailySummary;
    final salesBreakdown = _formatSalesBreakdown(session.sales);
    final conceptLine = _formatConceptMastery(conceptMastery);
    final levelName = _levelName(child.currentLevel);

    final prompt = '''
あなたは小学生向けのコンビニ経営ゲームのAIコーチです。
プレイヤー「${child.name}」が今日の店舗経営の結果を見ています。

【きょう1日の経営結果】
- 売上: ¥${summary.totalRevenue}
- 利益: ¥${summary.totalProfit}
- 利益率: ${(summary.averageProfitMargin * 100).toStringAsFixed(1)}%
- 販売件数: ${summary.totalSalesCount}件
${session.topSellingProduct != null ? '- ベスト商品: ${session.topSellingProduct}' : ''}

【販売詳細】
$salesBreakdown

【プレイヤーの得意概念（習熟度）】
$conceptLine

【ゲーム難度】
レベル${child.currentLevel}：$levelName

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

コメントを生成してください。
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 400,
          'system': 'あなたは小学生向けの優しいコンビニ経営コーチです。短く、わかりやすく、ひらがなを多めに使って、子どもが理解できる言葉で、売上の因果関係を説明してください。',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List;
        return content.first['text'] as String? ?? '今日もよく頑張ったね！';
      }
      return '今日もよく頑張ったね！';
    } catch (_) {
      return '今日もよく頑張ったね！';
    }
  }

  // ─── ヘルパー関数 ─────────────────────────────────────────

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

    if (byProduct.isEmpty) return '（販売記録なし）';

    return byProduct.entries
        .map((e) => '- ${e.key}: ${e.value.$2}個売れた（${e.value.$1}人が購入）')
        .join('\n');
  }

  String _formatConceptMastery(ConceptMasteryModel? mastery) {
    if (mastery == null) return '（データなし）';

    final sorted = mastery.masteryScores.entries
        .where((e) => e.value > 50)
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isEmpty) return '（まだ得意な概念はありません）';

    return sorted
        .take(3)
        .map((e) => '- ${ConceptMasteryModel.conceptNames[e.key] ?? e.key}: ${e.value}点')
        .join('\n');
  }

  String _levelName(int level) => switch (level) {
    1 => 'はじめてのお店',
    2 => 'お店をひろげるモード',
    3 => 'プロの店長モード',
    _ => '不明',
  };
}
