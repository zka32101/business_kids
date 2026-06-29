import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/child.dart';
import '../../../models/game_session.dart';
import '../../../providers/ai_coach_provider.dart';
import '../../../providers/iap_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';

class DayResultCard extends ConsumerWidget {
  final ChildModel child;
  final GameSessionModel session;
  final VoidCallback onNextDay;

  const DayResultCard({
    super.key,
    required this.child,
    required this.session,
    required this.onNextDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = session.dailySummary;
    final iapState = ref.watch(iapProvider);
    final isPremium = iapState.planType != PlanType.free;
    final aiState = ref.watch(aiCoachProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('今日の結果')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text('お疲れ様でした！', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _ResultGrid(ds: ds),
            const SizedBox(height: 16),
            _RegularCustomersSection(session: session),
            const SizedBox(height: 16),
            _CoachCausalitySection(childUid: child.uid, session: session),
            const SizedBox(height: 16),
            _BestProducts(session: session),
            if (isPremium) ...[
              const SizedBox(height: 16),
              _AiCoachBubble(aiState: aiState),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNextDay,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('次の日へ', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultGrid extends StatelessWidget {
  final DailySummary ds;

  const _ResultGrid({required this.ds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ResultItem(label: '売上', value: AppFormatters.yen(ds.totalRevenue), emoji: '💰'),
              _ResultItem(label: '利益', value: AppFormatters.yen(ds.totalProfit), emoji: '📈'),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              _ResultItem(label: '販売数', value: '${ds.totalSalesCount}個', emoji: '🛍️'),
              _ResultItem(
                label: '利益率',
                value: AppFormatters.percent(ds.averageProfitMargin * 100),
                emoji: '📊',
                valueColor: ds.averageProfitMargin >= 0.2 ? AppColors.profit : AppColors.loss,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color? valueColor;

  const _ResultItem({required this.label, required this.value, required this.emoji, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// 常連さん獲得・喪失セクション
class _RegularCustomersSection extends StatelessWidget {
  final GameSessionModel session;

  const _RegularCustomersSection({required this.session});

  @override
  Widget build(BuildContext context) {
    final newRegulars = session.sales
        .where((s) => s.npcBecameRegular)
        .map((s) => s.customerNpcId)
        .whereType<String>()
        .toSet();
    final totalRegulars = session.totalRegularCount;

    if (newRegulars.isEmpty && totalRegulars == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🌟', style: TextStyle(fontSize: 20)),
              SizedBox(width: 6),
              Text(
                'じょうれんさん',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (newRegulars.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '${newRegulars.length}人が新しく常連さんになったよ！',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          if (newRegulars.isNotEmpty) const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👥', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'じょうれんさん',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalRegulars人',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BestProducts extends StatelessWidget {
  final GameSessionModel session;

  const _BestProducts({required this.session});

  @override
  Widget build(BuildContext context) {
    if (session.sales.isEmpty) return const SizedBox();

    final topSelling = session.topSellingProduct;
    final topProfit = session.topProfitProduct;

    if (topSelling == null && topProfit == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('今日のベスト商品', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (topSelling != null)
            Text('🏆 一番売れた: $topSelling'),
          if (topProfit != null)
            Text('💰 一番もうかった: $topProfit'),
        ],
      ),
    );
  }
}

/// AIコーチの因果解説コメント（売上結果の分析）
class _CoachCausalitySection extends StatelessWidget {
  final String childUid;
  final GameSessionModel session;

  const _CoachCausalitySection({
    required this.childUid,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final comment = session.coachCommentReasoning;

    if (comment == null || comment.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🎓', style: TextStyle(fontSize: 20)),
              SizedBox(width: 6),
              Text(
                'きょうの作戦メモ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '― AIコーチより',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCoachBubble extends StatelessWidget {
  final AiCoachState aiState;

  const _AiCoachBubble({required this.aiState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: aiState.isLoading
                ? const LinearProgressIndicator()
                : Text(
                    aiState.advice ?? (aiState.canGetAdviceToday ? 'アドバイスを取得できます' : '今日はすでにアドバイスをもらいました'),
                    style: const TextStyle(fontSize: 13),
                  ),
          ),
        ],
      ),
    );
  }
}
