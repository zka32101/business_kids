import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child.dart';
import '../models/game_session.dart';
import '../models/concept_mastery.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService() {
    _db.settings = const Settings(persistenceEnabled: true);
  }

  /// NpcStateService が直接使用するための公開アクセサ
  FirebaseFirestore get db => _db;

  // 笏笏 Child 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

  Future<ChildModel> createChild(ChildModel child) async {
    final ref = _db.collection(AppConstants.colChildren).doc();
    final newChild = ChildModel(
      uid: ref.id,
      parentUid: child.parentUid,
      name: child.name,
      avatarId: child.avatarId,
      currentLevel: child.currentLevel,
      totalProfit: 0,
      totalRevenue: 0,
      consecutiveDays: 0,
      createdAt: DateTime.now(),
      storeLevel: StoreLevel.small,
      hasPremium: false,
      planType: 'free',
    );
    await ref.set(newChild.toFirestore());
    return newChild;
  }

  Stream<ChildModel?> watchChild(String childUid) =>
      _db.collection(AppConstants.colChildren)
          .doc(childUid)
          .snapshots()
          .map((doc) => doc.exists ? ChildModel.fromFirestore(doc) : null);

  Future<ChildModel?> getChild(String childUid) async {
    final doc = await _db.collection(AppConstants.colChildren).doc(childUid).get();
    return doc.exists ? ChildModel.fromFirestore(doc) : null;
  }

  Future<List<ChildModel>> getChildrenForParent(String parentUid) async {
    final snap = await _db
        .collection(AppConstants.colChildren)
        .where('parentUid', isEqualTo: parentUid)
        .get();
    return snap.docs.map(ChildModel.fromFirestore).toList();
  }

  Future<void> updateChild(ChildModel child) =>
      _db.collection(AppConstants.colChildren)
          .doc(child.uid)
          .update(child.toFirestore());

  Future<void> updateChildProfit(String childUid, int deltaProfit, int deltaRevenue) =>
      _db.collection(AppConstants.colChildren).doc(childUid).update({
        'totalProfit': FieldValue.increment(deltaProfit),
        'totalRevenue': FieldValue.increment(deltaRevenue),
        'lastPlayedAt': Timestamp.now(),
      });

  // 笏笏 GameSession 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

  Future<GameSessionModel> saveGameSession(GameSessionModel session) async {
    final ref = _db.collection(AppConstants.colGameSessions).doc();
    await ref.set(session.toFirestore());
    return GameSessionModel(
      sessionId: ref.id,
      childUid: session.childUid,
      level: session.level,
      date: session.date,
      sales: session.sales,
      isCompleted: true,
      topSellingProduct: session.topSellingProduct,
      topProfitProduct: session.topProfitProduct,
      totalRegularCount: session.totalRegularCount,
      coachCommentReasoning: session.coachCommentReasoning,
    );
  }

  Stream<List<GameSessionModel>> watchRecentSessions(String childUid, {int limit = 7}) =>
      _db.collection(AppConstants.colGameSessions)
          .where('childUid', isEqualTo: childUid)
          .orderBy('date', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map(GameSessionModel.fromFirestore).toList());

  Future<List<GameSessionModel>> getSessionsForMonth(String childUid, DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final snap = await _db
        .collection(AppConstants.colGameSessions)
        .where('childUid', isEqualTo: childUid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .get();
    return snap.docs.map(GameSessionModel.fromFirestore).toList();
  }

  // 笏笏 ConceptMastery 笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏

  Stream<ConceptMasteryModel?> watchConceptMastery(String childUid) =>
      _db.collection(AppConstants.colConceptMasteries)
          .doc(childUid)
          .snapshots()
          .map((doc) => doc.exists ? ConceptMasteryModel.fromFirestore(doc) : null);

  Future<void> updateConceptMastery(ConceptMasteryModel mastery) =>
      _db.collection(AppConstants.colConceptMasteries)
          .doc(mastery.childUid)
          .set(mastery.toFirestore(), SetOptions(merge: true));
}
