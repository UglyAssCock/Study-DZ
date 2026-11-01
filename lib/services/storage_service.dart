import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlgerianLevelInfo {
  final String code;
  final String cycle; // primaire, moyen, secondaire
  final String nameAr;
  final String nameFr;
  final String? finalExam; // 5eme, BEM, BAC

  const AlgerianLevelInfo({
    required this.code,
    required this.cycle,
    required this.nameAr,
    required this.nameFr,
    this.finalExam,
  });
}

class StreamInfo {
  final String code;
  final String nameAr;
  final String nameFr;
  final List<String> allowedLevels;

  const StreamInfo({
    required this.code,
    required this.nameAr,
    required this.nameFr,
    required this.allowedLevels,
  });
}

class SubjectInfo {
  final String id;
  final String nameAr;
  final String nameFr;
  final String emoji;
  final int colorHex;
  final int coeff;

  const SubjectInfo({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.emoji,
    required this.colorHex,
    required this.coeff,
  });
}

class StudentProfileData {
  String id;
  String name;
  String levelCode;
  String? streamCode;
  int xp;
  int streakDays;
  String lastStudyDate;
  int dailyGoalMinutes;
  int todayStudiedMinutes;
  Map<String, int> subjectMinutes;
  Map<String, List<int>> subjectQuizScores;
  List<String> completedLessonIds;
  List<String> bookmarkedIds;
  Map<String, String> personalNotes;
  List> wrongAnswers;
  List> examHistory;
  List> averageHistory;
  Map<String, int> flashcardBox; // id -> box (1..5)
  int createdMonth;
  int createdYear;

  StudentProfileData({
    required this.id,
    required this.name,
    required this.levelCode,
    this.streamCode,
    this.xp = 0,
    this.streakDays = 1,
    required this.lastStudyDate,
    this.dailyGoalMinutes = 30,
    this.todayStudiedMinutes = 0,
    Map<String, int>? subjectMinutes,
    Map<String, List<int>>? subjectQuizScores,
    List<String>? completedLessonIds,
    List<String>? bookmarkedIds,
    Map<String, String>? personalNotes,
    List>? wrongAnswers,
    List>? examHistory,
    List>? averageHistory,
    Map<String, int>? flashcardBox,
    int? createdMonth,
    int? createdYear,
  })  : subjectMinutes = subjectMinutes ?? {},
        subjectQuizScores = subjectQuizScores ?? {},
        completedLessonIds = completedLessonIds ?? [],
        bookmarkedIds = bookmarkedIds ?? [],
        personalNotes = personalNotes ?? {},
        wrongAnswers = wrongAnswers ?? [],
        examHistory = examHistory ?? [],
        averageHistory = averageHistory ?? [],
        flashcardBox = flashcardBox ?? {},
        createdMonth = createdMonth ?? DateTime.now().month,
        createdYear = createdYear ?? DateTime.now().year;

  int get levelNumber => (xp ~/ 100) + 1;

  double get overallProgressPercent {
    final completed = completedLessonIds.length * 8 + examHistory.length * 10;
    return min(100.0, max(12.0, completed.toDouble()));
  }

  double get overallAverageScore {
    if (subjectQuizScores.isEmpty) return 82.0;
    int total = 0;
    int count = 0;
    for (final list in subjectQuizScores.values) {
      for (final s in list) {
        total += s;
        count++;
      }
    }
    return count == 0 ? 82.0 : (total / count);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'levelCode': levelCode,
        'streamCode': streamCode,
        'xp': xp,
        'streakDays': streakDays,
        'lastStudyDate': lastStudyDate,
        'dailyGoalMinutes': dailyGoalMinutes,
        'todayStudiedMinutes': todayStudiedMinutes,
        'subjectMinutes': subjectMinutes,
        'subjectQuizScores': subjectQuizScores,
        'completedLessonIds': completedLessonIds,
        'bookmarkedIds': bookmarkedIds,
        'personalNotes': personalNotes,
        'wrongAnswers': wrongAnswers,
        'examHistory': examHistory,
        'averageHistory': averageHistory,
        'flashcardBox': flashcardBox,
        'createdMonth': createdMonth,
        'createdYear': createdYear,
      };

  factory StudentProfileData.fromJson(Map<String, dynamic> json) {
    final rawScores =
        (json['subjectQuizScores'] as Map<String, dynamic>?) ?? {};
    final parsedScores = <String, List<int>>{};
    rawScores.forEach((k, v) {
      if (v is List) {
        parsedScores[k] = v.map((e) => (e as num).toInt()).toList();
      }
    });

    final rawMins = (json['subjectMinutes'] as Map<String, dynamic>?) ?? {};
    final parsedMins = <String, int>{};
    rawMins.forEach((k, v) {
      parsedMins[k] = (v as num).toInt();
    });

    final rawNotes = (json['personalNotes'] as Map<String, dynamic>?) ?? {};
    final parsedNotes = <String, String>{};
    rawNotes.forEach((k, v) {
      parsedNotes[k] = v.toString();
    });

    final rawBoxes = (json['flashcardBox'] as Map<String, dynamic>?) ?? {};
    final parsedBoxes = <String, int>{};
    rawBoxes.forEach((k, v) {
      parsedBoxes[k] = (v as num).toInt();
    });

    return StudentProfileData(
      id: json['id']?.toString() ?? 'p1',
      name: json['name']?.toString() ?? 'تلميذ مجتهد',
      levelCode: json['levelCode']?.toString() ?? '3AM',
      streamCode: json['streamCode']?.toString(),
      xp: (json['xp'] as num?)?.toInt() ?? 120,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 1,
      lastStudyDate: json['lastStudyDate']?.toString() ??
          DateTime.now().toIso8601String().substring(0, 10),
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num?)?.toInt() ?? 30,
      todayStudiedMinutes:
          (json['todayStudiedMinutes'] as num?)?.toInt() ?? 0,
      subjectMinutes: parsedMins,
      subjectQuizScores: parsedScores,
      completedLessonIds: (json['completedLessonIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bookmarkedIds: (json['bookmarkedIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      personalNotes: parsedNotes,
      wrongAnswers: (json['wrongAnswers'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      examHistory: (json['examHistory'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      averageHistory: (json['averageHistory'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      flashcardBox: parsedBoxes,
      createdMonth: (json['createdMonth'] as num?)?.toInt() ?? 9,
      createdYear: (json['createdYear'] as num?)?.toInt() ?? 2026,
    );
  }
}

class StorageService extends ChangeNotifier {
  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  SharedPreferences? _prefs;
  bool isInitialized = false;

  // Settings
  String languageCode = 'ar';
  bool isDarkMode = false;
  double fontScale = 1.0;
  bool notificationsEnabled = true;
  String parentPin = '0000';
  String geminiApiKey = '';
  String? customExamDateIso;

  // Local Account (Optional)
  bool isGuest = true;
  String? accountName;
  String? accountEmail;

  // Profiles
  List<StudentProfileData> profiles = [];
  String? activeProfileId;

  // Loaded Content
  List> lessons = [];
  List> exams = [];
  List> quizzes = [];
  List> flashcards = [];
  List> calendarEvents = [];

  static const List<AlgerianLevelInfo> allLevels = [
    AlgerianLevelInfo(
      code: '1AP',
      cycle: 'primaire',
      nameAr: 'السنة الأولى ابتدائي (1AP)',
      nameFr: '1ère Année Primaire',
    ),
    AlgerianLevelInfo(
      code: '2AP',
      cycle: 'primaire',
      nameAr: 'السنة الثانية ابتدائي (2AP)',
      nameFr: '2ème Année Primaire',
    ),
    AlgerianLevelInfo(
      code: '3AP',
      cycle: 'primaire',
      nameAr: 'السنة الثالثة ابتدائي (3AP)',
      nameFr: '3ème Année Primaire',
    ),
    AlgerianLevelInfo(
      code: '4AP',
      cycle: 'primaire',
      nameAr: 'السنة الرابعة ابتدائي (4AP)',
      nameFr: '4ème Année Primaire',
    ),
    AlgerianLevelInfo(
      code: '5AP',
      cycle: 'primaire',
      nameAr: 'السنة الخامسة ابتدائي (5AP - السانكيام)',
      nameFr: '5ème Année Primaire (5ème)',
      finalExam: '5eme',
    ),
    AlgerianLevelInfo(
      code: '1AM',
      cycle: 'moyen',
      nameAr: 'السنة الأولى متوسط (1AM)',
      nameFr: '1ère Année Moyenne',
    ),
    AlgerianLevelInfo(
      code: '2AM',
      cycle: 'moyen',
      nameAr: 'السنة الثانية متوسط (2AM)',
      nameFr: '2ème Année Moyenne',
    ),
    AlgerianLevelInfo(
      code: '3AM',
      cycle: 'moyen',
      nameAr: 'السنة الثالثة متوسط (3AM)',
      nameFr: '3ème Année Moyenne',
    ),
    AlgerianLevelInfo(
      code: '4AM',
      cycle: 'moyen',
      nameAr: 'السنة الرابعة متوسط (4AM - البيام BEM)',
      nameFr: '4ème Année Moyenne (BEM)',
      finalExam: 'BEM',
    ),
    AlgerianLevelInfo(
      code: '1AS',
      cycle: 'secondaire',
      nameAr: 'السنة الأولى ثانوي (1AS)',
      nameFr: '1ère Année Secondaire',
    ),
    AlgerianLevelInfo(
      code: '2AS',
      cycle: 'secondaire',
      nameAr: 'السنة الثانية ثانوي (2AS)',
      nameFr: '2ème Année Secondaire',
    ),
    AlgerianLevelInfo(
      code: '3AS',
      cycle: 'secondaire',
      nameAr: 'السنة الثالثة ثانوي (3AS - البكالوريا BAC)',
      nameFr: '3ème Année Secondaire (BAC)',
      finalExam: 'BAC',
    ),
  ];

  // Note: 1AS has 2 common cores (ST & Lettres), bringing total level-tracks to 13+
  static const List<StreamInfo> allStreams = [
    StreamInfo(
      code: 'TC_ST',
      nameAr: 'جذع مشترك علوم وتكنولوجيا',
      nameFr: 'Tronc Commun Sciences et Technologies',
      allowedLevels: ['1AS'],
    ),
    StreamInfo(
      code: 'TC_LET',
      nameAr: 'جذع مشترك آداب',
      nameFr: 'Tronc Commun Lettres',
      allowedLevels: ['1AS'],
    ),
    StreamInfo(
      code: 'SE',
      nameAr: 'علوم تجريبية',
      nameFr: 'Sciences Expérimentales',
      allowedLevels: ['2AS', '3AS'],
    ),
    StreamInfo(
      code: 'MATH',
      nameAr: 'رياضيات',
      nameFr: 'Mathématiques',
      allowedLevels: ['2AS', '3AS'],
    ),
    StreamInfo(
      code: 'TM',
      nameAr: 'تقني رياضي',
      nameFr: 'Technique Mathématique',
      allowedLevels: ['2AS', '3AS'],
    ),
    StreamInfo(
      code: 'GE',
      nameAr: 'تسيير واقتصاد',
      nameFr: 'Gestion et Économie',
      allowedLevels: ['2AS', '3AS'],
    ),
    StreamInfo(
      code: 'LP',
      nameAr: 'آداب وفلسفة',
      nameFr: 'Lettres et Philosophie',
      allowedLevels: ['2AS', '3AS'],
    ),
    StreamInfo(
      code: 'LE',
      nameAr: 'لغات أجنبية',
      nameFr: 'Langues Étrangères',
      allowedLevels: ['2AS', '3AS'],
    ),
  ];

  StudentProfileData? get activeProfile {
    if (profiles.isEmpty) return null;
    try {
      return profiles.firstWhere((p) => p.id == activeProfileId);
    } catch (_) {
      return profiles.first;
    }
  }

  String tr(String ar, String fr) {
    return languageCode == 'fr' && fr.isNotEmpty ? fr : ar;
  }

  AlgerianLevelInfo getLevelInfo(String code) {
    return allLevels.firstWhere(
      (l) => l.code == code,
      orElse: () => allLevels[7], // 3AM fallback
    );
  }

  StreamInfo? getStreamInfo(String? code) {
    if (code == null || code.isEmpty) return null;
    try {
      return allStreams.firstWhere((s) => s.code == code);
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    if (isInitialized) return;
    _prefs = await SharedPreferences.getInstance();

    languageCode = _prefs?.getString('languageCode') ?? 'ar';
    isDarkMode = _prefs?.getBool('isDarkMode') ?? false;
    fontScale = _prefs?.getDouble('fontScale') ?? 1.0;
    notificationsEnabled = _prefs?.getBool('notificationsEnabled') ?? true;
    parentPin = _prefs?.getString('parentPin') ?? '0000';
    geminiApiKey = _prefs?.getString('geminiApiKey') ?? '';
    customExamDateIso = _prefs?.getString('customExamDateIso');

    isGuest = _prefs?.getBool('isGuest') ?? true;
    accountName = _prefs?.getString('accountName');
    accountEmail = _prefs?.getString('accountEmail');
    activeProfileId = _prefs?.getString('activeProfileId');

    final profilesRaw = _prefs?.getString('profiles_json');
    if (profilesRaw != null && profilesRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(profilesRaw) as List;
        profiles = decoded
            .map((e) =>
                StudentProfileData.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {
        profiles = [];
      }
    }

    await _loadJsonAssets();
    _updateStreakOnLaunch();
    isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadJsonAssets() async {
    lessons = await _readAssetList('assets/lessons.json', _defaultLessons);
    exams = await _readAssetList('assets/exams.json', _defaultExams);
    quizzes = await _readAssetList('assets/quizzes.json', _defaultQuizzes);
    flashcards =
        await _readAssetList('assets/flashcards.json', _defaultFlashcards);
    calendarEvents =
        await _readAssetList('assets/calendar.json', _defaultCalendar);
  }

  Future<List>> _readAssetList(
    String assetPath,
    List> fallback,
  ) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      final List> result = [];
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map) {
            result.add(Map<String, dynamic>.from(item));
          }
        }
      } else if (decoded is Map) {
        for (final value in decoded.values) {
          if (value is List) {
            for (final item in value) {
              if (item is Map) {
                result.add(Map<String, dynamic>.from(item));
              }
            }
          }
        }
      }
      if (result.isEmpty) return fallback;
      // Merge with built-in rich Algerian samples so every cycle has content
      final existingIds = result.map((e) => e['id']?.toString()).toSet();
      for (final fb in fallback) {
        if (!existingIds.contains(fb['id']?.toString())) {
          result.add(fb);
        }
      }
      return result;
    } catch (_) {
      return fallback;
    }
  }

  void _updateStreakOnLaunch() {
    final profile = activeProfile;
    if (profile == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (profile.lastStudyDate != today) {
      final last = DateTime.tryParse(profile.lastStudyDate);
      final now = DateTime.now();
      if (last != null) {
        final diff = DateTime(now.year, now.month, now.day)
            .difference(DateTime(last.year, last.month, last.day))
            .inDays;
        if (diff == 1) {
          profile.streakDays += 1;
        } else if (diff > 1) {
          profile.streakDays = 1;
        }
      }
      profile.lastStudyDate = today;
      profile.todayStudiedMinutes = 0;
      saveProfiles();
    }
  }

  Future<void> saveProfiles() async {
    final encoded = jsonEncode(profiles.map((p) => p.toJson()).toList());
    await _prefs?.setString('profiles_json', encoded);
    if (activeProfileId != null) {
      await _prefs?.setString('activeProfileId', activeProfileId!);
    }
    notifyListeners();
  }

  Future<void> createProfile({
    required String name,
    required String levelCode,
    String? streamCode,
    bool asGuest = true,
    String? email,
  }) async {
    final id = 'prof_${DateTime.now().millisecondsSinceEpoch}';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final newProf = StudentProfileData(
      id: id,
      name: name.trim().isEmpty ? 'تلميذ النجاح' : name.trim(),
      levelCode: levelCode,
      streamCode: streamCode,
      xp: 50,
      streakDays: 1,
      lastStudyDate: today,
    );
    profiles.add(newProf);
    activeProfileId = id;
    isGuest = asGuest;
    if (!asGuest) {
      accountName = newProf.name;
      accountEmail = email;
      await _prefs?.setBool('isGuest', false);
      if (accountName != null) {
        await _prefs?.setString('accountName', accountName!);
      }
      if (accountEmail != null) {
        await _prefs?.setString('accountEmail', accountEmail!);
      }
    } else {
      await _prefs?.setBool('isGuest', true);
    }
    await saveProfiles();
  }

  Future<void> linkAccountLater({
    required String name,
    required String email,
    required String password,
  }) async {
    isGuest = false;
    accountName = name.trim();
    accountEmail = email.trim();
    await _prefs?.setBool('isGuest', false);
    await _prefs?.setString('accountName', accountName!);
    await _prefs?.setString('accountEmail', accountEmail!);
    await _prefs?.setString('accountPassword', password);
    if (activeProfile != null && name.trim().isNotEmpty) {
      activeProfile!.name = name.trim();
      await saveProfiles();
    }
    notifyListeners();
  }

  Future<void> switchProfile(String id) async {
    activeProfileId = id;
    await _prefs?.setString('activeProfileId', id);
    _updateStreakOnLaunch();
    notifyListeners();
  }

  bool shouldSuggestSeptemberPromotion() {
    final p = activeProfile;
    if (p == null) return false;
    final now = DateTime.now();
    return now.month == 9 && p.createdYear < now.year;
  }

  Future<void> promoteActiveProfileToNextGrade() async {
    final p = activeProfile;
    if (p == null) return;
    final idx = allLevels.indexWhere((l) => l.code == p.levelCode);
    if (idx >= 0 && idx < allLevels.length - 1) {
      p.levelCode = allLevels[idx + 1].code;
      if (p.levelCode == '1AS') {
        p.streamCode = 'TC_ST';
      } else if (p.levelCode == '2AS' &&
          (p.streamCode == null || p.streamCode!.startsWith('TC_'))) {
        p.streamCode = 'SE';
      }
      p.createdYear = DateTime.now().year;
      await saveProfiles();
    }
  }

  List<SubjectInfo> getSubjectsForProfile([StudentProfileData? customProfile]) {
    final p = customProfile ?? activeProfile;
    final levelCode = p?.levelCode ?? '3AM';
    final streamCode = p?.streamCode ?? 'SE';
    final level = getLevelInfo(levelCode);

    if (level.cycle == 'primaire') {
      return const [
        SubjectInfo(
          id: 'math',
          nameAr: 'الرياضيات',
          nameFr: 'Mathématiques',
          emoji: '🧮',
          colorHex: 0xFFDBEAFE,
          coeff: 2,
        ),
        SubjectInfo(
          id: 'arabic',
          nameAr: 'اللغة العربية',
          nameFr: 'Langue Arabe',
          emoji: '📖',
          colorHex: 0xFFFEF3C7,
          coeff: 3,
        ),
        SubjectInfo(
          id: 'islamic',
          nameAr: 'التربية الإسلامية',
          nameFr: 'Éducation Islamique',
          emoji: '🕌',
          colorHex: 0xFFD1FAE5,
          coeff: 1,
        ),
        SubjectInfo(
          id: 'science',
          nameAr: 'التربية العلمية والتكنولوجية',
          nameFr: 'Éducation Scientifique',
          emoji: '🌱',
          colorHex: 0xFFDCFCE7,
          coeff: 1,
        ),
        SubjectInfo(
          id: 'hisgeo',
          nameAr: 'التاريخ والجغرافيا',
          nameFr: 'Histoire et Géographie',
          emoji: '🌍',
          colorHex: 0xFFFDE68A,
          coeff: 1,
        ),
        SubjectInfo(
          id: 'civics',
          nameAr: 'التربية المدنية',
          nameFr: 'Éducation Civique',
          emoji: '🇩🇿',
          colorHex: 0xFFE0E7FF,
          coeff: 1,
        ),
        SubjectInfo(
          id: 'french',
          nameAr: 'اللغة الفرنسية',
          nameFr: 'Langue Française',
          emoji: '🗼',
          colorHex: 0xFFDBEAFE,
          coeff: 1,
        ),
        SubjectInfo(
          id: 'english',
          nameAr: 'اللغة الإنجليزية',
          nameFr: 'Langue Anglaise',
          emoji: '🇬🇧',
          colorHex: 0xFFFCE7F3,
          coeff: 1,
        ),
      ];
    }

    if (level.cycle == 'moyen') {
      final isBem = levelCode == '4AM';
      return [
        SubjectInfo(
          id: 'math',
          nameAr: 'الرياضيات',
          nameFr: 'Mathématiques',
          emoji: '🧮',
          colorHex: 0xFFDBEAFE,
          coeff: isBem ? 4 : 3,
        ),
        SubjectInfo(
          id: 'arabic',
          nameAr: 'اللغة العربية',
          nameFr: 'Langue Arabe',
          emoji: '📖',
          colorHex: 0xFFFEF3C7,
          coeff: isBem ? 5 : 3,
        ),
        SubjectInfo(
          id: 'physics',
          nameAr: 'العلوم الفيزيائية والتكنولوجيا',
          nameFr: 'Sciences Physiques',
          emoji: '⚗️',
          colorHex: 0xFFE0E7FF,
          coeff: 2,
        ),
        SubjectInfo(
          id: 'science',
          nameAr: 'علوم الطبيعة والحياة',
          nameFr: 'Sciences de la Nature et de la Vie',
          emoji: '🌿',
          colorHex: 0xFFDCFCE7,
          coeff: 2,
        ),
        SubjectInfo(
          id: 'french',
          nameAr: 'اللغة الفرنسية',
          nameFr: 'Langue Française',
          emoji: '🗼',
          colorHex: 0xFFDBEAFE,
          coeff: isBem ? 3 : 2,
        ),
        SubjectInfo(
          id: 'english',
          nameAr: 'اللغة الإنجليزية',
          nameFr: 'Langue Anglaise',
          emoji: '🇬🇧',
          colorHex: 0xFFFCE7F3,
          coeff: isBem ? 2 : 1,
        ),
        SubjectInfo(
          id: 'hisgeo',
          nameAr: 'التاريخ والجغرافيا',
          nameFr: 'Histoire et Géographie',
          emoji: '🌍',
          colorHex: 0xFFFEF3C7,
          coeff: isBem ? 3 : 2,
        ),
        SubjectInfo(
          id: 'islamic',
          nameAr: 'التربية الإسلامية',
          nameFr: 'Éducation Islamique',
          emoji: '🕌',
          colorHex: 0xFFD1FAE5,
          coeff: isBem ? 2 : 1,
        ),
        SubjectInfo(
          id: 'civics',
          nameAr: 'التربية المدنية',
          nameFr: 'Éducation Civique',
          emoji: '⚖️',
          colorHex: 0xFFF3E8FF,
          coeff: 1,
        ),
        SubjectInfo(
          id: 'cs',
          nameAr: 'الإعلام الآلي',
          nameFr: 'Informatique',
          emoji: '💻',
          colorHex: 0xFFE0F2FE,
          coeff: 1,
        ),
      ];
    }

    // Secondaire (1AS, 2AS, 3AS) with stream-specific BAC coefficients
    int mathC = 5, phyC = 5, sciC = 6, arC = 3, frC = 2, enC = 2, hgC = 2, islC = 2, philoC = 2;
    if (streamCode == 'MATH') {
      mathC = 7;
      phyC = 6;
      sciC = 2;
    } else if (streamCode == 'TM') {
      mathC = 6;
      phyC = 6;
      sciC = 2;
    } else if (streamCode == 'GE') {
      mathC = 5;
      hgC = 4;
      arC = 3;
    } else if (streamCode == 'LP' || streamCode == 'TC_LET') {
      arC = 6;
      philoC = 6;
      hgC = 4;
      frC = 3;
      enC = 3;
      mathC = 2;
    } else if (streamCode == 'LE') {
      arC = 5;
      frC = 5;
      enC = 5;
      hgC = 2;
      philoC = 2;
      mathC = 2;
    }

    final list = <SubjectInfo>[
      SubjectInfo(
        id: 'math',
        nameAr: 'الرياضيات',
        nameFr: 'Mathématiques',
        emoji: '🧮',
        colorHex: 0xFFDBEAFE,
        coeff: mathC,
      ),
      SubjectInfo(
        id: 'arabic',
        nameAr: 'اللغة العربية وآدابها',
        nameFr: 'Langue et Littérature Arabes',
        emoji: '📖',
        colorHex: 0xFFFEF3C7,
        coeff: arC,
      ),
    ];

    if (streamCode != 'LP' && streamCode != 'LE' && streamCode != 'TC_LET') {
      list.addAll([
        SubjectInfo(
          id: 'physics',
          nameAr: 'العلوم الفيزيائية',
          nameFr: 'Sciences Physiques',
          emoji: '⚗️',
          colorHex: 0xFFE0E7FF,
          coeff: phyC,
        ),
        SubjectInfo(
          id: 'science',
          nameAr: 'علوم الطبيعة والحياة',
          nameFr: 'Sciences de la Nature et de la Vie',
          emoji: '🧬',
          colorHex: 0xFFDCFCE7,
          coeff: sciC,
        ),
      ]);
    }

    if (streamCode == 'TM') {
      list.add(
        const SubjectInfo(
          id: 'tech_eng',
          nameAr: 'التكنولوجيا (هندسة مدنية/ميكانيكية/كهربائية/طرائق)',
          nameFr: 'Génie (Civil / Mécanique / Électrique / Procédés)',
          emoji: '⚙️',
          colorHex: 0xFFE0F2FE,
          coeff: 7,
        ),
      );
    }

    if (streamCode == 'GE') {
      list.addAll(const [
        SubjectInfo(
          id: 'accounting',
          nameAr: 'التسيير المحاسبي والمالي',
          nameFr: 'Gestion Comptable et Financière',
          emoji: '📊',
          colorHex: 0xFFD1FAE5,
          coeff: 6,
        ),
        SubjectInfo(
          id: 'economy',
          nameAr: 'الاقتصاد والمناجمنت والقانون',
          nameFr: 'Économie, Management et Droit',
          emoji: '🏛️',
          colorHex: 0xFFFEF3C7,
          coeff: 5,
        ),
      ]);
    }

    list.addAll([
      SubjectInfo(
        id: 'hisgeo',
        nameAr: 'التاريخ والجغرافيا',
        nameFr: 'Histoire et Géographie',
        emoji: '🌍',
        colorHex: 0xFFFEF3C7,
        coeff: hgC,
      ),
      SubjectInfo(
        id: 'islamic',
        nameAr: 'العلوم الإسلامية',
        nameFr: 'Sciences Islamiques',
        emoji: '🕌',
        colorHex: 0xFFD1FAE5,
        coeff: islC,
      ),
      SubjectInfo(
        id: 'french',
        nameAr: 'اللغة الفرنسية',
        nameFr: 'Langue Française',
        emoji: '🗼',
        colorHex: 0xFFDBEAFE,
        coeff: frC,
      ),
      SubjectInfo(
        id: 'english',
        nameAr: 'اللغة الإنجليزية',
        nameFr: 'Langue Anglaise',
        emoji: '🇬🇧',
        colorHex: 0xFFFCE7F3,
        coeff: enC,
      ),
      SubjectInfo(
        id: 'philo',
        nameAr: 'الفلسفة',
        nameFr: 'Philosophie',
        emoji: '💡',
        colorHex: 0xFFF3E8FF,
        coeff: philoC,
      ),
    ]);

    return list;
  }

  List<SubjectInfo> getWeakSubjects([StudentProfileData? customProfile]) {
    final p = customProfile ?? activeProfile;
    final all = getSubjectsForProfile(p);
    if (p == null) return all.take(2).toList();
    final sorted = List<SubjectInfo>.from(all);
    sorted.sort((a, b) {
      final scoresA = p.subjectQuizScores[a.id] ?? [];
      final scoresB = p.subjectQuizScores[b.id] ?? [];
      final avgA = scoresA.isEmpty
          ? 50.0
          : scoresA.reduce((x, y) => x + y) / scoresA.length;
      final avgB = scoresB.isEmpty
          ? 50.0
          : scoresB.reduce((x, y) => x + y) / scoresB.length;
      return avgA.compareTo(avgB);
    });
    return sorted.take(2).toList();
  }

  Future<void> addXpAndMinutes({
    required int xpEarned,
    required int minutes,
    String? subjectId,
  }) async {
    final p = activeProfile;
    if (p == null) return;
    p.xp += xpEarned;
    p.todayStudiedMinutes += minutes;
    if (subjectId != null) {
      p.subjectMinutes[subjectId] =
          (p.subjectMinutes[subjectId] ?? 0) + minutes;
    }
    await saveProfiles();
  }

  Future<void> markLessonCompleted(String lessonId, String subjectId) async {
    final p = activeProfile;
    if (p == null) return;
    if (!p.completedLessonIds.contains(lessonId)) {
      p.completedLessonIds.add(lessonId);
      p.xp += 25;
      p.todayStudiedMinutes += 10;
      p.subjectMinutes[subjectId] = (p.subjectMinutes[subjectId] ?? 0) + 10;
      await saveProfiles();
    }
  }

  Future<void> toggleBookmark(String itemId) async {
    final p = activeProfile;
    if (p == null) return;
    if (p.bookmarkedIds.contains(itemId)) {
      p.bookmarkedIds.remove(itemId);
    } else {
      p.bookmarkedIds.add(itemId);
    }
    await saveProfiles();
  }

  Future<void> saveNote(String itemId, String note) async {
    final p = activeProfile;
    if (p == null) return;
    if (note.trim().isEmpty) {
      p.personalNotes.remove(itemId);
    } else {
      p.personalNotes[itemId] = note.trim();
    }
    await saveProfiles();
  }

  Future<void> recordQuizResult({
    required String subjectId,
    required int scorePercent,
    required List> mistakes,
  }) async {
    final p = activeProfile;
    if (p == null) return;
    final list = p.subjectQuizScores[subjectId] ?? [];
    list.add(scorePercent);
    p.subjectQuizScores[subjectId] = list;
    p.xp += 30 + (scorePercent ~/ 5);
    p.todayStudiedMinutes += 8;
    p.subjectMinutes[subjectId] = (p.subjectMinutes[subjectId] ?? 0) + 8;

    for (final m in mistakes) {
      final exists = p.wrongAnswers.any((w) => w['q'] == m['q']);
      if (!exists) {
        p.wrongAnswers.insert(0, m);
      }
    }
    await saveProfiles();
  }

  Future<void> removeWrongAnswerAt(int index) async {
    final p = activeProfile;
    if (p == null) return;
    if (index >= 0 && index < p.wrongAnswers.length) {
      p.wrongAnswers.removeAt(index);
      p.xp += 10;
      await saveProfiles();
    }
  }

  Future<void> updateFlashcardMastery(String cardId, bool knewIt) async {
    final p = activeProfile;
    if (p == null) return;
    final currentBox = p.flashcardBox[cardId] ?? 1;
    p.flashcardBox[cardId] =
        knewIt ? min(5, currentBox + 1) : max(1, currentBox - 1);
    p.xp += knewIt ? 5 : 2;
    await saveProfiles();
  }

  Future<void> setLanguage(String code) async {
    languageCode = code;
    await _prefs?.setString('languageCode', code);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    await _prefs?.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setFontScale(double value) async {
    fontScale = value;
    await _prefs?.setDouble('fontScale', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    await _prefs?.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setGeminiApiKey(String key) async {
    geminiApiKey = key.trim();
    await _prefs?.setString('geminiApiKey', geminiApiKey);
    notifyListeners();
  }

  Future<void> setParentPin(String pin) async {
    parentPin = pin.trim();
    await _prefs?.setString('parentPin', parentPin);
    notifyListeners();
  }

  Future<void> setCustomExamDate(DateTime date) async {
    customExamDateIso = date.toIso8601String();
    await _prefs?.setString('customExamDateIso', customExamDateIso!);
    notifyListeners();
  }

  String exportBackupJson() {
    final data = {
      'app': 'Study DZ',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'languageCode': languageCode,
      'isGuest': isGuest,
      'accountName': accountName,
      'accountEmail': accountEmail,
      'activeProfileId': activeProfileId,
      'profiles': profiles.map((p) => p.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<bool> importBackupJson(String rawJson) async {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final rawList = map['profiles'] as List?;
      if (rawList == null || rawList.isEmpty) return false;
      profiles = rawList
          .map((e) => StudentProfileData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      activeProfileId =
          map['activeProfileId']?.toString() ?? profiles.first.id;
      isGuest = map['isGuest'] as bool? ?? isGuest;
      accountName = map['accountName']?.toString() ?? accountName;
      accountEmail = map['accountEmail']?.toString() ?? accountEmail;
      await saveProfiles();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetAllData() async {
    await _prefs?.clear();
    profiles.clear();
    activeProfileId = null;
    isGuest = true;
    accountName = null;
    accountEmail = null;
    notifyListeners();
  }

  Future<String> askGeminiTutor(String userQuestion) async {
    if (geminiApiKey.trim().isEmpty) {
      return tr(
        'لم يتم إدخال مفتاح Gemini API بعد. افتح الإعدادات في تبويب "حسابي" والصق مفتاحك المجاني من Google AI Studio لتفعيل المساعد الذكي.',
        'Clé API Gemini manquante. Ouvrez les paramètres dans "Mon Profil" pour coller votre clé gratuite Google AI Studio.',
      );
    }
    final p = activeProfile;
    final levelName = getLevelInfo(p?.levelCode ?? '3AM').nameAr;
    final systemPrompt =
        'أنت أستاذ جزائري خبير وصبور في تطبيق ستدي دي زد (Study DZ). التلميذ يدرس في مستوى: $levelName وفق المنهاج الرسمي لوزارة التربية الوطنية الجزائرية. اشرح له بأسلوب مبسط وواضح ومشجع باللغة التي سألك بها (العربية أو الفرنسية أو الدارجة الجزائرية).';

    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey.trim()}',
      );
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      final payload = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$systemPrompt\n\nسؤال التلميذ: $userQuestion'}
            ]
          }
        ]
      });
      request.add(utf8.encode(payload));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts.first['text']?.toString() ??
                'تم استلام الإجابة بنجاح.';
          }
        }
      }
      return tr(
        'تعذر الحصول على إجابة حالياً (رمز الخطأ ${response.statusCode}). تأكد من صحة مفتاح API واتصالك بالإنترنت.',
        'Impossible d\'obtenir une réponse (Code ${response.statusCode}). Vérifiez votre clé API et votre connexion Internet.',
      );
    } catch (_) {
      return tr(
        'أنت غير متصل بالإنترنت حالياً. جميع الدروس والملخصات والتمارين والحاسبات تعمل بدون إنترنت، بينما يحتاج المساعد الذكي فقط لاتصال بالشبكة.',
        'Vous êtes hors ligne. Tous les cours, sujets et outils fonctionnent hors ligne, seul le tuteur IA nécessite Internet.',
      );
    }
  }

  // Built-in rich Algerian sample content across Primaire, Moyen, and Secondaire
  static final List> _defaultLessons = [
    {
      'id': 'les_math_3am_1',
      'cycle': 'moyen',
      'level': '3AM',
      'subject_id': 'math',
      'unit_ar': 'المقطع الأول: الأعداد النسبية والمعادلات',
      'title_ar': 'المعادلات من الدرجة الأولى ذات مجهول واحد',
      'title_fr': 'Équations du premier degré à une inconnue',
      'content_ar':
          'ما هي المعادلة؟\nالمعادلة هي مساواة بين عبارتين جبريتين تحتوي على متغير واحد (مجهول x) أو أكثر.\n\nمثال تطبيقي:\nx + 2 = 5\n\nخطوات الحل:\n1. نطرح 2 من الطرفين: x = 5 - 2\n2. نحصل على: x = 3\n\nقاعدة عامة:\nلحل المعادلة ax + b = c (حيث a ≠ 0):\n• ننقل المعلوم b إلى الطرف الثاني مع تغيير إشارته: ax = c - b\n• نقسم الطرفين على المعامل a: x = (c - b) / a.',
      'summary_ar':
          '• المعادلة مساواة تتضمن مجهولاً x.\n• عند نقل حد من طرف لآخر نغير إشارته (+ يصبح - والعكس).\n• لعزل x نقسم على العدد المضروب فيه.',
      'pdf_file': 'assets/pdfs/math_equations_3am.pdf',
      'steps_exercise': {
        'question_ar': 'حل المعادلة التالية خطوة بخطوة: 3x - 5 = 10',
        'steps': [
          'الخطوة 1: ننقل العدد (-5) إلى الطرف الثاني فيصبح (+5): 3x = 10 + 5',
          'الخطوة 2: نبسط الطرف الأيمن: 3x = 15',
          'الخطوة 3: نقسم الطرفين على 3: x = 15 / 3 = 5',
          'التحقق: 3(5) - 5 = 15 - 5 = 10 (المساواة محققة ✅)',
        ]
      }
    },
    {
      'id': 'les_ar_5ap_1',
      'cycle': 'primaire',
      'level': '5AP',
      'subject_id': 'arabic',
      'unit_ar': 'القواعد النحوية',
      'title_ar': 'الجملة الفعلية وأركانها ونائب الفاعل',
      'title_fr': 'La phrase verbale et ses composants',
      'content_ar':
          'تتكون الجملة الفعلية من ركنين أساسيين هما:\n1. الفعل (ماضٍ، مضارع، أو أمر).\n2. الفاعل (وهو من قام بالفعل ويكون مرفوعاً دائماً).\n\nمثال: راجعَ التلميذُ الدرسَ.\n• راجعَ: فعل ماضٍ مبني على الفتح.\n• التلميذُ: فاعل مرفوع وعلامة رفعه الضمة الظاهرة.\n• الدرسَ: مفعول به منصوب وعلامة نصبه الفتحة.',
      'summary_ar':
          '• الفاعل اسم مرفوع نسأل عنه بـ (مَنْ؟).\n• المفعول به اسم منصوب نسأل عنه بـ (ماذا؟).\n• إذا بُني الفعل للمجهول ينوب المفعول به عن الفاعل ويصبح مرفوعاً (نائب فاعل).',
      'pdf_file': 'assets/pdfs/arabic_5ap_grammar.pdf',
      'steps_exercise': {
        'question_ar': 'أعرب الجملة التالية إعراباً تاماً: كَتَبَ المعلمُ الدرسَ',
        'steps': [
          'كَتَبَ: فعل ماضٍ مبني على الفتحة الظاهرة على آخره.',
          'المعلمُ: فاعل مرفوع وعلامة رفعه الضمة الظاهرة على آخره.',
          'الدرسَ: مفعول به منصوب وعلامة نصبه الفتحة الظاهرة على آخره.',
        ]
      }
    },
    {
      'id': 'les_phy_3as_1',
      'cycle': 'secondaire',
      'level': '3AS',
      'subject_id': 'physics',
      'unit_ar': 'الوحدة الأولى: المتابعة الزمنية لتحول كيميائي',
      'title_ar': 'سرعة التفاعل وزمن نصف التفاعل t½',
      'title_fr': 'Vitesse de réaction et temps de demi-réaction',
      'content_ar':
          'تُصنف التحولات الكيميائية حسب مدتها الزمنية إلى:\n1. تحولات سريعة (لحظية).\n2. تحولات بطيئة (تستغرق ثواني إلى ساعات).\n3. تحولات بطيئة جداً (أيام أو أشهر مثل صدأ الحديد).\n\nزمن نصف التفاعل (t½):\nهو الزمن اللازم لبلوغ تقدم التفاعل نصف قيمته النهائية:\nx(t½) = xf / 2\n\nالسرعة الحجمية للتفاعل:\nv_vol = (1 / V) × (dx / dt)',
      'summary_ar':
          '• عند اللحظة t = t½ يكون التقدم x(t½) = xf / 2.\n• تزداد سرعة التفاعل بزيادة درجة الحرارة أو التركيز الابتدائي للمتفاعلات (عوامل حركية).',
      'pdf_file': 'assets/pdfs/bac_physics_unit1.pdf',
      'steps_exercise': {
        'question_ar':
            'إذا كان التقدم الأعظمي لتحول تام هو xmax = 0.04 mol، فاحسب قيمة التقدم عند t½ واستنتج كيفية تحديده بيانياً.',
        'steps': [
          'الخطوة 1: نكتب تعريف زمن نصف التفاعل: x(t½) = xmax / 2',
          'الخطوة 2: نعوض عددياً: x(t½) = 0.04 / 2 = 0.02 mol',
          'الخطوة 3: نعين القيمة 0.02 mol على محور التراتيب ونسقطها على البيان ثم على محور الأزمنة لقراءة t½.',
        ]
      }
    },
    {
      'id': 'les_fr_4am_1',
      'cycle': 'moyen',
      'level': '4AM',
      'subject_id': 'french',
      'unit_ar': 'Projet 1: Le texte argumentatif',
      'title_ar': 'تركيب النص الحجاجي (Le texte argumentatif)',
      'title_fr': 'Structure du texte argumentatif (BEM)',
      'content_ar':
          'Dans un texte argumentatif descriptif (4AM - BEM) :\n1. Introduction : Présentation du thème + Thèse (opinion de l\'auteur).\n2. Développement : Arguments introduits par des connecteurs d\'énumération (D\'abord, Ensuite, De plus, Enfin) illustrés par des exemples.\n3. Conclusion : Réaffirmation de la thèse (En conclusion, Pour conclure).',
      'summary_ar':
          '• Thèse = وجهة النظر.\n• Arguments = الحجج والبراهين (D\'abord, Ensuite, Enfin).\n• Exemples = الأمثلة (Par exemple, comme).',
      'pdf_file': 'assets/pdfs/french_4am_bem.pdf',
      'steps_exercise': {
        'question_ar':
            'Identifiez la thèse et les connecteurs dans un paragraphe sur le tourisme en Algérie.',
        'steps': [
          'Étape 1 : Repérer la thèse dans l\'introduction (ex: L\'Algérie est une destination magnifique).',
          'Étape 2 : Souligner les connecteurs logiques (D\'abord, Ensuite, Enfin).',
          'Étape 3 : Reformuler la conclusion avec "En somme" ou "Finalement".',
        ]
      }
    },
  ];

  static final List> _defaultExams = [
    {
      'id': 'exam_bac_2025_math',
      'cycle': 'secondaire',
      'level': '3AS',
      'stream': 'SE',
      'year': 2025,
      'subject_id': 'math',
      'title_ar': 'موضوع بكالوريا 2025 - الرياضيات (علوم تجريبية)',
      'title_fr': 'Sujet BAC 2025 - Mathématiques (Sciences Exp.)',
      'sujet_ar':
          'الجمهورية الجزائرية الديمقراطية الشعبية - الديوان الوطني للامتحانات والمسابقات\nامتحان بكالوريا التعليم الثانوي (المدة: 3 ساعات ونصف - المعامل: 5)\n\nالتمرين الأول (04 نقاط - المتتاليات العددية):\nلتكن المتتالية (Un) المعرفة بحدها الأول U0 = 1 ومن أجل كل عدد طبيعي n:\nU(n+1) = (1/2) Un + 2\n1) أحسب الحدود U1، U2، U3.\n2) برهن بالتراجع أنه من أجل كل عدد طبيعي n فإن: Un < 4.\n3) أدرس اتجاه تغير المتتالية (Un) واستنتج أنها متقاربة.\n\nالتمرين الثاني (05 نقاط - الاحتمالات):\nيحتوي كيس على 5 كرات بيضاء و3 كرات خضراء لا نفرق بينها عند اللمس. نسحب عشوائياً وفي آن واحد 3 كرات.\n1) أحسب عدد الحالات الممكنة.\n2) أحسب احتمال الحادثة A: "سحب 3 كرات من نفس اللون".\n\nالتمرين الثالث (07 نقاط - الدوال الأسية):\nنعتبر الدالة f المعرفة على R بـ: f(x) = (x - 1)e^x + 2.\n1) أحسب نهايتي الدالة f عند -∞ وعند +∞.\n2) أدرس اتجاه تغير الدالة f وشكل جدول تغيراتها.',
      'correction_ar':
          'الإجابة النموذجية وسلم التنقيط:\n\nحل التمرين الأول (04 نقاط):\n1) حساب الحدود:\n• U1 = (1/2)(1) + 2 = 5/2 = 2.5 (0.5 ن)\n• U2 = (1/2)(2.5) + 2 = 3.25 (0.5 ن)\n2) البرهان بالتراجع أن Un < 4:\n• من أجل n=0 لدينا U0 = 1 < 4 محققة.\n• نفرض أن Un < 4 ونبرهن أن U(n+1) < 4:\nلدينا Un < 4 ⇒ (1/2)Un < 2 ⇒ (1/2)Un + 2 < 4 أي U(n+1) < 4. (1.5 ن)\n3) U(n+1) - Un = 2 - (1/2)Un = (1/2)(4 - Un) > 0 ومنه المتتالية متزايدة تماماً ومحدودة من الأعلى بـ 4 فهي متقاربة نحو النهاية L = 4. (1.5 ن)\n\nحل التمرين الثاني (05 نقاط):\n1) عدد الحالات الممكنة: C(8,3) = 56 حالة.\n2) P(A) = (C(5,3) + C(3,3)) / 56 = (10 + 1) / 56 = 11/56.',
      'pdf_file': 'assets/pdfs/bac_2025_math_se_sujet.pdf',
      'correction_pdf': 'assets/pdfs/bac_2025_math_se_corr.pdf',
    },
    {
      'id': 'exam_bem_2025_math',
      'cycle': 'moyen',
      'level': '4AM',
      'stream': null,
      'year': 2025,
      'subject_id': 'math',
      'title_ar': 'موضوع شهادة التعليم المتوسط BEM 2025 - الرياضيات',
      'title_fr': 'Sujet BEM 2025 - Mathématiques',
      'sujet_ar':
          'امتحان شهادة التعليم المتوسط (المدة: ساعتان - المعامل: 4)\n\nالتمرين الأول (03 نقاط):\n1) أحسب القاسم المشترك الأكبر PGCD(468, 396).\n2) اكتب الكسر 468/396 على شكل كسر غير قابل للاختزال.\n\nالتمرين الثاني (03 نقاط):\nلتكن العبارة E = (2x - 3)² - 16\n1) انشر وبسط العبارة E.\n2) حلل العبارة E إلى جداء عاملين من الدرجة الأولى.\n3) حل المعادلة: (2x - 7)(2x + 1) = 0.',
      'correction_ar':
          'التصحيح النموذجي لشهادة التعليم المتوسط:\n\nحل التمرين الأول:\n1) باستعمال خوارزمية إقليدس:\n468 = 396 × 1 + 72\n396 = 72 × 5 + 36\n72 = 36 × 2 + 0\nإذن PGCD(468, 396) = 36.\n2) اختزال الكسر: نقسم البسط والمقام على 36 فنجد: 468/396 = 13/11.\n\nحل التمرين الثاني:\n1) النشر: E = 4x² - 12x + 9 - 16 = 4x² - 12x - 7.\n2) التحليل: E = (2x - 3 - 4)(2x - 3 + 4) = (2x - 7)(2x + 1).\n3) حلول المعادلة: إما x = 7/2 أو x = -1/2.',
      'pdf_file': 'assets/pdfs/bem_2025_math_sujet.pdf',
      'correction_pdf': 'assets/pdfs/bem_2025_math_corr.pdf',
    },
    {
      'id': 'exam_5ap_2025_ar',
      'cycle': 'primaire',
      'level': '5AP',
      'stream': null,
      'year': 2025,
      'subject_id': 'arabic',
      'title_ar': 'تقييم المكتسبات وموضوع نهاية المرحلة الابتدائية 5AP - اللغة العربية',
      'title_fr': 'Examen 5ème Primaire - Langue Arabe',
      'sujet_ar':
          'السند:\nالوطنُ هو البيتُ الكبيرُ الذي نعيشُ في كنفه آمنين، وقد ضحّى الشهداءُ الأبرارُ بأرواحهم الغاليةِ حتى تنعمَ الجزائرُ بالحريةِ والاستقلال، فعلينا يا أبنائي أن نجتهدَ في طلبِ العلمِ لنبنيَ مستقبلَ وطننا.\n\nالأسئلة:\nأولاً - البناء الفكري:\n1) هات عنواناً مناسباً للنص.\n2) واجبنا نحو الوطن كما ورد في النص؟\n\nثانياً - البناء اللغوي:\n1) أعرب ما تحته خط: الشهداءُ، العلمِ.\n2) استخرج من النص جمع تكسير وصفة.',
      'correction_ar':
          'الإجابة النموذجية:\n\nالبناء الفكري:\n1) العنوان المناسب: حب الوطن / واجبنا نحو الجزائر.\n2) واجبنا نحو الوطن أن نجتهد في طلب العلم لنبني مستقبله.\n\nالبناء اللغوي:\n• الشهداءُ: فاعل مرفوع وعلامة رفعه الضمة الظاهرة على آخره.\n• العلمِ: مضاف إليه مجرور وعلامة جره الكسرة الظاهرة على آخره.\n• جمع تكسير: الشهداء / أبناء. • صفة: الكبير / الأبرار / الغالية.',
      'pdf_file': 'assets/pdfs/5ap_2025_arabic.pdf',
      'correction_pdf': 'assets/pdfs/5ap_2025_arabic_corr.pdf',
    },
  ];

  static final List> _defaultQuizzes = [
    {
      'id': 'quiz_moyen_math',
      'cycle': 'moyen',
      'subject_id': 'math',
      'difficulty': 'متوسط',
      'title_ar': 'اختبار في الرياضيات - المعادلات والحساب الحرفي',
      'title_fr': 'Quiz Mathématiques - Équations et Calcul',
      'questions': [
        {
          'q_ar': 'حل المعادلة التالية: x + 7 = 12',
          'options': ['x = 5', 'x = 7', 'x = 9', 'x = 12'],
          'correct_index': 0,
          'explanation_ar': 'بطرح 7 من الطرفين نحصل على: x = 12 - 7 = 5.',
        },
        {
          'q_ar': 'ما هو القاسم المشترك الأكبر للعددين 24 و 18؟',
          'options': ['3', '6', '8', '12'],
          'correct_index': 1,
          'explanation_ar': '24 = 6 × 4 و 18 = 6 × 3، إذن PGCD(24,18) = 6.',
        },
        {
          'q_ar': 'نشر العبارة (x + 3)² يساوي:',
          'options': ['x² + 9', 'x² + 3x + 9', 'x² + 6x + 9', '2x + 6'],
          'correct_index': 2,
          'explanation_ar':
              'متطابقة شهيرة أولى: (a+b)² = a² + 2ab + b² = x² + 6x + 9.',
        },
      ]
    },
    {
      'id': 'quiz_moyen_hisgeo',
      'cycle': 'moyen',
      'subject_id': 'hisgeo',
      'difficulty': 'سهل',
      'title_ar': 'اختبار في التاريخ والجغرافيا - الثورة التحريرية المجيدة',
      'title_fr': 'Quiz Histoire-Géographie - Révolution Algérienne',
      'questions': [
        {
          'q_ar': 'متى اندلعت الثورة التحريرية الجزائرية الكبرى؟',
          'options': [
            '1 نوفمبر 1954',
            '5 جويلية 1962',
            '20 أوت 1956',
            '8 ماي 1945'
          ],
          'correct_index': 0,
          'explanation_ar':
              'اندلعت ثورة التحرير المجيدة ليلة الفاتح من نوفمبر 1954.',
        },
        {
          'q_ar': 'في أي سنة انعقد مؤتمر الصومام التاريخي؟',
          'options': ['1954', '1955', '20 أوت 1956', '19 مارس 1962'],
          'correct_index': 2,
          'explanation_ar':
              'انعقد مؤتمر الصومام يوم 20 أوت 1956 بإفري أوزلاقن لتنظيم الثورة.',
        },
        {
          'q_ar': 'كم تبلغ مساحة الجزائر الإجمالية؟',
          'options': [
            '2,381,741 كم²',
            '1,500,000 كم²',
            '3,100,000 كم²',
            '980,000 كم²'
          ],
          'correct_index': 0,
          'explanation_ar':
              'تتربع الجزائر على مساحة 2,381,741 كم² وهي أكبر دولة إفريقية وعربية.',
        },
      ]
    },
    {
      'id': 'quiz_primaire_ar',
      'cycle': 'primaire',
      'subject_id': 'arabic',
      'difficulty': 'سهل',
      'title_ar': 'مسابقة الأبطال للابتدائي - اللغة العربية والحساب 🌟',
      'title_fr': 'Quiz Primaire - Arabe et Calcul',
      'questions': [
        {
          'q_ar': 'ما هو إعراب كلمة (التلميذُ) في جملة: نَجَحَ التلميذُ؟',
          'options': ['فاعل مرفوع', 'مفعول به منصوب', 'فعل ماضٍ', 'حرف جر'],
          'correct_index': 0,
          'explanation_ar': 'التلميذُ هو من قام بفعل النجاح فهو فاعل مرفوع بالضمة.',
        },
        {
          'q_ar': 'كم يساوي 8 × 7 ؟',
          'options': ['48', '54', '56', '64'],
          'correct_index': 2,
          'explanation_ar': 'جدول الضرب: 8 × 7 = 56.',
        },
        {
          'q_ar': 'أين تكتب الهمزة في كلمة (بِئْر) لأنها ساكنة وما قبلها مكسور؟',
          'options': ['على النبرة', 'على الألف', 'على الواو', 'على السطر'],
          'correct_index': 0,
          'explanation_ar': 'الكسرة أقوى الحركات لذلك تكتب الهمزة المتوسطة على النبرة.',
        },
      ]
    },
    {
      'id': 'quiz_secondaire_phy',
      'cycle': 'secondaire',
      'subject_id': 'physics',
      'difficulty': 'صعب',
      'title_ar': 'اختبار البكالوريا - العلوم الفيزيائية والرياضيات',
      'title_fr': 'Quiz BAC - Physique et Mathématiques',
      'questions': [
        {
          'q_ar': 'ما هي مشتقة الدالة الأسية f(x) = e^(2x) ؟',
          'options': ['e^(2x)', '2e^(2x)', 'x.e^(2x)', 'e^x'],
          'correct_index': 1,
          'explanation_ar': 'مشتقة e^(u(x)) هي u\'(x).e^(u(x)) ومنه 2e^(2x).',
        },
        {
          'q_ar': 'وحدة قياس ثابت الزمن τ في الدارة RC هي:',
          'options': ['الثانية (s)', 'الأوم (Ω)', 'الفاراد (F)', 'الفولط (V)'],
          'correct_index': 0,
          'explanation_ar': 'ثابت الزمن τ = R × C يقاس بالثانية (s).',
        },
        {
          'q_ar': 'قانون نيوتن الثاني في الميكانيك ينص على أن مجموع القوى الخارجية يساوي:',
          'options': ['m × a', 'm × v', '0 دائماً', 'm / a'],
          'correct_index': 0,
          'explanation_ar': 'ΣF_ext = m × a حيث m الكتلة و a شعاع التسارع.',
        },
      ]
    },
  ];

  static final List> _defaultFlashcards = [
    {
      'id': 'fc_1',
      'subject_id': 'math',
      'category_ar': 'قوانين الرياضيات',
      'front_ar': 'المتطابقات الشهيرة الثلاث',
      'back_ar':
          '1) (a + b)² = a² + 2ab + b²\n2) (a - b)² = a² - 2ab + b²\n3) (a - b)(a + b) = a² - b²',
    },
    {
      'id': 'fc_2',
      'subject_id': 'math',
      'category_ar': 'قوانين الرياضيات',
      'front_ar': 'مميز معادلة الدرجة الثانية Δ = b² - 4ac',
      'back_ar':
          '• إذا كان Δ > 0: حلان متمايزان x1,2 = (-b ± √Δ) / 2a\n• إذا كان Δ = 0: حل مضاعف x0 = -b / 2a\n• إذا كان Δ < 0: لا توجد حلول في R.',
    },
    {
      'id': 'fc_3',
      'subject_id': 'physics',
      'category_ar': 'الفيزياء والكيمياء',
      'front_ar': 'قوانين كمية المادة n',
      'back_ar':
          '• حالة صلبة/سائلة: n = m / M\n• حالة غازية: n = V_g / V_M\n• محلول مائي: n = C × V',
    },
    {
      'id': 'fc_4',
      'subject_id': 'hisgeo',
      'category_ar': 'تواريخ معلمية (التاريخ)',
      'front_ar': 'أهم محطات الثورة التحريرية (1954 - 1962)',
      'back_ar':
          '• 1 نوفمبر 1954: اندلاع الثورة\n• 20 أوت 1955: هجومات الشمال القسنطيني\n• 20 أوت 1956: مؤتمر الصومام\n• 19 مارس 1962: وقف إطلاق النار\n• 5 جويلية 1962: عيد الاستقلال',
    },
    {
      'id': 'fc_5',
      'subject_id': 'french',
      'category_ar': 'مفردات وقواعد الفرنسية',
      'front_ar': 'Les connecteurs d\'énumération (روابط الترتيب)',
      'back_ar':
          '• D\'abord / Premièrement (أولاً)\n• Ensuite / De plus (ثانياً / إضافة إلى ذلك)\n• Enfin / Finalement (أخيراً)',
    },
  ];

  static final List> _defaultCalendar = [
    {
      'title_ar': 'الدخول المدرسي الرسمي (جميع الأطوار)',
      'date': '2026-09-21',
      'badge_ar': 'وطني',
    },
    {
      'title_ar': 'اختبارات الفصل الأول (ابتدائي، متوسط، ثانوي)',
      'date': '2026-12-01',
      'badge_ar': 'فصل 1',
    },
    {
      'title_ar': 'اختبارات الفصل الثاني',
      'date': '2027-03-07',
      'badge_ar': 'فصل 2',
    },
    {
      'title_ar': 'تقييم مكتسبات مرحلة التعليم الابتدائي (5AP)',
      'date': '2027-05-11',
      'badge_ar': 'السانكيام 5AP',
    },
    {
      'title_ar': 'امتحان شهادة التعليم المتوسط (البيام BEM)',
      'date': '2027-06-01',
      'badge_ar': 'البيام BEM',
    },
    {
      'title_ar': 'امتحان شهادة البكالوريا (BAC)',
      'date': '2027-06-13',
      'badge_ar': 'البكالوريا BAC',
    },
  ];
}
