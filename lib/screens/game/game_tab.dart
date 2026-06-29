import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/child.dart';
import '../../models/product.dart';
import '../../models/npc.dart';
import '../../providers/game_session_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import 'widgets/store_display.dart';
import 'widgets/customer_card.dart';
import 'widgets/price_selector.dart';
import 'widgets/day_result_card.dart';
// import '../../widgets/streak_widget.dart'; // TODO: Phase 1 - ゲーム性強化

class GameTab extends ConsumerStatefulWidget {
  final ChildModel child;

  const GameTab({super.key, required this.child});

  @override
  ConsumerState<GameTab> createState() => _GameTabState();
}

class _GameTabState extends ConsumerState<GameTab> {
  bool _completeDayCalled = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameSessionProvider);
    final session = gameState.session;

    // isDayComplete になった瞬間に一度だけ completeDay() を呼ぶ
    if (gameState.isDayComplete && session != null && !session.isCompleted && !_completeDayCalled) {
      _completeDayCalled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(gameSessionProvider.notifier).completeDay(widget.child);
      });
    }
    // 次の日が始まったらフラグをリセット
    if (!gameState.isDayComplete) {
      _completeDayCalled = false;
    }

    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gameState.isDayComplete) {
      if (gameState.isLoading) {
        // completeDay() 実行中はローディング表示
        return Scaffold(
          backgroundColor: const Color(0xFFFFF9E6),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('🎉', style: TextStyle(fontSize: 64)),
                SizedBox(height: 24),
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('きょうの記録をほぞん中...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      }
      return DayResultCard(
        child: widget.child,
        session: session,
        onNextDay: () => ref.read(gameSessionProvider.notifier).startDay(widget.child),
      );
    }

    final summary = session.dailySummary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.child.name}のお店'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.yen(summary.totalRevenue),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text('売上', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(12),
          //   child: StreakWidget(childUid: widget.child.uid, compact: true),
          // ), // TODO: Phase 1 - ゲーム性強化
          if (gameState.todayManager != null)
            _ManagerGreeting(manager: gameState.todayManager!),
          StoreDisplay(storeLevel: widget.child.storeLevel, level: widget.child.currentLevel),
          _CustomerCounter(remaining: gameState.customersRemaining),
          Expanded(
            child: gameState.currentCustomer != null
                ? _SaleSection(
                    child: widget.child,
                    customer: gameState.currentCustomer!,
                    products: ref.read(gameSessionProvider.notifier).productsForLevel(widget.child.currentLevel),
                  )
                : _CallCustomerButton(
                    onTap: () => ref.read(gameSessionProvider.notifier).spawnCustomer(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ManagerGreeting extends StatelessWidget {
  final NpcModel manager;

  const _ManagerGreeting({required this.manager});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingSmall),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Text(manager.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(manager.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  manager.greeting,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCounter extends StatelessWidget {
  final int remaining;

  const _CustomerCounter({required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding, vertical: 4),
      child: Row(
        children: [
          const Text('👥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            '残りのお客さん: $remaining人',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CallCustomerButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CallCustomerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛎️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.person_add),
            label: const Text('お客さんを呼ぶ', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleSection extends ConsumerStatefulWidget {
  final ChildModel child;
  final NpcModel customer;
  final List<ProductModel> products;

  const _SaleSection({
    required this.child,
    required this.customer,
    required this.products,
  });

  @override
  ConsumerState<_SaleSection> createState() => _SaleSectionState();
}

class _SaleSectionState extends ConsumerState<_SaleSection> {
  ProductModel? _selectedProduct;
  int? _selectedPrice;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Column(
        children: [
          CustomerCard(customer: widget.customer),
          const SizedBox(height: 16),
          const Text('商品を選ぶ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.products.map((p) => _ProductChip(
              product: p,
              isSelected: _selectedProduct?.productId == p.productId,
              onTap: () => setState(() {
                _selectedProduct = p;
                _selectedPrice = null;
              }),
            )).toList(),
          ),
          if (_selectedProduct != null && widget.child.currentLevel >= 2) ...[
            const SizedBox(height: 16),
            PriceSelector(
              product: _selectedProduct!,
              level: widget.child.currentLevel,
              selectedPrice: _selectedPrice,
              onPriceSelected: (price) => setState(() => _selectedPrice = price),
              priceOptions: ref.read(gameSessionProvider.notifier).priceOptionsFor(_selectedProduct!),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSell ? _sell : null,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('売る！', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canSell {
    if (_selectedProduct == null) return false;
    if (widget.child.currentLevel == 1) return true;
    return _selectedPrice != null;
  }

  void _sell() {
    final product = _selectedProduct!;
    final price = widget.child.currentLevel == 1 ? product.defaultSellingPrice : _selectedPrice!;
    ref.read(gameSessionProvider.notifier).processSale(product, price, 1);
    setState(() {
      _selectedProduct = null;
      _selectedPrice = null;
    });
  }
}

class _ProductChip extends StatelessWidget {
  final ProductModel product;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductChip({required this.product, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(product.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(
              '仕入: ${AppFormatters.yen(product.costPrice)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
