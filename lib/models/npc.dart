import 'package:cloud_firestore/cloud_firestore.dart';

enum NpcType { manager, customer, event }

enum CustomerReaction { happy, neutral, disappointed }

class NpcModel {
  final String npcId;
  final String name;
  final String emoji;
  final NpcType type;
  final String greeting;
  final String? preferredProductId;
  final int? preferredMaxPrice;
  final String? occupation;
  final int minLevel;

  const NpcModel({
    required this.npcId,
    required this.name,
    required this.emoji,
    required this.type,
    required this.greeting,
    this.preferredProductId,
    this.preferredMaxPrice,
    this.occupation,
    this.minLevel = 1,
  });

  CustomerReaction reactionTo(int sellingPrice, int costPrice) {
    if (preferredMaxPrice != null && sellingPrice > preferredMaxPrice!) {
      return CustomerReaction.disappointed;
    }
    if (sellingPrice <= costPrice * 1.1) {
      return CustomerReaction.happy;
    }
    return CustomerReaction.neutral;
  }

  factory NpcModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NpcModel(
      npcId: doc.id,
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '👤',
      type: NpcType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'customer'),
        orElse: () => NpcType.customer,
      ),
      greeting: data['greeting'] as String? ?? 'こんにちは！',
      preferredProductId: data['preferredProductId'] as String?,
      preferredMaxPrice: data['preferredMaxPrice'] as int?,
      occupation: data['occupation'] as String?,
      minLevel: data['minLevel'] as int? ?? 1,
    );
  }
}

class DefaultNpcs {
  static const List<NpcModel> managers = [
    NpcModel(
      npcId: 'manager_taro',
      name: '店長タロウ',
      emoji: '👨',
      type: NpcType.manager,
      greeting: '今日はお客さんが多そうだね。高めの値段でいけるかも！',
    ),
    NpcModel(
      npcId: 'manager_miki',
      name: '店長ミキ',
      emoji: '👩',
      type: NpcType.manager,
      greeting: '今日は安めがいいかな。量で勝負しよう！',
    ),
    NpcModel(
      npcId: 'manager_kenta',
      name: '店長ケンタ',
      emoji: '👦',
      type: NpcType.manager,
      greeting: 'お客さんに喜んでもらえる値段を考えよう！',
    ),
    NpcModel(
      npcId: 'manager_hana',
      name: '店長ハナ',
      emoji: '👧',
      type: NpcType.manager,
      greeting: '今日は特別な商品を売ってみない？',
    ),
  ];

  static const List<NpcModel> customers = [
    NpcModel(
      npcId: 'customer_student',
      name: '学生さん',
      emoji: '🎒',
      type: NpcType.customer,
      greeting: 'レモネードください！',
      preferredMaxPrice: 120,
      occupation: '学生',
    ),
    NpcModel(
      npcId: 'customer_worker',
      name: 'サラリーマン',
      emoji: '💼',
      type: NpcType.customer,
      greeting: 'コーヒー1つ！',
      preferredMaxPrice: 150,
      occupation: '会社員',
    ),
    NpcModel(
      npcId: 'customer_grandma',
      name: 'おばあさん',
      emoji: '👵',
      type: NpcType.customer,
      greeting: 'おにぎり1つちょうだいね',
      preferredMaxPrice: 130,
      occupation: 'おばあさん',
    ),
    NpcModel(
      npcId: 'customer_family',
      name: '家族連れ',
      emoji: '👨‍👩‍👧',
      type: NpcType.customer,
      greeting: 'みんなの分をください！',
      preferredMaxPrice: 200,
      occupation: '家族',
    ),
    NpcModel(
      npcId: 'customer_athlete',
      name: 'スポーツ選手',
      emoji: '🏃',
      type: NpcType.customer,
      greeting: '飲み物ください！疲れた〜',
      preferredMaxPrice: 160,
      occupation: 'スポーツ選手',
    ),
  ];

  static const List<NpcModel> eventNpcs = [
    NpcModel(
      npcId: 'event_reporter',
      name: '新聞記者',
      emoji: '📰',
      type: NpcType.event,
      greeting: '今、話題の商品は？取材させてください！',
      minLevel: 3,
    ),
    NpcModel(
      npcId: 'event_rival',
      name: 'ライバル店主',
      emoji: '😤',
      type: NpcType.event,
      greeting: 'こっちはもっと安いぞ！負けないからな！',
      minLevel: 3,
    ),
    NpcModel(
      npcId: 'event_investor',
      name: '投資家',
      emoji: '💰',
      type: NpcType.event,
      greeting: '君の商売、資金援助しようか？',
      minLevel: 3,
    ),
  ];
}
