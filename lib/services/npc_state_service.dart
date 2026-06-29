import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_npc_state.dart';
import '../models/npc.dart';

/// NPC の好感度状態を Firestore に永続化・読み込みするサービス
/// コレクション: npcStates/{childUid}/npcs/{npcId}
class NpcStateService {
  final FirebaseFirestore _db;

  NpcStateService(this._db);

  CollectionReference<Map<String, dynamic>> _npcsCol(String childUid) =>
      _db.collection('npcStates').doc(childUid).collection('npcs');

  /// 子ども全 NPC の状態をロード（存在しない場合は初期値を返す）
  Future<Map<String, SessionNpcState>> loadNpcStates(
    String childUid,
    List<NpcModel> npcs,
  ) async {
    final snap = await _npcsCol(childUid).get();
    final saved = {for (final d in snap.docs) d.id: d.data()};

    return {
      for (final npc in npcs)
        npc.npcId: saved.containsKey(npc.npcId)
            ? SessionNpcState.fromFirestore(
                npc.npcId, npc.name, npc.emoji, saved[npc.npcId]!)
            : SessionNpcState.initial(npc.npcId, npc.name, npc.emoji),
    };
  }

  /// セッション終了後に全 NPC 状態を保存
  Future<void> saveNpcStates(
    String childUid,
    Map<String, SessionNpcState> states,
  ) async {
    final batch = _db.batch();
    for (final entry in states.entries) {
      final ref = _npcsCol(childUid).doc(entry.key);
      batch.set(ref, entry.value.toFirestore(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// 常連さんのリストを返す
  Future<List<SessionNpcState>> loadRegularCustomers(String childUid) async {
    final snap = await _npcsCol(childUid)
        .where('isRegular', isEqualTo: true)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return SessionNpcState.fromFirestore(
        d.id,
        data['name'] as String? ?? '',
        data['emoji'] as String? ?? '👤',
        data,
      );
    }).toList();
  }

  /// 特定 NPC の好感度をリセット（デバッグ用）
  Future<void> resetNpcState(String childUid, String npcId) async {
    await _npcsCol(childUid).doc(npcId).delete();
  }
}
