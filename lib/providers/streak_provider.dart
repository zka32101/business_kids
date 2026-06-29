import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/streak.dart';
import '../services/streak_service.dart';
import '../services/firestore_service.dart';
import 'child_provider.dart';

final streakServiceProvider = Provider((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return StreakService(firestoreService.db);
});

final streakRecordProvider =
    FutureProvider.family<StreakRecord, String>((ref, childUid) async {
  final service = ref.watch(streakServiceProvider);
  return service.getStreakRecord(childUid);
});

final updateStreakOnGamePlayProvider =
    FutureProvider.family<StreakRecord, String>((ref, childUid) async {
  final service = ref.watch(streakServiceProvider);
  final updatedStreak = await service.updateStreakOnGamePlay(childUid);
  ref.invalidate(streakRecordProvider);
  return updatedStreak;
});

final resetStreakIfNeededProvider =
    FutureProvider.family<void, String>((ref, childUid) async {
  final service = ref.watch(streakServiceProvider);
  await service.resetStreakIfNeeded(childUid);
  ref.invalidate(streakRecordProvider);
});
