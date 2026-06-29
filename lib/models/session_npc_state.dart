import 'package:cloud_firestore/cloud_firestore.dart';

/// セッション中の NPC 単一購入記録
class PurchaseRecord {
  final String productId;
  final String productName;
  final int sellingPrice;
  final int costPrice;
  final bool bought;
  final DateTime timestamp;

  const PurchaseRecord({
    required this.productId,
    required this.productName,
    required this.sellingPrice,
    required this.costPrice,
    required this.bought,
    required this.timestamp,
  });

  int get profit => bought ? (sellingPrice - costPrice) : 0;

  /// 価格が「ぼったくり」かどうか（仕入れ値の2倍超）
  bool get wasOverpriced => sellingPrice > costPrice * 2;

  /// 価格が「良心的」かどうか（仕入れ値の1.5倍以下）
  bool get wasFairPrice => sellingPrice <= (costPrice * 1.5).round();

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'sellingPrice': sellingPrice,
    'costPrice': costPrice,
    'bought': bought,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory PurchaseRecord.fromMap(Map<String, dynamic> map) => PurchaseRecord(
    productId: map['productId'] as String? ?? '',
    productName: map['productName'] as String? ?? '',
    sellingPrice: map['sellingPrice'] as int? ?? 0,
    costPrice: map['costPrice'] as int? ?? 0,
    bought: map['bought'] as bool? ?? false,
    timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

/// ゲームセッション中の NPC 動的状態（メモリ管理 + Firestore 永続化）
/// NpcModel は const 不変だが、セッション間でこの状態が変化する
class SessionNpcState {
  final String npcId;
  final String name;
  final String emoji;

  /// 累積好感度スコア (0–100)。70 以上で isRegular = true
  final int favoriteScore;

  /// この日の購入履歴（セッション終了時に Firestore へ保存）
  final List<PurchaseRecord> dailyHistory;

  /// 常連フラグ
  final bool isRegular;

  /// 今日友達を連れてくるか（セッション開始時に決定）
  final bool isBringingFriend;

  const SessionNpcState({
    required this.npcId,
    required this.name,
    required this.emoji,
    required this.favoriteScore,
    this.dailyHistory = const [],
    this.isRegular = false,
    this.isBringingFriend = false,
  });

  /// 今セッションで新たに常連になったか
  bool get justBecameRegular => favoriteScore >= 70 && !isRegular;

  /// 直近 N 回の購入で連続ぼったくりがあったか
  bool get hadConsecutiveOverprice {
    if (dailyHistory.length < 2) return false;
    final recent = dailyHistory.reversed.take(2).toList();
    return recent.every((r) => r.wasOverpriced);
  }

  SessionNpcState copyWith({
    int? favoriteScore,
    List<PurchaseRecord>? dailyHistory,
    bool? isRegular,
    bool? isBringingFriend,
  }) =>
      SessionNpcState(
        npcId: npcId,
        name: name,
        emoji: emoji,
        favoriteScore: favoriteScore ?? this.favoriteScore,
        dailyHistory: dailyHistory ?? this.dailyHistory,
        isRegular: isRegular ?? this.isRegular,
        isBringingFriend: isBringingFriend ?? this.isBringingFriend,
      );

  /// Firestore npcStates/{childUid}/npcs/{npcId} に保存するマップ
  Map<String, dynamic> toFirestore() => {
    'npcId': npcId,
    'name': name,
    'emoji': emoji,
    'favoriteScore': favoriteScore,
    'isRegular': isRegular,
    'totalVisits': dailyHistory.length,
    'updatedAt': Timestamp.fromDate(DateTime.now()),
  };

  factory SessionNpcState.fromFirestore(
    String npcId,
    String name,
    String emoji,
    Map<String, dynamic> data,
  ) =>
      SessionNpcState(
        npcId: npcId,
        name: name,
        emoji: emoji,
        favoriteScore: data['favoriteScore'] as int? ?? 20,
        isRegular: data['isRegular'] as bool? ?? false,
      );

  /// 初回来店（好感度は 20 スタート）
  factory SessionNpcState.initial(String npcId, String name, String emoji) =>
      SessionNpcState(
        npcId: npcId,
        name: name,
        emoji: emoji,
        favoriteScore: 20,
      );
}
