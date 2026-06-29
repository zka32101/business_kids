class StreakRecord {
  final String childUid;
  final int currentStreak; // 連続プレイ日数
  final int longestStreak; // 最長記録
  final DateTime lastPlayDate; // 最後にプレイした日
  final DateTime? streakStartDate; // ストリーク開始日
  final int totalCoinsEarned; // ストリークで獲得したコイン合計

  const StreakRecord({
    required this.childUid,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastPlayDate,
    this.streakStartDate,
    required this.totalCoinsEarned,
  });

  StreakRecord copyWith({
    String? childUid,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPlayDate,
    DateTime? streakStartDate,
    int? totalCoinsEarned,
  }) {
    return StreakRecord(
      childUid: childUid ?? this.childUid,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childUid': childUid,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastPlayDate': lastPlayDate.toIso8601String(),
      'streakStartDate': streakStartDate?.toIso8601String(),
      'totalCoinsEarned': totalCoinsEarned,
    };
  }

  factory StreakRecord.fromMap(Map<String, dynamic> map) {
    return StreakRecord(
      childUid: map['childUid'] as String,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastPlayDate: DateTime.parse(map['lastPlayDate'] as String),
      streakStartDate: map['streakStartDate'] != null
          ? DateTime.parse(map['streakStartDate'] as String)
          : null,
      totalCoinsEarned: map['totalCoinsEarned'] as int? ?? 0,
    );
  }
}

class StreakReward {
  final int days;
  final int coins;
  final String? badge; // バッジID（3日目、7日目、30日目）

  const StreakReward({
    required this.days,
    required this.coins,
    this.badge,
  });

  static const List<StreakReward> rewards = [
    StreakReward(days: 1, coins: 100),
    StreakReward(days: 3, coins: 300, badge: 'streak_3days'),
    StreakReward(days: 7, coins: 1000, badge: 'streak_7days'),
    StreakReward(days: 14, coins: 2500),
    StreakReward(days: 30, coins: 5000, badge: 'streak_30days'),
  ];

  static StreakReward? getRewardForStreak(int streak) {
    return rewards
        .where((r) => streak % r.days == 0 && streak >= r.days)
        .lastOrNull;
  }
}
