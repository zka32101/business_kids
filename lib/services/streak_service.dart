import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/streak.dart';

class StreakService {
  final FirebaseFirestore _db;

  StreakService(this._db);

  Future<StreakRecord> getStreakRecord(String childUid) async {
    final doc = await _db
        .collection('children')
        .doc(childUid)
        .collection('streaks')
        .doc('current')
        .get();

    if (doc.exists) {
      return StreakRecord.fromMap(doc.data()!);
    }

    final newStreak = StreakRecord(
      childUid: childUid,
      currentStreak: 0,
      longestStreak: 0,
      lastPlayDate: DateTime.now(),
      streakStartDate: null,
      totalCoinsEarned: 0,
    );

    await _db
        .collection('children')
        .doc(childUid)
        .collection('streaks')
        .doc('current')
        .set(newStreak.toMap());

    return newStreak;
  }

  Future<StreakRecord> updateStreakOnGamePlay(String childUid) async {
    final currentStreak = await getStreakRecord(childUid);
    final now = DateTime.now();
    final lastPlay = currentStreak.lastPlayDate;

    // Check if it's a new day
    final isDifferentDay = lastPlay.year != now.year ||
        lastPlay.month != now.month ||
        lastPlay.day != now.day;

    int newCurrentStreak = currentStreak.currentStreak;
    DateTime? streakStart = currentStreak.streakStartDate;
    int earnedCoins = 0;

    if (!isDifferentDay) {
      // Same day, no streak update
      return currentStreak;
    }

    // Check if streak continues (played yesterday)
    final yesterday = now.subtract(Duration(days: 1));
    final isConsecutive = lastPlay.year == yesterday.year &&
        lastPlay.month == yesterday.month &&
        lastPlay.day == yesterday.day;

    if (isConsecutive) {
      // Continue streak
      newCurrentStreak = currentStreak.currentStreak + 1;
      streakStart = currentStreak.streakStartDate ?? lastPlay;

      // Award coins based on streak
      earnedCoins = 100 * newCurrentStreak;
    } else {
      // Streak broken, reset to 1
      newCurrentStreak = 1;
      streakStart = now;
      earnedCoins = 100;
    }

    // Update longest streak if needed
    final newLongestStreak =
        (newCurrentStreak > currentStreak.longestStreak)
            ? newCurrentStreak
            : currentStreak.longestStreak;

    final updatedStreak = currentStreak.copyWith(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastPlayDate: now,
      streakStartDate: streakStart,
      totalCoinsEarned: currentStreak.totalCoinsEarned + earnedCoins,
    );

    await _db
        .collection('children')
        .doc(childUid)
        .collection('streaks')
        .doc('current')
        .update(updatedStreak.toMap());

    return updatedStreak;
  }

  Future<void> resetStreakIfNeeded(String childUid) async {
    final currentStreak = await getStreakRecord(childUid);
    final now = DateTime.now();
    final lastPlay = currentStreak.lastPlayDate;

    // Check if 2+ days have passed
    final daysSinceLastPlay = now.difference(lastPlay).inDays;

    if (daysSinceLastPlay >= 2) {
      final resetStreak = currentStreak.copyWith(
        currentStreak: 0,
        streakStartDate: null,
      );

      await _db
          .collection('children')
          .doc(childUid)
          .collection('streaks')
          .doc('current')
          .update(resetStreak.toMap());
    }
  }

  Future<int> getStreakRewardCoins(int streak) async {
    final reward = StreakReward.getRewardForStreak(streak);
    return reward?.coins ?? 0;
  }
}
