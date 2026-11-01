class StudentProfile {
  final String id;
  String name;
  String level; // e.g., 1AP..3AS
  String? stream; // e.g., SE, MATH, ST_1AS
  int xp;
  int streakDays;
  String lastActiveDate;
  int dailyGoalMinutes;
  int todayStudiedMinutes;
  int solvedCount;
  List<double> scoreHistory;
  Map<String, int> subjectMinutes;
  Map<String, double> subjectWeaknessScore; // 0..100 (lower = weaker)
  List<String> badges;

  StudentProfile({
    required this.id,
    required this.name,
    required this.level,
    this.stream,
    this.xp = 120,
    this.streakDays = 7,
    required this.lastActiveDate,
    this.dailyGoalMinutes = 45,
    this.todayStudiedMinutes = 30,
    this.solvedCount = 12,
    List<double>? scoreHistory,
    Map<String, int>? subjectMinutes,
    Map<String, double>? subjectWeaknessScore,
    List<String>? badges,
  })  : scoreHistory = scoreHistory ?? [14.5, 16.0, 16.5],
        subjectMinutes = subjectMinutes ?? {'math': 45, 'arabic': 30, 'physics': 25},
        subjectWeaknessScore = subjectWeaknessScore ?? {'math': 62.0, 'physics': 58.0, 'arabic': 82.0},
        badges = badges ?? ['بداية موفقة 🌟', 'مثابر الأسبوع 🔥'];

  double get averagePercent {
    if (scoreHistory.isEmpty) return 82.0;
    final avg20 = scoreHistory.reduce((a, b) => a + b) / scoreHistory.length;
    return (avg20 / 20.0 * 100.0).clamp(0.0, 100.0);
  }

  int get playerLevel => (xp ~/ 100) + 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level,
        'stream': stream,
        'xp': xp,
        'streakDays': streakDays,
        'lastActiveDate': lastActiveDate,
        'dailyGoalMinutes': dailyGoalMinutes,
        'todayStudiedMinutes': todayStudiedMinutes,
        'solvedCount': solvedCount,
        'scoreHistory': scoreHistory,
        'subjectMinutes': subjectMinutes,
        'subjectWeaknessScore': subjectWeaknessScore,
        'badges': badges,
      };

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String? ?? 'default_1',
      name: json['name'] as String? ?? 'تلميذ مجتهد',
      level: json['level'] as String? ?? '3AM',
      stream: json['stream'] as String?,
      xp: json['xp'] as int? ?? 120,
      streakDays: json['streakDays'] as int? ?? 1,
      lastActiveDate: json['lastActiveDate'] as String? ?? '2026-01-01',
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 45,
      todayStudiedMinutes: json['todayStudiedMinutes'] as int? ?? 15,
      solvedCount: json['solvedCount'] as int? ?? 5,
      scoreHistory: (json['scoreHistory'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [15.0],
      subjectMinutes: (json['subjectMinutes'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      subjectWeaknessScore: (json['subjectWeaknessScore'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class WrongAnswerItem {
  final String question;
  final String chosenAnswer;
  final String correctAnswer;
  final String explanation;
  final String subject;
  final String date;

  WrongAnswerItem({
    required this.question,
    required this.chosenAnswer,
    required this.correctAnswer,
    required this.explanation,
    required this.subject,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'chosenAnswer': chosenAnswer,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'subject': subject,
        'date': date,
      };

  factory WrongAnswerItem.fromJson(Map<String, dynamic> json) => WrongAnswerItem(
        question: json['question'] as String? ?? '',
        chosenAnswer: json['chosenAnswer'] as String? ?? '',
        correctAnswer: json['correctAnswer'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        subject: json['subject'] as String? ?? 'math',
        date: json['date'] as String? ?? '',
      );
}
