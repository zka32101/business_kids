import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/badge.dart';

class BadgeService {
  final FirebaseFirestore _db;

  BadgeService(this._db);

  static const List<AchievementBadge> _masterBadges = [
    // 売上バッジ
    AchievementBadge(
      id: 'sales_100k',
      name: 'sales_100k',
      displayName: '商人の道',
      description: '売上 ¥100万達成',
      emoji: '🏆',
      category: 'sales',
      condition: 'sales >= 1000000',
      requiredValue: 1000000,
    ),
    AchievementBadge(
      id: 'sales_500k',
      name: 'sales_500k',
      displayName: '一人前の商人',
      description: '売上 ¥500万達成',
      emoji: '⭐',
      category: 'sales',
      condition: 'sales >= 5000000',
      requiredValue: 5000000,
    ),
    AchievementBadge(
      id: 'sales_1m',
      name: 'sales_1m',
      displayName: '商売人の鑑',
      description: '売上 ¥1000万達成',
      emoji: '💎',
      category: 'sales',
      condition: 'sales >= 10000000',
      requiredValue: 10000000,
    ),
    // 常連客バッジ
    AchievementBadge(
      id: 'regulars_5',
      name: 'regulars_5',
      displayName: '信頼の第一歩',
      description: '常連客を5人作成',
      emoji: '👥',
      category: 'regulars',
      condition: 'regulars >= 5',
      requiredValue: 5,
    ),
    AchievementBadge(
      id: 'regulars_10',
      name: 'regulars_10',
      displayName: '信頼の絆',
      description: '常連客を10人作成',
      emoji: '🤝',
      category: 'regulars',
      condition: 'regulars >= 10',
      requiredValue: 10,
    ),
    AchievementBadge(
      id: 'regulars_20',
      name: 'regulars_20',
      displayName: 'コミュニティの王',
      description: '常連客を20人作成',
      emoji: '👑',
      category: 'regulars',
      condition: 'regulars >= 20',
      requiredValue: 20,
    ),
    // 利益バッジ
    AchievementBadge(
      id: 'profit_30',
      name: 'profit_30',
      displayName: '完璧な経営',
      description: '利益率30%達成',
      emoji: '📈',
      category: 'profit',
      condition: 'profitRate >= 30',
      requiredValue: 30,
    ),
    AchievementBadge(
      id: 'profit_50',
      name: 'profit_50',
      displayName: '経営のプロ',
      description: '利益率50%達成',
      emoji: '🎯',
      category: 'profit',
      condition: 'profitRate >= 50',
      requiredValue: 50,
    ),
    // 学習バッジ
    AchievementBadge(
      id: 'learning_allconcepts',
      name: 'learning_allconcepts',
      displayName: '学習マスター',
      description: '9つの概念をすべてマスター',
      emoji: '🎓',
      category: 'learning',
      condition: 'masteredConcepts >= 9',
      requiredValue: 9,
    ),
    AchievementBadge(
      id: 'learning_ai_coach',
      name: 'learning_ai_coach',
      displayName: 'AIコーチの生徒',
      description: 'AI解説を20回読む',
      emoji: '🤖',
      category: 'learning',
      condition: 'coachCommentsRead >= 20',
      requiredValue: 20,
    ),
    // ストリークバッジ
    AchievementBadge(
      id: 'streak_3days',
      name: 'streak_3days',
      displayName: '継続は力なり',
      description: '3日連続プレイ',
      emoji: '🔥',
      category: 'learning',
      condition: 'streak >= 3',
      requiredValue: 3,
    ),
    AchievementBadge(
      id: 'streak_7days',
      name: 'streak_7days',
      displayName: '習慣の達人',
      description: '7日連続プレイ',
      emoji: '🔥🔥',
      category: 'learning',
      condition: 'streak >= 7',
      requiredValue: 7,
    ),
    AchievementBadge(
      id: 'streak_30days',
      name: 'streak_30days',
      displayName: 'レジェンド',
      description: '30日連続プレイ',
      emoji: '👑',
      category: 'learning',
      condition: 'streak >= 30',
      requiredValue: 30,
    ),
  ];

  static const List<BadgeTitle> _masterTitles = [
    BadgeTitle(
      id: 'title_beginner',
      displayName: '新米店長',
      description: '駆け出しの店長',
      rankLevel: 1,
    ),
    BadgeTitle(
      id: 'title_novice',
      displayName: '一人前の店長',
      description: 'ビジネスの基礎を学んだ',
      rankLevel: 2,
    ),
    BadgeTitle(
      id: 'title_expert',
      displayName: '経営のプロ',
      description: '高い利益率を保つ',
      rankLevel: 3,
    ),
    BadgeTitle(
      id: 'title_legend',
      displayName: 'カリスマ店長',
      description: '多くの常連客を持つ',
      rankLevel: 4,
    ),
  ];

  Future<List<EarnedBadge>> getEarnedBadges(String childUid) async {
    final query = await _db
        .collection('children')
        .doc(childUid)
        .collection('badges')
        .get();

    return query.docs.map((doc) => EarnedBadge.fromMap(doc.data())).toList();
  }

  Future<List<AchievementBadge>> getEarnedBadgeDetails(String childUid) async {
    final earnedDocs = await _db
        .collection('children')
        .doc(childUid)
        .collection('badges')
        .get();

    final earnedIds =
        earnedDocs.docs.map((doc) => doc.data()['badgeId'] as String).toSet();

    return _masterBadges.where((badge) => earnedIds.contains(badge.id)).toList();
  }

  Future<void> awardBadge(String childUid, String badgeId) async {
    final badge = _masterBadges.firstWhere(
      (b) => b.id == badgeId,
      orElse: () => throw Exception('Badge not found: $badgeId'),
    );

    await _db
        .collection('children')
        .doc(childUid)
        .collection('badges')
        .doc(badgeId)
        .set(EarnedBadge(
          badgeId: badgeId,
          childUid: childUid,
          earnedAt: DateTime.now(),
        ).toMap());
  }

  Future<bool> hasBadge(String childUid, String badgeId) async {
    final doc = await _db
        .collection('children')
        .doc(childUid)
        .collection('badges')
        .doc(badgeId)
        .get();

    return doc.exists;
  }

  Future<void> checkAndAwardBadges(
    String childUid, {
    int? totalSales,
    int? regularCount,
    int? profitRate,
    int? masteredConcepts,
    int? coachCommentsRead,
    int? currentStreak,
  }) async {
    for (final badge in _masterBadges) {
      if (await hasBadge(childUid, badge.id)) {
        continue; // Skip if already earned
      }

      bool shouldAward = false;

      if (badge.id == 'sales_100k' && totalSales != null) {
        shouldAward = totalSales >= 1000000;
      } else if (badge.id == 'sales_500k' && totalSales != null) {
        shouldAward = totalSales >= 5000000;
      } else if (badge.id == 'sales_1m' && totalSales != null) {
        shouldAward = totalSales >= 10000000;
      } else if (badge.id == 'regulars_5' && regularCount != null) {
        shouldAward = regularCount >= 5;
      } else if (badge.id == 'regulars_10' && regularCount != null) {
        shouldAward = regularCount >= 10;
      } else if (badge.id == 'regulars_20' && regularCount != null) {
        shouldAward = regularCount >= 20;
      } else if (badge.id == 'profit_30' && profitRate != null) {
        shouldAward = profitRate >= 30;
      } else if (badge.id == 'profit_50' && profitRate != null) {
        shouldAward = profitRate >= 50;
      } else if (badge.id == 'learning_allconcepts' && masteredConcepts != null) {
        shouldAward = masteredConcepts >= 9;
      } else if (badge.id == 'learning_ai_coach' && coachCommentsRead != null) {
        shouldAward = coachCommentsRead >= 20;
      } else if (badge.id == 'streak_3days' && currentStreak != null) {
        shouldAward = currentStreak >= 3;
      } else if (badge.id == 'streak_7days' && currentStreak != null) {
        shouldAward = currentStreak >= 7;
      } else if (badge.id == 'streak_30days' && currentStreak != null) {
        shouldAward = currentStreak >= 30;
      }

      if (shouldAward) {
        await awardBadge(childUid, badge.id);
      }
    }
  }

  Future<EquippedTitle?> getCurrentTitle(String childUid) async {
    final query = await _db
        .collection('children')
        .doc(childUid)
        .collection('titles')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return EquippedTitle.fromMap(query.docs.first.data());
    }
    return null;
  }

  Future<void> equipTitle(String childUid, String titleId) async {
    final existingTitle = await getCurrentTitle(childUid);

    if (existingTitle != null) {
      await _db
          .collection('children')
          .doc(childUid)
          .collection('titles')
          .doc(existingTitle.titleId)
          .delete();
    }

    await _db
        .collection('children')
        .doc(childUid)
        .collection('titles')
        .doc(titleId)
        .set(EquippedTitle(
          titleId: titleId,
          childUid: childUid,
          equippedAt: DateTime.now(),
        ).toMap());
  }

  BadgeTitle? getTitleById(String titleId) {
    try {
      return _masterTitles.firstWhere((t) => t.id == titleId);
    } catch (_) {
      return null;
    }
  }

  List<BadgeTitle> getAllTitles() => List.from(_masterTitles);

  AchievementBadge? getBadgeById(String badgeId) {
    try {
      return _masterBadges.firstWhere((b) => b.id == badgeId);
    } catch (_) {
      return null;
    }
  }

  List<AchievementBadge> getAllBadges() => List.from(_masterBadges);
}
