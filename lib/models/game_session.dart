import 'package:cloud_firestore/cloud_firestore.dart';

class SaleRecord {
  final String productId;
  final String productName;
  final int costPrice;
  final int sellingPrice;
  final int quantity;
  final bool customerBought;
  final DateTime timestamp;

  // ★ 新規：NPC 追跡フィールド
  final String? customerNpcId;
  final int npcFavoriteScoreDelta;
  final bool npcBecameRegular;

  const SaleRecord({
    required this.productId,
    required this.productName,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.customerBought,
    required this.timestamp,
    this.customerNpcId,
    this.npcFavoriteScoreDelta = 0,
    this.npcBecameRegular = false,
  });

  int get revenue => customerBought ? sellingPrice * quantity : 0;
  int get profit => customerBought ? (sellingPrice - costPrice) * quantity : 0;

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'costPrice': costPrice,
    'sellingPrice': sellingPrice,
    'quantity': quantity,
    'customerBought': customerBought,
    'timestamp': Timestamp.fromDate(timestamp),
    'customerNpcId': customerNpcId,
    'npcFavoriteScoreDelta': npcFavoriteScoreDelta,
    'npcBecameRegular': npcBecameRegular,
  };

  factory SaleRecord.fromMap(Map<String, dynamic> map) => SaleRecord(
    productId: map['productId'] as String? ?? '',
    productName: map['productName'] as String? ?? '',
    costPrice: map['costPrice'] as int? ?? 0,
    sellingPrice: map['sellingPrice'] as int? ?? 0,
    quantity: map['quantity'] as int? ?? 1,
    customerBought: map['customerBought'] as bool? ?? false,
    timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    customerNpcId: map['customerNpcId'] as String?,
    npcFavoriteScoreDelta: map['npcFavoriteScoreDelta'] as int? ?? 0,
    npcBecameRegular: map['npcBecameRegular'] as bool? ?? false,
  );
}

class DailySummary {
  final int totalRevenue;
  final int totalProfit;
  final double averageProfitMargin;
  final int totalSalesCount;
  final int failedSales;

  const DailySummary({
    required this.totalRevenue,
    required this.totalProfit,
    required this.averageProfitMargin,
    required this.totalSalesCount,
    required this.failedSales,
  });

  factory DailySummary.fromSales(List<SaleRecord> sales) {
    final successfulSales = sales.where((s) => s.customerBought).toList();
    final totalRevenue = successfulSales.fold(0, (acc, s) => acc + s.revenue);
    final totalProfit = successfulSales.fold(0, (acc, s) => acc + s.profit);
    final failedSales = sales.where((s) => !s.customerBought).length;
    final avgMargin = totalRevenue > 0 ? totalProfit / totalRevenue : 0.0;

    return DailySummary(
      totalRevenue: totalRevenue,
      totalProfit: totalProfit,
      averageProfitMargin: avgMargin,
      totalSalesCount: successfulSales.length,
      failedSales: failedSales,
    );
  }
}

class GameSessionModel {
  final String? sessionId;
  final String childUid;
  final int level;
  final DateTime date;
  final List<SaleRecord> sales;
  final bool isCompleted;
  final String? topSellingProduct;
  final String? topProfitProduct;

  // ★ 新規：この日の常連客数
  final int totalRegularCount;

  // ★ 新規：AIコーチの因果解説コメント
  final String? coachCommentReasoning;

  const GameSessionModel({
    this.sessionId,
    required this.childUid,
    required this.level,
    required this.date,
    required this.sales,
    this.isCompleted = false,
    this.topSellingProduct,
    this.topProfitProduct,
    this.totalRegularCount = 0,
    this.coachCommentReasoning,
  });

  DailySummary get dailySummary => DailySummary.fromSales(sales);

  GameSessionModel addSale(SaleRecord sale) => GameSessionModel(
    sessionId: sessionId,
    childUid: childUid,
    level: level,
    date: date,
    sales: [...sales, sale],
    isCompleted: isCompleted,
    topSellingProduct: topSellingProduct,
    topProfitProduct: topProfitProduct,
    totalRegularCount: totalRegularCount + (sale.npcBecameRegular ? 1 : 0),
    coachCommentReasoning: coachCommentReasoning,
  );

  Map<String, dynamic> toFirestore() => {
    'childUid': childUid,
    'level': level,
    'date': Timestamp.fromDate(date),
    'sales': sales.map((s) => s.toMap()).toList(),
    'isCompleted': isCompleted,
    'topSellingProduct': topSellingProduct,
    'topProfitProduct': topProfitProduct,
    'totalRevenue': dailySummary.totalRevenue,
    'totalProfit': dailySummary.totalProfit,
    'totalRegularCount': totalRegularCount,
    'coachCommentReasoning': coachCommentReasoning,
  };

  factory GameSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final salesList = data['sales'] as List? ?? [];
    return GameSessionModel(
      sessionId: doc.id,
      childUid: data['childUid'] as String? ?? '',
      level: data['level'] as int? ?? 1,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sales: salesList
          .map((s) => SaleRecord.fromMap(s as Map<String, dynamic>))
          .toList(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      topSellingProduct: data['topSellingProduct'] as String?,
      topProfitProduct: data['topProfitProduct'] as String?,
      totalRegularCount: data['totalRegularCount'] as int? ?? 0,
      coachCommentReasoning: data['coachCommentReasoning'] as String?,
    );
  }
}
