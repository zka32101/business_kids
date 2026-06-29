class AchievementBadge {
  final String id;
  final String name; // バッジの内部ID (e.g., 'merchant_1m', 'trust_10regulars')
  final String displayName; // 表示名 (e.g., '商人の道')
  final String description; // バッジの説明
  final String emoji; // 🏆
  final String category; // 'sales', 'regulars', 'profit', 'learning'
  final String condition; // 獲得条件
  final int? requiredValue; // 必要な値

  const AchievementBadge({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.emoji,
    required this.category,
    required this.condition,
    this.requiredValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'emoji': emoji,
      'category': category,
      'condition': condition,
      'requiredValue': requiredValue,
    };
  }

  factory AchievementBadge.fromMap(Map<String, dynamic> map) {
    return AchievementBadge(
      id: map['id'] as String,
      name: map['name'] as String,
      displayName: map['displayName'] as String,
      description: map['description'] as String,
      emoji: map['emoji'] as String,
      category: map['category'] as String,
      condition: map['condition'] as String,
      requiredValue: map['requiredValue'] as int?,
    );
  }
}

class EarnedBadge {
  final String badgeId;
  final String childUid;
  final DateTime earnedAt;
  final int? earnedValue; // 獲得時の値（例：売上 ¥100万）

  const EarnedBadge({
    required this.badgeId,
    required this.childUid,
    required this.earnedAt,
    this.earnedValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'badgeId': badgeId,
      'childUid': childUid,
      'earnedAt': earnedAt.toIso8601String(),
      'earnedValue': earnedValue,
    };
  }

  factory EarnedBadge.fromMap(Map<String, dynamic> map) {
    return EarnedBadge(
      badgeId: map['badgeId'] as String,
      childUid: map['childUid'] as String,
      earnedAt: DateTime.parse(map['earnedAt'] as String),
      earnedValue: map['earnedValue'] as int?,
    );
  }
}

class BadgeTitle {
  final String id;
  final String displayName; // 表示名（例：「新米店長」「カリスマ店長」）
  final String description;
  final String? badgeId; // どのバッジで解放されるか
  final int rankLevel; // レベル 1-4

  const BadgeTitle({
    required this.id,
    required this.displayName,
    required this.description,
    this.badgeId,
    required this.rankLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'description': description,
      'badgeId': badgeId,
      'rankLevel': rankLevel,
    };
  }

  factory BadgeTitle.fromMap(Map<String, dynamic> map) {
    return BadgeTitle(
      id: map['id'] as String,
      displayName: map['displayName'] as String,
      description: map['description'] as String,
      badgeId: map['badgeId'] as String?,
      rankLevel: map['rankLevel'] as int,
    );
  }
}

class EquippedTitle {
  final String titleId;
  final String childUid;
  final DateTime equippedAt;

  const EquippedTitle({
    required this.titleId,
    required this.childUid,
    required this.equippedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'titleId': titleId,
      'childUid': childUid,
      'equippedAt': equippedAt.toIso8601String(),
    };
  }

  factory EquippedTitle.fromMap(Map<String, dynamic> map) {
    return EquippedTitle(
      titleId: map['titleId'] as String,
      childUid: map['childUid'] as String,
      equippedAt: DateTime.parse(map['equippedAt'] as String),
    );
  }
}
