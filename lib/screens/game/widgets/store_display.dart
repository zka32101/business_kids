import 'package:flutter/material.dart';
import '../../../models/child.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/constants.dart';

class StoreDisplay extends StatelessWidget {
  final StoreLevel storeLevel;
  final int level;

  const StoreDisplay({super.key, required this.storeLevel, required this.level});

  @override
  Widget build(BuildContext context) {
    final (bgStart, bgEnd, shelves, showSign) = switch (storeLevel) {
      StoreLevel.small => (
          const Color(0xFFFFF3E0),
          const Color(0xFFFFE0B2),
          ['🍋'],
          false,
        ),
      StoreLevel.medium => (
          const Color(0xFFE8F5E9),
          const Color(0xFFC8E6C9),
          ['🍋', '🍙', '☕'],
          true,
        ),
      StoreLevel.full => (
          const Color(0xFFE3F2FD),
          const Color(0xFFBBDEFB),
          ['🍋', '🍙', '☕', '🍱', '🍦'],
          true,
        ),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.padding, vertical: 8),
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgStart, bgEnd],
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: Colors.brown.shade300, width: 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏪', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: shelves.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  )).toList(),
                ),
              ],
            ),
          ),
          if (showSign)
            Positioned(
              top: 8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'OPEN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'レベル$level',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
