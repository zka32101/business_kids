import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge.dart';
import '../services/badge_service.dart';
import '../services/firestore_service.dart';
import 'child_provider.dart';

final badgeServiceProvider = Provider((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return BadgeService(firestoreService.db);
});

final earnedBadgesProvider =
    FutureProvider.family<List<AchievementBadge>, String>((ref, childUid) async {
  final service = ref.watch(badgeServiceProvider);
  return service.getEarnedBadgeDetails(childUid);
});

final allBadgesProvider = FutureProvider((ref) async {
  final service = ref.watch(badgeServiceProvider);
  return service.getAllBadges();
});

final currentTitleProvider =
    FutureProvider.family<BadgeTitle?, String>((ref, childUid) async {
  final service = ref.watch(badgeServiceProvider);
  final equippedTitle = await service.getCurrentTitle(childUid);
  if (equippedTitle == null) return null;
  return service.getTitleById(equippedTitle.titleId);
});

final allTitlesProvider = FutureProvider<List<BadgeTitle>>((ref) async {
  final service = ref.watch(badgeServiceProvider);
  return service.getAllTitles();
});

final awardBadgeProvider =
    FutureProvider.family<void, ({String childUid, String badgeId})>(
        (ref, params) async {
  final service = ref.watch(badgeServiceProvider);
  await service.awardBadge(params.childUid, params.badgeId);
  ref.invalidate(earnedBadgesProvider);
});

final equipTitleProvider =
    FutureProvider.family<void, ({String childUid, String titleId})>(
        (ref, params) async {
  final service = ref.watch(badgeServiceProvider);
  await service.equipTitle(params.childUid, params.titleId);
  ref.invalidate(currentTitleProvider);
});

final checkAndAwardBadgesProvider =
    FutureProvider.family<void,
        ({
          String childUid,
          int? totalSales,
          int? regularCount,
          int? profitRate,
          int? masteredConcepts,
          int? coachCommentsRead,
          int? currentStreak,
        })>((ref, params) async {
  final service = ref.watch(badgeServiceProvider);
  await service.checkAndAwardBadges(
    params.childUid,
    totalSales: params.totalSales,
    regularCount: params.regularCount,
    profitRate: params.profitRate,
    masteredConcepts: params.masteredConcepts,
    coachCommentsRead: params.coachCommentsRead,
    currentStreak: params.currentStreak,
  );
  ref.invalidate(earnedBadgesProvider);
});
