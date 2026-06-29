import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/formatters.dart';

class PriceSelector extends StatelessWidget {
  final ProductModel product;
  final int level;
  final int? selectedPrice;
  final ValueChanged<int> onPriceSelected;
  final List<int> priceOptions;

  const PriceSelector({
    super.key,
    required this.product,
    required this.level,
    required this.selectedPrice,
    required this.onPriceSelected,
    required this.priceOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('値段を決めよう！', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          '仕入れ値: ${AppFormatters.yen(product.costPrice)}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: priceOptions.map((price) {
            final profit = price - product.costPrice;
            final margin = product.marginAt(price);
            final isSelected = selectedPrice == price;
            return Expanded(
              child: GestureDetector(
                onTap: () => onPriceSelected(price),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(10),
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
                      Text(
                        AppFormatters.yen(price),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '利益 ${AppFormatters.yen(profit)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: profit > 0 ? AppColors.profit : AppColors.loss,
                        ),
                      ),
                      if (level >= 3)
                        Text(
                          AppFormatters.percent(margin),
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
