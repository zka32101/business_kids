import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/challenge.dart';

class ChallengeService {
  final FirebaseFirestore _db;

  ChallengeService(this._db);

  static const List<Map<String, dynamic>> _dailyChallengeTemplates = [
    {
      'title': '本日の売上目標',
      'description': '本日の売上が¥50,000以上になるようにしよう！',
      'type': 'sales',
      'targetValue': 50000,
    },
    {
      'title': '常連客を増やそう',
      'description': '新しい常連客を3人以上作ろう！',
      'type': 'regulars',
      'targetValue': 3,
    },
    {
      'title': '在庫を効率的に',
      'description': '商品の在庫切れなしで1日を終える',
      'type': 'inventory',
      'targetValue': 1,
    },
    {
      'title': '利益を上げる',
      'description': '本日の利益が¥10,000以上になるようにしよう！',
      'type': 'profit',
      'targetValue': 10000,
    },
  ];

  Future<DailyChallenge> getTodaysChallenge(String childUid) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final doc = await _db
        .collection('children')
        .doc(childUid)
        .collection('dailyChallenges')
        .doc(dateStr)
        .get();

    if (doc.exists) {
      return DailyChallenge.fromMap(doc.data()!);
    }

    return _generateDailyChallenge(childUid, today);
  }

  Future<DailyChallenge> _generateDailyChallenge(
      String childUid, DateTime date) async {
    final templates = _dailyChallengeTemplates;
    final dayOfWeek = date.weekday; // 1 = Monday, 7 = Sunday
    final template = templates[dayOfWeek % templates.length];

    final challenge = DailyChallenge(
      id: const Uuid().v4(),
      childUid: childUid,
      date: date,
      title: template['title'] as String,
      description: template['description'] as String,
      type: template['type'] as String,
      targetValue: template['targetValue'] as int,
      currentValue: 0,
      completed: false,
      createdAt: DateTime.now(),
    );

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await _db
        .collection('children')
        .doc(childUid)
        .collection('dailyChallenges')
        .doc(dateStr)
        .set(challenge.toMap());

    return challenge;
  }

  Future<WeeklyChallenge?> getCurrentWeekChallenge(String childUid) async {
    final now = DateTime.now();
    final weekNumber = _getWeekNumber(now);
    final year = now.year;

    final query = await _db
        .collection('children')
        .doc(childUid)
        .collection('weeklyChallenges')
        .where('weekNumber', isEqualTo: weekNumber)
        .where('year', isEqualTo: year)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return WeeklyChallenge.fromMap(query.docs.first.data());
    }

    return _generateWeeklyChallenge(childUid, weekNumber, year);
  }

  Future<WeeklyChallenge> _generateWeeklyChallenge(
      String childUid, int weekNumber, int year) async {
    final templates = [
      {
        'title': '週間売上目標',
        'description': 'この1週間で¥300,000以上の売上を達成しよう！',
        'type': 'sales',
        'targetValue': 300000,
      },
      {
        'title': '常連客ネットワーク',
        'description': '常連客を10人以上作ろう！',
        'type': 'regulars',
        'targetValue': 10,
      },
      {
        'title': '5日連続プレイ',
        'description': 'この週で5日以上ゲームをプレイしよう！',
        'type': 'streak',
        'targetValue': 5,
      },
      {
        'title': '安定経営',
        'description': '毎日プレイして利益率30%以上を保ちましょう',
        'type': 'profit',
        'targetValue': 30,
      },
    ];

    final template = templates[weekNumber % templates.length];

    final challenge = WeeklyChallenge(
      id: const Uuid().v4(),
      childUid: childUid,
      weekNumber: weekNumber,
      year: year,
      title: template['title'] as String,
      description: template['description'] as String,
      type: template['type'] as String,
      targetValue: template['targetValue'] as int,
      currentValue: 0,
      completed: false,
      createdAt: DateTime.now(),
    );

    await _db
        .collection('children')
        .doc(childUid)
        .collection('weeklyChallenges')
        .doc(challenge.id)
        .set(challenge.toMap());

    return challenge;
  }

  Future<void> updateDailyChallengeProgress(
    String childUid,
    DateTime date,
    String type,
    int value,
  ) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final doc = await _db
        .collection('children')
        .doc(childUid)
        .collection('dailyChallenges')
        .doc(dateStr)
        .get();

    if (!doc.exists) {
      return;
    }

    final challenge = DailyChallenge.fromMap(doc.data()!);

    if (challenge.type == type) {
      int newValue = challenge.currentValue + value;
      bool completed = newValue >= challenge.targetValue;

      await _db
          .collection('children')
          .doc(childUid)
          .collection('dailyChallenges')
          .doc(dateStr)
          .update({
        'currentValue': newValue,
        'completed': completed,
        'completedAt': completed ? DateTime.now().toIso8601String() : null,
      });
    }
  }

  Future<void> updateWeeklyChallengeProgress(
    String childUid,
    String challengeId,
    int value,
  ) async {
    final doc = await _db
        .collection('children')
        .doc(childUid)
        .collection('weeklyChallenges')
        .doc(challengeId)
        .get();

    if (!doc.exists) {
      return;
    }

    final challenge = WeeklyChallenge.fromMap(doc.data()!);
    int newValue = challenge.currentValue + value;
    bool completed = newValue >= challenge.targetValue;

    await _db
        .collection('children')
        .doc(childUid)
        .collection('weeklyChallenges')
        .doc(challengeId)
        .update({
      'currentValue': newValue,
      'completed': completed,
      'completedAt': completed ? DateTime.now().toIso8601String() : null,
    });
  }

  int _getWeekNumber(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final dayOfJan4 = jan4.weekday;
    final weekOneMonday = jan4.subtract(Duration(days: dayOfJan4 - 1));
    final weekNumber = ((date.difference(weekOneMonday).inDays) / 7).ceil();
    return weekNumber;
  }
}
