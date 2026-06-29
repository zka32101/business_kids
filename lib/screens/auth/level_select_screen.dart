import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/child_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  int _selectedLevel = 1;
  bool _isLoading = false;

  Future<void> _start() async {
    final user = ref.read(authStateProvider).valueOrNull;

    setState(() => _isLoading = true);
    try {
      final parentUid = user?.uid ?? 'guest';
      await ref.read(childNotifierProvider.notifier).createChild(parentUid, 'こども', _selectedLevel);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'レベルを選んでね！',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'あとで変えることもできるよ',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                ..._LevelCard.options.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _LevelCard(
                    level: opt.level,
                    emoji: opt.emoji,
                    title: opt.title,
                    subtitle: opt.subtitle,
                    stars: opt.stars,
                    color: opt.color,
                    isSelected: _selectedLevel == opt.level,
                    onTap: () => setState(() => _selectedLevel = opt.level),
                  ),
                )),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('はじめる！', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelOption {
  final int level;
  final String emoji;
  final String title;
  final String subtitle;
  final int stars;
  final Color color;

  const _LevelOption({
    required this.level,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.stars,
    required this.color,
  });
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String emoji;
  final String title;
  final String subtitle;
  final int stars;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  static const List<_LevelOption> options = [
    _LevelOption(level: 1, emoji: '🍋', title: 'レベル1', subtitle: '小1〜3年向け', stars: 1, color: AppColors.level1),
    _LevelOption(level: 2, emoji: '🍙', title: 'レベル2', subtitle: '小3〜5年向け', stars: 2, color: AppColors.level2),
    _LevelOption(level: 3, emoji: '🏪', title: 'レベル3', subtitle: '小5〜6年向け', stars: 3, color: AppColors.level3),
  ];

  const _LevelCard({
    required this.level,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.stars,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withValues(alpha: 0.3) : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Row(children: List.generate(3, (i) => Text(
                    i < stars ? '⭐' : '☆',
                    style: const TextStyle(fontSize: 16),
                  ))),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}
