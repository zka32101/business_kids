class DailyChallenge {
  final String id;
  final String childUid;
  final DateTime date;
  final String title;
  final String description;
  final String type; // 'sales', 'regulars', 'inventory', 'profit'
  final int targetValue;
  final int currentValue;
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;

  const DailyChallenge({
    required this.id,
    required this.childUid,
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.completed,
    required this.createdAt,
    this.completedAt,
  });

  DailyChallenge copyWith({
    String? id,
    String? childUid,
    DateTime? date,
    String? title,
    String? description,
    String? type,
    int? targetValue,
    int? currentValue,
    bool? completed,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      childUid: childUid ?? this.childUid,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childUid': childUid,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'type': type,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      id: map['id'] as String,
      childUid: map['childUid'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      targetValue: map['targetValue'] as int,
      currentValue: map['currentValue'] as int? ?? 0,
      completed: map['completed'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }
}

class WeeklyChallenge {
  final String id;
  final String childUid;
  final int weekNumber;
  final int year;
  final String title;
  final String description;
  final String type;
  final int targetValue;
  final int currentValue;
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;

  const WeeklyChallenge({
    required this.id,
    required this.childUid,
    required this.weekNumber,
    required this.year,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.completed,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childUid': childUid,
      'weekNumber': weekNumber,
      'year': year,
      'title': title,
      'description': description,
      'type': type,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory WeeklyChallenge.fromMap(Map<String, dynamic> map) {
    return WeeklyChallenge(
      id: map['id'] as String,
      childUid: map['childUid'] as String,
      weekNumber: map['weekNumber'] as int,
      year: map['year'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      targetValue: map['targetValue'] as int,
      currentValue: map['currentValue'] as int? ?? 0,
      completed: map['completed'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }
}
