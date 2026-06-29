import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge.dart';
import '../providers/badge_provider.dart';

class BadgeDisplay extends ConsumerWidget {
  final String childUid;

  const BadgeDisplay({Key? key, required this.childUid}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earnedBadgesAsync = ref.watch(earnedBadgesProvider(childUid));
    final currentTitleAsync = ref.watch(currentTitleProvider(childUid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        currentTitleAsync.when(
          data: (title) {
            if (title == null) return const SizedBox.shrink();
            return _buildTitleCard(title);
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'バッジ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        earnedBadgesAsync.when(
          data: (badges) {
            if (badges.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('バッジはまだ取得していません'),
              );
            }
            return _buildBadgeGrid(badges);
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
          error: (err, __) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('エラー: $err'),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleCard(BadgeTitle title) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    final bgColor = colors[(title.rankLevel - 1) % colors.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor.shade300, bgColor.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '現在の称号',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title.description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid(List<AchievementBadge> badges) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeItem(context, badge);
      },
    );
  }

  Widget _buildBadgeItem(BuildContext context, AchievementBadge badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(context, badge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              badge.displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, AchievementBadge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(badge.displayName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カテゴリ: ${_getCategoryLabel(badge.category)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(badge.description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '獲得条件: ${badge.condition}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'sales':
        return '売上';
      case 'regulars':
        return '常連客';
      case 'profit':
        return '利益';
      case 'learning':
        return '学習';
      default:
        return category;
    }
  }
}
