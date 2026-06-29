import 'package:cloud_firestore/cloud_firestore.dart';

enum StoreLevel { small, medium, full }

class ChildModel {
  final String uid;
  final String parentUid;
  final String name;
  final String avatarId;
  final int currentLevel;
  final int totalProfit;
  final int totalRevenue;
  final int consecutiveDays;
  final DateTime createdAt;
  final DateTime? lastPlayedAt;
  final StoreLevel storeLevel;
  final bool hasPremium;
  final String planType; // 'free' | 'subscription' | 'lifetime'

  const ChildModel({
    required this.uid,
    required this.parentUid,
    required this.name,
    required this.avatarId,
    required this.currentLevel,
    required this.totalProfit,
    required this.totalRevenue,
    required this.consecutiveDays,
    required this.createdAt,
    this.lastPlayedAt,
    required this.storeLevel,
    required this.hasPremium,
    required this.planType,
  });

  int get trialDaysElapsed =>
      DateTime.now().difference(createdAt).inDays;

  bool get isTrialExpired => !hasPremium && trialDaysElapsed >= 7;

  bool get shouldShowBankruptcy => isTrialExpired;

  factory ChildModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildModel(
      uid: doc.id,
      parentUid: data['parentUid'] as String? ?? '',
      name: data['name'] as String? ?? 'こども',
      avatarId: data['avatarId'] as String? ?? 'avatar_01',
      currentLevel: data['currentLevel'] as int? ?? 1,
      totalProfit: data['totalProfit'] as int? ?? 0,
      totalRevenue: data['totalRevenue'] as int? ?? 0,
      consecutiveDays: data['consecutiveDays'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate(),
      storeLevel: StoreLevel.values.firstWhere(
        (e) => e.name == (data['storeLevel'] as String? ?? 'small'),
        orElse: () => StoreLevel.small,
      ),
      hasPremium: data['hasPremium'] as bool? ?? false,
      planType: data['planType'] as String? ?? 'free',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'parentUid': parentUid,
    'name': name,
    'avatarId': avatarId,
    'currentLevel': currentLevel,
    'totalProfit': totalProfit,
    'totalRevenue': totalRevenue,
    'consecutiveDays': consecutiveDays,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastPlayedAt': lastPlayedAt != null ? Timestamp.fromDate(lastPlayedAt!) : null,
    'storeLevel': storeLevel.name,
    'hasPremium': hasPremium,
    'planType': planType,
  };

  ChildModel copyWith({
    String? name,
    String? avatarId,
    int? currentLevel,
    int? totalProfit,
    int? totalRevenue,
    int? consecutiveDays,
    DateTime? lastPlayedAt,
    StoreLevel? storeLevel,
    bool? hasPremium,
    String? planType,
  }) => ChildModel(
    uid: uid,
    parentUid: parentUid,
    name: name ?? this.name,
    avatarId: avatarId ?? this.avatarId,
    currentLevel: currentLevel ?? this.currentLevel,
    totalProfit: totalProfit ?? this.totalProfit,
    totalRevenue: totalRevenue ?? this.totalRevenue,
    consecutiveDays: consecutiveDays ?? this.consecutiveDays,
    createdAt: createdAt,
    lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    storeLevel: storeLevel ?? this.storeLevel,
    hasPremium: hasPremium ?? this.hasPremium,
    planType: planType ?? this.planType,
  );
}
