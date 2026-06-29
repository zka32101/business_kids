import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String name;
  final String emoji;
  final int costPrice;
  final int defaultSellingPrice;
  final int minLevel;
  final String? imageAsset;
  final bool isEventProduct;

  const ProductModel({
    required this.productId,
    required this.name,
    required this.emoji,
    required this.costPrice,
    required this.defaultSellingPrice,
    required this.minLevel,
    this.imageAsset,
    this.isEventProduct = false,
  });

  int profitAt(int sellingPrice) => sellingPrice - costPrice;

  double marginAt(int sellingPrice) =>
      sellingPrice > 0 ? (sellingPrice - costPrice) / sellingPrice : 0;

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      productId: doc.id,
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '🛍️',
      costPrice: data['costPrice'] as int? ?? 0,
      defaultSellingPrice: data['defaultSellingPrice'] as int? ?? 0,
      minLevel: data['minLevel'] as int? ?? 1,
      imageAsset: data['imageAsset'] as String?,
      isEventProduct: data['isEventProduct'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'emoji': emoji,
    'costPrice': costPrice,
    'defaultSellingPrice': defaultSellingPrice,
    'minLevel': minLevel,
    'imageAsset': imageAsset,
    'isEventProduct': isEventProduct,
  };
}

class DefaultProducts {
  static const List<ProductModel> level1 = [
    ProductModel(
      productId: 'lemonade',
      name: 'レモネード',
      emoji: '🍋',
      costPrice: 50,
      defaultSellingPrice: 100,
      minLevel: 1,
    ),
  ];

  static const List<ProductModel> level2 = [
    ProductModel(
      productId: 'lemonade',
      name: 'レモネード',
      emoji: '🍋',
      costPrice: 50,
      defaultSellingPrice: 100,
      minLevel: 1,
    ),
    ProductModel(
      productId: 'onigiri',
      name: 'おにぎり',
      emoji: '🍙',
      costPrice: 80,
      defaultSellingPrice: 150,
      minLevel: 2,
    ),
    ProductModel(
      productId: 'coffee',
      name: 'コーヒー',
      emoji: '☕',
      costPrice: 60,
      defaultSellingPrice: 130,
      minLevel: 2,
    ),
  ];

  static const List<ProductModel> level3 = [
    ProductModel(
      productId: 'lemonade',
      name: 'レモネード',
      emoji: '🍋',
      costPrice: 50,
      defaultSellingPrice: 100,
      minLevel: 1,
    ),
    ProductModel(
      productId: 'onigiri',
      name: 'おにぎり',
      emoji: '🍙',
      costPrice: 80,
      defaultSellingPrice: 150,
      minLevel: 2,
    ),
    ProductModel(
      productId: 'coffee',
      name: 'コーヒー',
      emoji: '☕',
      costPrice: 60,
      defaultSellingPrice: 130,
      minLevel: 2,
    ),
    ProductModel(
      productId: 'bento',
      name: 'お弁当',
      emoji: '🍱',
      costPrice: 300,
      defaultSellingPrice: 550,
      minLevel: 3,
    ),
    ProductModel(
      productId: 'ice',
      name: 'アイス',
      emoji: '🍦',
      costPrice: 100,
      defaultSellingPrice: 200,
      minLevel: 3,
    ),
  ];
}
