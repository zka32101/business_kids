import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/challenge.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/child_provider.dart';

class ChallengesTab extends ConsumerWidget {
  const ChallengesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(currentChildProvider);

    return childAsync.when(
      data: (child) {
        if (child == null) {
          return const Center(child: Text('お子さんを選択してください'));
        }
        return _buildChallengesView(context, ref, child.uid);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('エラー: $err')),
    );
  }

  Widget _buildChallengesView(
      BuildContext context, WidgetRef ref, String childUid) {
    final dailyChallengeAsync = ref.watch(dailyChallengeProvider(childUid));
    final weeklyChallengeAsync = ref.watch(weeklyChallengeProvider(childUid));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '📅 本日のチャレンジ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          dailyChallengeAsync.when(
            data: (challenge) => _buildChallengeCard(context, challenge),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, __) => Text('エラー: $err'),
          ),
          const SizedBox(height: 24),
          const Text(
            '📊 週間チャレンジ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          weeklyChallengeAsync.when(
            data: (challenge) {
              if (challenge == null) {
                return const Text('チャレンジはありません');
              }
              return _buildChallengeCard(context, challenge);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, __) => Text('エラー: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, dynamic challenge) {
    final isDaily = challenge is DailyChallenge;
    final title = challenge.title;
    final description = challenge.description;
    final targetValue = challenge.targetValue;
    final currentValue = challenge.currentValue;
    final completed = challenge.completed;

    final progress = (currentValue / targetValue).clamp(0.0, 1.0);

    final bgColor = completed ? Colors.green : Colors.blue;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              bgColor.shade300,
              bgColor.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (completed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✓ 完了',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(progress, currentValue, targetValue),
            const SizedBox(height: 12),
            _buildRewardInfo(targetValue),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, int current, int target) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '進捗',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Text(
              '$current / $target',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(Colors.yellow.shade300),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardInfo(int targetValue) {
    int rewardCoins = 0;

    if (targetValue >= 50000) {
      rewardCoins = 500; // 売上チャレンジ
    } else if (targetValue == 3) {
      rewardCoins = 300; // 常連客チャレンジ
    } else if (targetValue == 1) {
      rewardCoins = 200; // 在庫チャレンジ
    } else if (targetValue >= 10000) {
      rewardCoins = 400; // 利益チャレンジ
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            '達成時の報酬: $rewardCoins コイン',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
