import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../models/child.dart';
import '../../providers/child_provider.dart';
import '../../providers/iap_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
// import '../../widgets/badge_display.dart'; // TODO: Phase 1 - ゲーム性強化

class ProfileTab extends ConsumerWidget {
  final ChildModel child;

  const ProfileTab({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iapState = ref.watch(iapProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('プロフィール')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          children: [
            _AvatarCard(child: child),
            const SizedBox(height: 16),
            _StatsCard(child: child),
            const SizedBox(height: 16),
            if (iapState.planType == PlanType.free && !child.isTrialExpired)
              _TrialBanner(child: child),
            const SizedBox(height: 16),
            // BadgeDisplay(childUid: child.uid), // TODO: Phase 1 - ゲーム性強化
            // const SizedBox(height: 16),
            _MenuSection(child: child),
          ],
        ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final ChildModel child;

  const _AvatarCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final levelColor = child.currentLevel == 1
        ? AppColors.level1
        : child.currentLevel == 2
            ? AppColors.level2
            : AppColors.level3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: levelColor.withValues(alpha: 0.2),
            child: Text(child.name.isNotEmpty ? child.name[0] : '?',
                style: TextStyle(fontSize: 32, color: levelColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'レベル${child.currentLevel}',
                    style: TextStyle(color: levelColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${child.storeLevel.name}のお店',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends ConsumerWidget {
  final ChildModel child;

  const _StatsCard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('累計実績', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(label: '総売上', value: AppFormatters.yen(child.totalRevenue), emoji: '💰'),
              _StatItem(label: '総利益', value: AppFormatters.yen(child.totalProfit), emoji: '📈'),
              _StatItem(label: 'プレイ日数', value: '${child.consecutiveDays}日', emoji: '📅'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _StatItem({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TrialBanner extends StatelessWidget {
  final ChildModel child;

  const _TrialBanner({required this.child});

  @override
  Widget build(BuildContext context) {
    final remaining = AppConstants.trialDays - child.trialDaysElapsed;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        children: [
          const Text('⏰', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '無料体験中：あと$remaining日',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/bankruptcy'),
            child: const Text('プランを見る'),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends ConsumerWidget {
  final ChildModel child;

  const _MenuSection({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.swap_horiz,
          label: 'レベルを変える',
          onTap: () => context.go('/level-select'),
        ),
        _MenuItem(
          icon: Icons.supervisor_account,
          label: '親ダッシュボード',
          onTap: () => context.go('/parent-dashboard'),
        ),
        _MenuItem(
          icon: Icons.smart_toy_outlined,
          label: 'AIコーチの設定',
          onTap: () => _showApiKeyDialog(context),
        ),
        _MenuItem(
          icon: Icons.logout,
          label: '子どもを変える',
          onTap: () {
            ref.read(selectedChildUidProvider.notifier).state = null;
            context.go('/level-select');
          },
        ),
      ],
    );
  }
}

Future<void> _showApiKeyDialog(BuildContext context) async {
  const storage = FlutterSecureStorage();
  final currentKey = await storage.read(key: 'claude_api_key') ?? '';
  final controller = TextEditingController(text: currentKey);

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('AIコーチの設定'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Claude API キーを入力するとAIコーチが使えます。\n空欄の場合はAIコーチは無効になります。',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'APIキー (sk-ant-...)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () async {
            final key = controller.text.trim();
            if (key.isEmpty) {
              await storage.delete(key: 'claude_api_key');
            } else {
              await storage.write(key: 'claude_api_key', value: key);
            }
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
          child: const Text('保存'),
        ),
      ],
    ),
  );

  controller.dispose();
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
