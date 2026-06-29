import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/iap_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class BankruptcyScreen extends ConsumerWidget {
  const BankruptcyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iapState = ref.watch(iapProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😢', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              const Text(
                'お店が閉まっちゃった...',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                '7日間の無料体験が終わったよ。\nつづきをプレイするにはプランを選んでね！',
                style: TextStyle(fontSize: 15, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _PlanCard(
                emoji: '⭐',
                title: '月額プラン',
                price: '¥100/月',
                description: '全レベル・全機能が使えるよ',
                color: AppColors.primary,
                isLoading: iapState.isLoading,
                onTap: () => ref.read(iapProvider.notifier).purchaseSubscription(),
              ),
              const SizedBox(height: 12),
              _PlanCard(
                emoji: '👑',
                title: 'ずっと使えるプラン',
                price: '¥1,000（買い切り）',
                description: 'ずっとお得！一回だけ払えばOK',
                color: AppColors.accent,
                isLoading: iapState.isLoading,
                onTap: () => ref.read(iapProvider.notifier).purchaseLifetime(),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/level-select'),
                child: const Text(
                  '無料のままつかう（レベル1のみ）',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),
              if (iapState.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  iapState.error!,
                  style: const TextStyle(color: AppColors.loss),
                  textAlign: TextAlign.center,
                ),
              ],
              TextButton(
                onPressed: () => ref.read(iapProvider.notifier).restorePurchases(),
                child: const Text(
                  '購入を復元する',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String price;
  final String description;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _PlanCard({
    required this.emoji,
    required this.title,
    required this.price,
    required this.description,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(price,
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                  Text(description,
                      style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
