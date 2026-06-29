import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/child.dart';
import '../../models/concept_mastery.dart';
import '../../models/game_session.dart';
import '../../providers/child_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class LedgerTab extends ConsumerWidget {
  final ChildModel child;

  const LedgerTab({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('帳簿'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '週間レポート'),
              Tab(text: 'まなびメーター'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _WeeklyView(child: child),
            _ConceptView(child: child),
          ],
        ),
      ),
    );
  }
}

class _WeeklyView extends ConsumerWidget {
  final ChildModel child;

  const _WeeklyView({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_weeklySessionsProvider(child.uid));

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return const Center(child: Text('まだデータがないよ。ゲームをプレイしよう！'));
        }

        final totalRevenue = sessions.fold<int>(0, (s, gs) => s + gs.dailySummary.totalRevenue);
        final totalProfit = sessions.fold<int>(0, (s, gs) => s + gs.dailySummary.totalProfit);
        final totalSales = sessions.fold<int>(0, (s, gs) => s + gs.dailySummary.totalSalesCount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatCard(label: '今週の売上', value: AppFormatters.yen(totalRevenue), icon: '💰'),
                  const SizedBox(width: 8),
                  _StatCard(label: '今週の利益', value: AppFormatters.yen(totalProfit), icon: '📈'),
                  const SizedBox(width: 8),
                  _StatCard(label: '販売数', value: '$totalSales個', icon: '🛍️'),
                ],
              ),
              const SizedBox(height: 24),
              const Text('日別売上グラフ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    barGroups: sessions.asMap().entries.map((e) {
                      final ds = e.value.dailySummary;
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: ds.totalRevenue.toDouble(),
                            color: AppColors.primary,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                          BarChartRodData(
                            toY: ds.totalProfit.toDouble(),
                            color: AppColors.profit,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text('${v.toInt() + 1}日', style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('セッション履歴', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...sessions.reversed.map((gs) {
                final ds = gs.dailySummary;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Text('📅', style: TextStyle(fontSize: 24)),
                    title: Text('売上: ${AppFormatters.yen(ds.totalRevenue)} / 利益: ${AppFormatters.yen(ds.totalProfit)}'),
                    subtitle: Text('販売数: ${ds.totalSalesCount}個'),
                    trailing: Text(
                      AppFormatters.percent(ds.averageProfitMargin * 100),
                      style: TextStyle(
                        color: ds.averageProfitMargin >= 0.2 ? AppColors.profit : AppColors.loss,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ConceptView extends ConsumerWidget {
  final ChildModel child;

  const _ConceptView({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteryAsync = ref.watch(_conceptMasteryProvider(child.uid));

    return masteryAsync.when(
      data: (mastery) {
        if (mastery == null) {
          return const Center(child: Text('まだデータがないよ'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: mastery.overallProgress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '総合進捗: ${(mastery.overallProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ConceptMasteryModel.allConcepts.map((key) {
                  final score = mastery.masteryScores[key] ?? 0;
                  final isMastered = score >= 80;
                  return _ConceptTile(
                    conceptKey: key,
                    score: score,
                    isMastered: isMastered,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }
}

class _ConceptTile extends StatelessWidget {
  final String conceptKey;
  final int score;
  final bool isMastered;

  static const Map<String, String> _labels = {
    ConceptKeys.costPrice: '仕入れ値',
    ConceptKeys.profit: '利益',
    ConceptKeys.revenue: '売上',
    ConceptKeys.priceSet: '値段設定',
    ConceptKeys.inventory: '在庫管理',
    ConceptKeys.tax: '消費税',
    ConceptKeys.profitMargin: '利益率',
    ConceptKeys.competition: '競争',
    ConceptKeys.trust: '信用の力',
  };

  static const Map<String, String> _emojis = {
    ConceptKeys.costPrice: '🏷️',
    ConceptKeys.profit: '💰',
    ConceptKeys.revenue: '📊',
    ConceptKeys.priceSet: '🎯',
    ConceptKeys.inventory: '📦',
    ConceptKeys.tax: '🏛️',
    ConceptKeys.profitMargin: '📈',
    ConceptKeys.competition: '🏆',
    ConceptKeys.trust: '🤝',
  };

  const _ConceptTile({required this.conceptKey, required this.score, required this.isMastered});

  @override
  Widget build(BuildContext context) {
    final label = _labels[conceptKey] ?? conceptKey;
    final emoji = _emojis[conceptKey] ?? '📚';

    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMastered ? AppColors.secondary.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMastered ? AppColors.secondary : Colors.grey.shade300,
          width: isMastered ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              if (isMastered) const Icon(Icons.check_circle, color: AppColors.secondary, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(isMastered ? AppColors.secondary : AppColors.primary),
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 2),
          Text('$score点', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

final _weeklySessionsProvider = StreamProvider.autoDispose.family<List<GameSessionModel>, String>((ref, childId) {
  final fs = ref.read(firestoreServiceProvider);
  return fs.watchRecentSessions(childId, limit: 7);
});

final _conceptMasteryProvider = StreamProvider.autoDispose.family<ConceptMasteryModel?, String>((ref, childId) {
  final fs = ref.read(firestoreServiceProvider);
  return fs.watchConceptMastery(childId);
});
