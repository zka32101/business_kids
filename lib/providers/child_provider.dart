import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final selectedChildUidProvider = StateProvider<String?>((ref) => null);

final childProvider = StreamProvider.family<ChildModel?, String>((ref, childUid) {
  return ref.watch(firestoreServiceProvider).watchChild(childUid);
});

final currentChildProvider = Provider<AsyncValue<ChildModel?>>((ref) {
  final childUid = ref.watch(selectedChildUidProvider);
  if (childUid == null) return const AsyncValue.data(null);
  return ref.watch(childProvider(childUid));
});

final childListProvider = FutureProvider.family<List<ChildModel>, String>((ref, parentUid) {
  return ref.read(firestoreServiceProvider).getChildrenForParent(parentUid);
});

class ChildNotifier extends StateNotifier<AsyncValue<ChildModel?>> {
  final FirestoreService _service;
  final Ref _ref;

  ChildNotifier(this._service, this._ref) : super(const AsyncValue.loading());

  Future<void> createChild(String parentUid, String name, int level) async {
    state = const AsyncValue.loading();
    try {
      final child = await _service.createChild(ChildModel(
        uid: '',
        parentUid: parentUid,
        name: name,
        avatarId: 'avatar_01',
        currentLevel: level,
        totalProfit: 0,
        totalRevenue: 0,
        consecutiveDays: 0,
        createdAt: DateTime.now(),
        storeLevel: StoreLevel.small,
        hasPremium: false,
        planType: 'free',
      ));
      _ref.read(selectedChildUidProvider.notifier).state = child.uid;
      state = AsyncValue.data(child);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLevel(ChildModel child, int level) async {
    final updated = child.copyWith(currentLevel: level);
    await _service.updateChild(updated);
  }
}

final childNotifierProvider = StateNotifierProvider<ChildNotifier, AsyncValue<ChildModel?>>(
  (ref) => ChildNotifier(ref.read(firestoreServiceProvider), ref),
);
