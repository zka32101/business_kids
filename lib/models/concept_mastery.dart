import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class ConceptMasteryModel {
  final String childUid;
  final Map<String, int> masteryScores;
  final DateTime updatedAt;

  const ConceptMasteryModel({
    required this.childUid,
    required this.masteryScores,
    required this.updatedAt,
  });

  static const List<String> allConcepts = [
    ConceptKeys.costPrice,
    ConceptKeys.profit,
    ConceptKeys.revenue,
    ConceptKeys.priceSet,
    ConceptKeys.inventory,
    ConceptKeys.tax,
    ConceptKeys.profitMargin,
    ConceptKeys.competition,
    ConceptKeys.trust,  // ★ 新規
  ];

  static const Map<String, String> conceptNames = {
    ConceptKeys.costPrice: '仕入れ値の理解',
    ConceptKeys.profit: '利益の計算',
    ConceptKeys.revenue: '売上の意味',
    ConceptKeys.priceSet: '値段設定',
    ConceptKeys.inventory: '在庫管理',
    ConceptKeys.tax: '税金の仕組み',
    ConceptKeys.profitMargin: '利益率',
    ConceptKeys.competition: '競争と市場',
    ConceptKeys.trust: '信用の力',  // ★ 新規
  };

  int scoreFor(String concept) => masteryScores[concept] ?? 0;

  bool isMastered(String concept) => scoreFor(concept) >= 80;

  double get overallProgress {
    if (masteryScores.isEmpty) return 0;
    final total = masteryScores.values.fold(0, (s, v) => s + v);
    return total / (allConcepts.length * 100);
  }

  List<String> get masteredConcepts =>
      allConcepts.where(isMastered).toList();

  factory ConceptMasteryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final scores = data['masteryScores'] as Map<String, dynamic>? ?? {};
    return ConceptMasteryModel(
      childUid: data['childUid'] as String? ?? '',
      masteryScores: scores.map((k, v) => MapEntry(k, (v as num).toInt())),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'childUid': childUid,
    'masteryScores': masteryScores,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  ConceptMasteryModel updateScore(String concept, int delta) {
    final newScores = Map<String, int>.from(masteryScores);
    newScores[concept] = ((newScores[concept] ?? 0) + delta).clamp(0, 100);
    return ConceptMasteryModel(
      childUid: childUid,
      masteryScores: newScores,
      updatedAt: DateTime.now(),
    );
  }
}
