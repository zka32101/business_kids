import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/child.dart';
import '../../models/concept_mastery.dart';
import '../../models/game_session.dart';
import '../../models/session_npc_state.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/game_session_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('親ダッシュボード'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login-select');
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('ログインしてください'));
          }
          return _DashboardBody(parentUid: user.uid);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final String parentUid;

  const _DashboardBody({required this.parentUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childListAsync = ref.watch(childListProvider(parentUid));

    return childListAsync.when(
      data: (children) {
        if (children.isEmpty) {
          return const Center(child: Text('子どものプロフィールがありません'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.padding),
          itemCount: children.length,
          itemBuilder: (context, i) => _ChildCard(childId: children[i].uid),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }
}

class _ChildCard extends ConsumerWidget {
  final String childId;

  const _ChildCard({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(childProvider(childId));

    return childAsync.when(
      data: (child) {
        if (child == null) return const SizedBox();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChildProfileHeader(child: child),
                const Divider(height: 24),
                _LearningProgress(childId: child.uid),
                const SizedBox(height: 12),
                _SessionTrend(childId: child.uid),
                const SizedBox(height: 12),
                _RegularCustomersRow(child: child),
                const SizedBox(height: 12),
                _SettingsLinks(childId: child.uid),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(child: Text('エラー: $e')),
    );
  }
}

class _ChildProfileHeader extends StatelessWidget {
  final ChildModel child;

  const _ChildProfileHeader({required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            child.name.isNotEmpty ? child.name[0] : '?',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(child.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('レベル${child.currentLevel} / ${child.storeLevel.name}のお店',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text(
                '総売上: ${AppFormatters.yen(child.totalRevenue)} / 総利益: ${AppFormatters.yen(child.totalProfit)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LearningProgress extends ConsumerWidget {
  final String childId;

  const _LearningProgress({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteryAsync = ref.watch(_masteryProvider(childId));

    return masteryAsync.when(
      data: (mastery) {
        if (mastery == null) {
          return const Text('まだデータがありません', style: TextStyle(fontSize: 13));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('まなびの進捗', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: mastery.overallProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ConceptMasteryModel.allConcepts.map((key) {
                final score = mastery.masteryScores[key] ?? 0;
                final mastered = score >= 80;
                return Chip(
                  label: Text(
                    _conceptLabel(key),
                    style: TextStyle(
                      fontSize: 11,
                      color: mastered ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  backgroundColor: mastered ? AppColors.secondary : Colors.grey.shade100,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => const SizedBox(),
    );
  }

  String _conceptLabel(String key) {
    const labels = {
      ConceptKeys.costPrice: '仕入れ値',
      ConceptKeys.profit: '利益',
      ConceptKeys.revenue: '売上',
      ConceptKeys.priceSet: '値段設定',
      ConceptKeys.inventory: '在庫',
      ConceptKeys.tax: '税金',
      ConceptKeys.profitMargin: '利益率',
      ConceptKeys.competition: '競争',
      ConceptKeys.trust: '信用の力',
    };
    return labels[key] ?? key;
  }
}

class _SessionTrend extends ConsumerWidget {
  final String childId;

  const _SessionTrend({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_sessionsProvider(childId));

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox();

        final recent = sessions.take(5).toList();
        final avgProfit = recent.isEmpty
            ? 0
            : recent.fold<int>(0, (s, gs) => s + gs.dailySummary.totalProfit) ~/ recent.length;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('最近の傾向', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('直近${recent.length}回の平均利益: ${AppFormatters.yen(avgProfit)}'),
              Text('総プレイ回数: ${sessions.length}回'),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (e, _) => const SizedBox(),
    );
  }
}

/// じょうれんさん数・連続プレイ日数表示
class _RegularCustomersRow extends ConsumerWidget {
  final ChildModel child;

  const _RegularCustomersRow({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regularAsync = ref.watch(_regularCustomersProvider(child.uid));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Row(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: regularAsync.when(
              data: (regulars) => Text(
                'じょうれんさん: ${regulars.length}人 / 連続${child.consecutiveDays}日',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              loading: () => const Text('よみこみ中...', style: TextStyle(fontSize: 13)),
              error: (e, _) => Text(
                '連続${child.consecutiveDays}日プレイ中',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsLinks extends ConsumerWidget {
  final String childId;

  const _SettingsLinks({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(selectedChildUidProvider.notifier).state = childId;
              context.go('/home');
            },
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('ゲームを見る', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/bankruptcy'),
            icon: const Icon(Icons.payment, size: 16),
            label: const Text('プラン変更', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

final _masteryProvider = StreamProvider.autoDispose.family<ConceptMasteryModel?, String>((ref, childId) {
  final fs = ref.read(firestoreServiceProvider);
  return fs.watchConceptMastery(childId);
});

final _sessionsProvider = StreamProvider.autoDispose.family<List<GameSessionModel>, String>((ref, childId) {
  final fs = ref.read(firestoreServiceProvider);
  return fs.watchRecentSessions(childId, limit: 20);
});

final _regularCustomersProvider = FutureProvider.autoDispose.family<List<SessionNpcState>, String>((ref, childId) {
  final npcService = ref.read(npcStateServiceProvider);
  return npcService.loadRegularCustomers(childId);
});
