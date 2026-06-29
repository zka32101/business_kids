import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../services/firestore_service.dart';
import 'child_provider.dart';

final challengeServiceProvider = Provider((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ChallengeService(firestoreService.db);
});

final dailyChallengeProvider =
    FutureProvider.family<DailyChallenge, String>((ref, childUid) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getTodaysChallenge(childUid);
});

final weeklyChallengeProvider =
    FutureProvider.family<WeeklyChallenge?, String>((ref, childUid) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getCurrentWeekChallenge(childUid);
});

final updateDailyChallengeProgressProvider = FutureProvider.family<void,
    ({
      String childUid,
      DateTime date,
      String type,
      int value,
    })>((ref, params) async {
  final service = ref.watch(challengeServiceProvider);
  await service.updateDailyChallengeProgress(
    params.childUid,
    params.date,
    params.type,
    params.value,
  );
  ref.invalidate(dailyChallengeProvider);
});

final updateWeeklyChallengeProgressProvider = FutureProvider.family<void,
    ({
      String childUid,
      String challengeId,
      int value,
    })>((ref, params) async {
  final service = ref.watch(challengeServiceProvider);
  await service.updateWeeklyChallengeProgress(
    params.childUid,
    params.challengeId,
    params.value,
  );
  ref.invalidate(weeklyChallengeProvider);
});
