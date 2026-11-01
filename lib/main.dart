import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/onboarding_screen.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.initialize();
  runApp(StudyDzApp(controller: controller));
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.notifier!;
  }
}

class StudyDzApp extends StatelessWidget {
  final AppController controller;

  const StudyDzApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final isAr = controller.languageCode == 'ar';
          const primaryGreen = Color(0xFF0B7A3E);
          const accentGold = Color(0xFFF5B800);

          final lightScheme = ColorScheme.fromSeed(
            seedColor: primaryGreen,
            primary: primaryGreen,
            secondary: accentGold,
            brightness: Brightness.light,
            surface: const Color(0xFFF4F7F5),
          );

          final darkScheme = ColorScheme.fromSeed(
            seedColor: primaryGreen,
            primary: const Color(0xFF2ECC71),
            secondary: accentGold,
            brightness: Brightness.dark,
            surface: const Color(0xFF121A15),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ستدي دي زد - Study DZ',
            themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightScheme,
              scaffoldBackgroundColor: const Color(0xFFF2F6F3),
              cardTheme: CardThemeData(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                centerTitle: true,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkScheme,
              scaffoldBackgroundColor: const Color(0xFF0D1410),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF074D27),
                foregroundColor: Colors.white,
                centerTitle: true,
                elevation: 0,
              ),
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(controller.fontScale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            home: controller.hasCompletedOnboarding
                ? const HomeShell()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}

class StudentProfile {
  String id;
  String name;
  String levelCode;
  String streamCode;
  int xp;
  int streakDays;
  String lastStudyDate;
  int dailyGoalMinutes;
  int todayStudyMinutes;
  Map<String, int> subjectMinutes;
  Map<String, List<int>> subjectScores;
  List<String> bookmarks;
  Map<String, String> notes;
  List> wrongAnswers;
  Map<String, int> flashcardMastery;
  List> examAttempts;
  List> averageHistory;
  String targetExamDate;
  int createdMonth;
  int createdYear;

  StudentProfile({
    required this.id,
    required this.name,
    required this.levelCode,
    this.streamCode = '',
    this.xp = 120,
    this.streakDays = 1,
    this.lastStudyDate = '',
    this.dailyGoalMinutes = 45,
    this.todayStudyMinutes = 15,
    Map<String, int>? subjectMinutes,
    Map<String, List<int>>? subjectScores,
    List<String>? bookmarks,
    Map<String, String>? notes,
    List>? wrongAnswers,
    Map<String, int>? flashcardMastery,
    List>? examAttempts,
    List>? averageHistory,
    this.targetExamDate = '2027-06-07',
    int? createdMonth,
    int? createdYear,
  })  : subjectMinutes = subjectMinutes ?? {'math': 45, 'arabic': 30, 'physics': 20},
        subjectScores = subjectScores ?? {'math': [75, 82], 'arabic': [88], 'physics': [60]},
        bookmarks = bookmarks ?? [],
        notes = notes ?? {},
        wrongAnswers = wrongAnswers ?? [],
        flashcardMastery = flashcardMastery ?? {},
        examAttempts = examAttempts ?? [],
        averageHistory = averageHistory ?? [],
        createdMonth = createdMonth ?? DateTime.now().month,
        createdYear = createdYear ?? DateTime.now().year;

  String get cycle {
    if (levelCode.endsWith('AP')) return 'primaire';
    if (levelCode.endsWith('AM')) return 'moyen';
    return 'secondaire';
  }

  int get levelNumber => (xp ~/ 100) + 1;

  double get overallAveragePercent {
    int total = 0;
    int count = 0;
    for (final list in subjectScores.values) {
      for (final s in list) {
        total += s;
        count++;
      }
    }
    if (count == 0) return 82.0;
    return total / count;
  }

  int get solvedExercisesCount {
    int count = 0;
    for (final list in subjectScores.values) {
      count += list.length * 10;
    }
    return count == 0 ? 20 : count;
  }

  List<String> get weakSubjects {
    final entries = <MapEntry<String, double>>[];
    subjectScores.forEach((subj, scores) {
      if (scores.isNotEmpty) {
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        if (avg < 70) entries.add(MapEntry(subj, avg));
      }
    });
    entries.sort((a, b) => a.value.compareTo(b.value));
    if (entries.isEmpty) return ['physics', 'math'];
    return entries.map((e) => e.key).toList();
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
        'todayStudyMinutes': todayStudyMinutes,
        'subjectMinutes': subjectMinutes,
        'subjectScores': subjectScores,
        'bookmarks': bookmarks,
        'notes': notes,
        'wrongAnswers': wrongAnswers,
        'flashcardMastery': flashcardMastery,
        'examAttempts': examAttempts,
        'averageHistory': averageHistory,
        'targetExamDate': targetExamDate,
        'createdMonth': createdMonth,
        'createdYear': createdYear,
      };

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    final rawScores = (json['subjectScores'] as Map?) ?? {};
    final parsedScores = <String, List<int>>{};
    rawScores.forEach((k, v) {
      if (v is List) {
        parsedScores[k.toString()] =
            v.map((e) => int.tryParse(e.toString()) ?? 0).toList();
      }
    });

    final rawMins = (json['subjectMinutes'] as Map?) ?? {};
    final parsedMins = <String, int>{};
    rawMins.forEach((k, v) {
      parsedMins[k.toString()] = int.tryParse(v.toString()) ?? 0;
    });

    final rawMastery = (json['flashcardMastery'] as Map?) ?? {};
    final parsedMastery = <String, int>{};
    rawMastery.forEach((k, v) {
      parsedMastery[k.toString()] = int.tryParse(v.toString()) ?? 0;
    });

    final rawNotes = (json['notes'] as Map?) ?? {};
    final parsedNotes = <String, String>{};
    rawNotes.forEach((k, v) {
      parsedNotes[k.toString()] = v.toString();
    });

    return StudentProfile(
      id: json['id']?.toString() ?? 'p1',
      name: json['name']?.toString() ?? 'تلميذ النجاح',
      levelCode: json['levelCode']?.toString() ?? '4AM',
      streamCode: json['streamCode']?.toString() ?? '',
      xp: int.tryParse(json['xp']?.toString() ?? '120') ?? 120,
      streakDays: int.tryParse(json['streakDays']?.toString() ?? '7') ?? 7,
      lastStudyDate: json['lastStudyDate']?.toString() ?? '',
      dailyGoalMinutes:
          int.tryParse(json['dailyGoalMinutes']?.toString() ?? '45') ?? 45,
      todayStudyMinutes:
          int.tryParse(json['todayStudyMinutes']?.toString() ?? '25') ?? 25,
      subjectMinutes: parsedMins.isEmpty ? null : parsedMins,
      subjectScores: parsedScores.isEmpty ? null : parsedScores,
      bookmarks: ((json['bookmarks'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      notes: parsedNotes,
      wrongAnswers: ((json['wrongAnswers'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      flashcardMastery: parsedMastery,
      examAttempts: ((json['examAttempts'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      averageHistory: ((json['averageHistory'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      targetExamDate: json['targetExamDate']?.toString() ?? '2027-06-07',
      createdMonth: int.tryParse(json['createdMonth']?.toString() ?? '10'),
      createdYear: int.tryParse(json['createdYear']?.toString() ?? '2026'),
    );
  }
}

class AppController extends ChangeNotifier {
  bool hasCompletedOnboarding = false;
  bool isGuest = true;
  String accountName = '';
  String accountEmail = '';
  String accountPassword = '';
  String languageCode = 'ar';
  bool isDarkMode = false;
  double fontScale = 1.0;
  bool notificationsEnabled = true;
  String parentPin = '1234';
  String geminiApiKey = '';
  int currentTabIndex = 0;
  String? selectedSubjectFilter;

  List<StudentProfile> profiles = [];
  int activeProfileIndex = 0;

  List> lessons = [];
  List> exams = [];
  List> quizzes = [];
  List> flashcards = [];
  List> calendarEvents = [];
  List> exercises = [];

  static const List> allLevels = [
    {'code': '1AP', 'ar': 'السنة الأولى ابتدائي (1AP)', 'fr': '1ère Année Primaire (1AP)', 'cycle': 'primaire'},
    {'code': '2AP', 'ar': 'السنة الثانية ابتدائي (2AP)', 'fr': '2ème Année Primaire (2AP)', 'cycle': 'primaire'},
    {'code': '3AP', 'ar': 'السنة الثالثة ابتدائي (3AP)', 'fr': '3ème Année Primaire (3AP)', 'cycle': 'primaire'},
    {'code': '4AP', 'ar': 'السنة الرابعة ابتدائي (4AP)', 'fr': '4ème Année Primaire (4AP)', 'cycle': 'primaire'},
    {'code': '5AP', 'ar': 'السنة الخامسة ابتدائي - السانكيام (5AP)', 'fr': '5ème Année Primaire (5AP)', 'cycle': 'primaire'},
    {'code': '1AM', 'ar': 'السنة الأولى متوسط (1AM)', 'fr': '1ère Année Moyenne (1AM)', 'cycle': 'moyen'},
    {'code': '2AM', 'ar': 'السنة الثانية متوسط (2AM)', 'fr': '2ème Année Moyenne (2AM)', 'cycle': 'moyen'},
    {'code': '3AM', 'ar': 'السنة الثالثة متوسط (3AM)', 'fr': '3ème Année Moyenne (3AM)', 'cycle': 'moyen'},
    {'code': '4AM', 'ar': 'السنة الرابعة متوسط - البيام (4AM)', 'fr': '4ème Année Moyenne - BEM (4AM)', 'cycle': 'moyen'},
    {'code': '1AS', 'ar': 'السنة الأولى ثانوي (1AS)', 'fr': '1ère Année Secondaire (1AS)', 'cycle': 'secondaire'},
    {'code': '2AS', 'ar': 'السنة الثانية ثانوي (2AS)', 'fr': '2ème Année Secondaire (2AS)', 'cycle': 'secondaire'},
    {'code': '3AS', 'ar': 'السنة الثالثة ثانوي - البكالوريا (3AS)', 'fr': '3ème Année Secondaire - BAC (3AS)', 'cycle': 'secondaire'},
    {'code': '3AS_LIBRE', 'ar': 'مترشح حر للبكالوريا (Bac Libre)', 'fr': 'Candidat Libre BAC', 'cycle': 'secondaire'},
  ];

  static const List> streams1AS = [
    {'code': 'TC_ST', 'ar': 'جذع مشترك علوم وتكنولوجيا', 'fr': 'Tronc Commun Sciences et Technologies'},
    {'code': 'TC_L', 'ar': 'جذع مشترك آداب', 'fr': 'Tronc Commun Lettres'},
  ];

  static const List> streams2AS3AS = [
    {'code': 'SE', 'ar': 'علوم تجريبية', 'fr': 'Sciences Expérimentales'},
    {'code': 'MATH', 'ar': 'رياضيات', 'fr': 'Mathématiques'},
    {'code': 'TM', 'ar': 'تقني رياضي', 'fr': 'Technique Mathématique'},
    {'code': 'GE', 'ar': 'تسيير واقتصاد', 'fr': 'Gestion et Économie'},
    {'code': 'LP', 'ar': 'آداب وفلسفة', 'fr': 'Lettres et Philosophie'},
    {'code': 'LE', 'ar': 'لغات أجنبية', 'fr': 'Langues Étrangères'},
  ];

  static const List> coreSubjects = [
    {
      'id': 'math',
      'ar': 'الرياضيات',
      'fr': 'Mathématiques',
      'emoji': '🧮',
      'color': 0xFFE3F2FD,
      'cycles': ['primaire', 'moyen', 'secondaire'],
    },
    {
      'id': 'arabic',
      'ar': 'اللغة العربية',
      'fr': 'Langue Arabe',
      'emoji': '📖',
      'color': 0xFFFFF3E0,
      'cycles': ['primaire', 'moyen', 'secondaire'],
    },
    {
      'id': 'physics',
      'ar': 'العلوم الفيزيائية والتكنولوجيا',
      'fr': 'Sciences Physiques',
      'emoji': '⚗️',
      'color': 0xFFEDE7F6,
      'cycles': ['moyen', 'secondaire'],
    },
    {
      'id': 'science',
      'ar': 'علوم الطبيعة والحياة',
      'fr': 'Sciences de la Nature et de la Vie',
      'emoji': '🌿',
      'color': 0xFFE8F5E9,
      'cycles': ['primaire', 'moyen', 'secondaire'],
    },
    {
      'id': 'hisgeo',
      'ar': 'التاريخ والجغرافيا',
      'fr': 'Histoire et Géographie',
      'emoji': '🌍',
      'color': 0xFFFFF8E1,
      'cycles': ['primaire', 'moyen', 'secondaire'],
    },
    {
      'id': 'islamic',
      'ar': 'التربية الإسلامية',
      'fr': 'Éducation Islamique',
      'emoji': '🕌',
      'color': 0xFFE0F2F1,
      'cycles': ['primaire', 'moyen', 'secondaire'],
    },
    {
      'id': 'french',
      'ar': 'اللغة الفرنسية',
      'fr': 'Langue Française',
      'emoji': '🗼',
      'color': 0xFFE3F2FD,
      'cycles': ['primaire', 'moyen', 'secondaire'],
    },
    {
      'id': 'english',
      'ar': 'اللغة الإنجليزية',
      'fr': 'Langue Anglaise',
      'emoji': '🇬🇧',
      'color': 0xFFFCE4EC,
      'cycles': ['primaire', 'moyen', 'secondaire'],
    },
    {
      'id': 'civics',
      'ar': 'التربية المدنية',
      'fr': 'Éducation Civique',
      'emoji': '⚖️',
      'color': 0xFFF3E5F5,
      'cycles': ['primaire', 'moyen'],
    },
    {
      'id': 'philo',
      'ar': 'الفلسفة',
      'fr': 'Philosophie',
      'emoji': '🤔',
      'color': 0xFFFFEBEE,
      'cycles': ['secondaire'],
    },
    {
      'id': 'cs',
      'ar': 'الإعلام الآلي',
      'fr': 'Informatique',
      'emoji': '💻',
      'color': 0xFFE8EAF6,
      'cycles': ['moyen', 'secondaire'],
    },
    {
      'id': 'accounting',
      'ar': 'التسيير المحاسبي والمالي',
      'fr': 'Gestion Comptable et Financière',
      'emoji': '📊',
      'color': 0xFFE0F7FA,
      'cycles': ['secondaire'],
    },
  ];

  StudentProfile get currentProfile {
    if (profiles.isEmpty) {
      profiles.add(StudentProfile(
        id: 'default_1',
        name: 'أمين',
        levelCode: '3AM',
        streakDays: 7,
        xp: 650,
      ));
    }
    if (activeProfileIndex < 0 || activeProfileIndex >= profiles.length) {
      activeProfileIndex = 0;
    }
    return profiles[activeProfileIndex];
  }

  String tr(String arText, String frText) {
    return languageCode == 'fr' && frText.isNotEmpty ? frText : arText;
  }

  String levelLabel(String code) {
    for (final lvl in allLevels) {
      if (lvl['code'] == code) {
        return tr(lvl['ar']!, lvl['fr']!);
      }
    }
    return code;
  }

  String streamLabel(String code) {
    for (final s in [...streams1AS, ...streams2AS3AS]) {
      if (s['code'] == code) {
        return tr(s['ar']!, s['fr']!);
      }
    }
    return '';
  }

  Map<String, dynamic> subjectMeta(String subjectId) {
    for (final s in coreSubjects) {
      if (s['id'] == subjectId) return s;
    }
    return coreSubjects.first;
  }

  String subjectName(String subjectId) {
    final m = subjectMeta(subjectId);
    return tr(m['ar'] as String, m['fr'] as String);
  }

  List> subjectsForCurrentProfile() {
    final cyc = currentProfile.cycle;
    return coreSubjects
        .where((s) => (s['cycles'] as List).contains(cyc))
        .toList();
  }

  int getSubjectCoefficient(String subjectId, {String? levelOverride, String? streamOverride}) {
    final lvl = levelOverride ?? currentProfile.levelCode;
    final strm = streamOverride ?? currentProfile.streamCode;

    if (lvl.endsWith('AP')) {
      return (subjectId == 'math' || subjectId == 'arabic') ? 2 : 1;
    }
    if (lvl == '4AM') {
      const bemCoeffs = {
        'arabic': 5,
        'math': 4,
        'french': 3,
        'hisgeo': 3,
        'science': 2,
        'physics': 2,
        'english': 2,
        'islamic': 2,
        'civics': 1,
        'cs': 1,
      };
      return bemCoeffs[subjectId] ?? 2;
    }
    if (lvl.endsWith('AM')) {
      const amCoeffs = {
        'arabic': 3,
        'math': 3,
        'french': 2,
        'hisgeo': 2,
        'science': 2,
        'physics': 2,
        'english': 1,
        'islamic': 1,
        'civics': 1,
        'cs': 1,
      };
      return amCoeffs[subjectId] ?? 1;
    }

    if (strm == 'MATH') {
      const mathCoeffs = {
        'math': 7,
        'physics': 6,
        'arabic': 3,
        'science': 2,
        'hisgeo': 2,
        'french': 2,
        'english': 2,
        'islamic': 2,
        'philo': 2,
      };
      return mathCoeffs[subjectId] ?? 2;
    }
    if (strm == 'TM') {
      const tmCoeffs = {
        'math': 6,
        'physics': 6,
        'arabic': 3,
        'hisgeo': 2,
        'french': 2,
        'english': 2,
        'islamic': 2,
        'philo': 2,
      };
      return tmCoeffs[subjectId] ?? 2;
    }
    if (strm == 'GE') {
      const geCoeffs = {
        'accounting': 6,
        'math': 5,
        'hisgeo': 4,
        'arabic': 3,
        'french': 2,
        'english': 2,
        'islamic': 2,
        'philo': 2,
      };
      return geCoeffs[subjectId] ?? 2;
    }
    if (strm == 'LP') {
      const lpCoeffs = {
        'arabic': 6,
        'philo': 6,
        'hisgeo': 4,
        'french': 3,
        'english': 3,
        'islamic': 2,
        'math': 2,
      };
      return lpCoeffs[subjectId] ?? 2;
    }
    if (strm == 'LE') {
      const leCoeffs = {
        'arabic': 5,
        'french': 5,
        'english': 5,
        'hisgeo': 2,
        'islamic': 2,
        'philo': 2,
        'math': 2,
      };
      return leCoeffs[subjectId] ?? 2;
    }
    const seCoeffs = {
      'science': 6,
      'math': 5,
      'physics': 5,
      'arabic': 3,
      'hisgeo': 2,
      'french': 2,
      'english': 2,
      'islamic': 2,
      'philo': 2,
    };
    return seCoeffs[subjectId] ?? 2;
  }

  Future<File> _resolveStorageFile() async {
    try {
      final cmdline = File('/proc/self/cmdline');
      if (await cmdline.exists()) {
        final raw = await cmdline.readAsString();
        final pkg = raw.split('\u0000').first.trim();
        if (pkg.isNotEmpty && pkg.contains('.')) {
          final dir = Directory('/data/data/$pkg/files');
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          return File('${dir.path}/study_dz_state.json');
        }
      }
    } catch (_) {}
    return File('${Directory.systemTemp.path}/study_dz_state.json');
  }

  Future<void> initialize() async {
    _loadDefaultSeedData();
    await _loadAssetsJsonSafely();
    await _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    try {
      final file = await _resolveStorageFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        restoreFromBackupJson(content, notify: false);
      }
    } catch (_) {}
  }

  Future<void> saveState() async {
    try {
      final file = await _resolveStorageFile();
      await file.writeAsString(exportBackupJson());
    } catch (_) {}
    notifyListeners();
  }

  String exportBackupJson() {
    final map = {
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'isGuest': isGuest,
      'accountName': accountName,
      'accountEmail': accountEmail,
      'languageCode': languageCode,
      'isDarkMode': isDarkMode,
      'fontScale': fontScale,
      'notificationsEnabled': notificationsEnabled,
      'parentPin': parentPin,
      'geminiApiKey': geminiApiKey,
      'activeProfileIndex': activeProfileIndex,
      'profiles': profiles.map((p) => p.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  bool restoreFromBackupJson(String jsonStr, {bool notify = true}) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      hasCompletedOnboarding = map['hasCompletedOnboarding'] == true;
      isGuest = map['isGuest'] != false;
      accountName = map['accountName']?.toString() ?? '';
      accountEmail = map['accountEmail']?.toString() ?? '';
      languageCode = map['languageCode']?.toString() ?? 'ar';
      isDarkMode = map['isDarkMode'] == true;
      fontScale = double.tryParse(map['fontScale']?.toString() ?? '1.0') ?? 1.0;
      notificationsEnabled = map['notificationsEnabled'] != false;
      parentPin = map['parentPin']?.toString() ?? '1234';
      geminiApiKey = map['geminiApiKey']?.toString() ?? '';
      activeProfileIndex =
          int.tryParse(map['activeProfileIndex']?.toString() ?? '0') ?? 0;

      final rawProfiles = (map['profiles'] as List?) ?? [];
      if (rawProfiles.isNotEmpty) {
        profiles = rawProfiles
            .map((e) => StudentProfile.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      if (notify) {
        saveState();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetAllData() async {
    hasCompletedOnboarding = false;
    isGuest = true;
    accountName = '';
    accountEmail = '';
    accountPassword = '';
    profiles = [];
    activeProfileIndex = 0;
    try {
      final file = await _resolveStorageFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
    notifyListeners();
  }

  void setTab(int idx, {String? subjectFilter}) {
    currentTabIndex = idx;
    if (subjectFilter != null) {
      selectedSubjectFilter = subjectFilter;
    }
    notifyListeners();
  }

  void recordStudyProgress({
    required String subjectId,
    int minutesAdded = 5,
    int xpAdded = 25,
    int? quizScorePercent,
  }) {
    final p = currentProfile;
    p.xp += xpAdded;
    p.todayStudyMinutes += minutesAdded;
    p.subjectMinutes[subjectId] =
        (p.subjectMinutes[subjectId] ?? 0) + minutesAdded;
    if (quizScorePercent != null) {
      final list = p.subjectScores[subjectId] ?? [];
      list.add(quizScorePercent);
      p.subjectScores[subjectId] = list;
    }
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (p.lastStudyDate != today) {
      p.streakDays += 1;
      p.lastStudyDate = today;
    }
    saveState();
  }

  void toggleBookmark(String itemId) {
    final p = currentProfile;
    if (p.bookmarks.contains(itemId)) {
      p.bookmarks.remove(itemId);
    } else {
      p.bookmarks.add(itemId);
    }
    saveState();
  }

  void saveNote(String itemId, String text) {
    final p = currentProfile;
    if (text.trim().isEmpty) {
      p.notes.remove(itemId);
    } else {
      p.notes[itemId] = text.trim();
    }
    saveState();
  }

  void addWrongAnswer({
    required String questionAr,
    required String correctAnswerAr,
    required String explanationAr,
    required String subjectId,
  }) {
    final p = currentProfile;
    final exists = p.wrongAnswers.any((w) => w['question_ar'] == questionAr);
    if (!exists) {
      p.wrongAnswers.insert(0, {
        'question_ar': questionAr,
        'correct_ar': correctAnswerAr,
        'explanation_ar': explanationAr,
        'subject': subjectId,
        'date': DateTime.now().toIso8601String().substring(0, 10),
      });
      saveState();
    }
  }

  bool shouldSuggestSeptemberPromotion() {
    final now = DateTime.now();
    final p = currentProfile;
    return now.month == 9 && now.year > p.createdYear;
  }

  void promoteToNextGrade() {
    final p = currentProfile;
    final idx = allLevels.indexWhere((e) => e['code'] == p.levelCode);
    if (idx != -1 && idx + 1 < allLevels.length) {
      p.levelCode = allLevels[idx + 1]['code']!;
      p.createdYear = DateTime.now().year;
      saveState();
    }
  }

  Future<void> _loadAssetsJsonSafely() async {
    await _mergeJsonList('assets/lessons.json', lessons, 'lessons');
    await _mergeJsonList('assets/exams.json', exams, 'exams');
    await _mergeJsonList('assets/quizzes.json', quizzes, 'quizzes');
    await _mergeJsonList('assets/flashcards.json', flashcards, 'flashcards');
    await _mergeJsonList('assets/calendar.json', calendarEvents, 'events');
  }

  Future<void> _mergeJsonList(
    String assetPath,
    List> target,
    String mapKey,
  ) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      List? list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        if (decoded[mapKey] is List) {
          list = decoded[mapKey] as List;
        } else if (decoded['items'] is List) {
          list = decoded['items'] as List;
        } else if (decoded['data'] is List) {
          list = decoded['data'] as List;
        }
      }
      if (list != null) {
        for (final item in list) {
          if (item is Map) {
            final m = Map<String, dynamic>.from(item);
            final id = m['id']?.toString() ?? '';
            if (id.isEmpty || !target.any((e) => e['id'] == id)) {
              target.add(m);
            }
          }
        }
      }
    } catch (_) {}
  }

  void _loadDefaultSeedData() {
    lessons = [
      {
        'id': 'les_math_1',
        'cycle': 'moyen',
        'level': '3AM',
        'subject': 'math',
        'unit_ar': 'المقطع الأول: الحساب الحرفي والمعادلات',
        'title_ar': 'المعادلات من الدرجة الأولى بمجهول واحد',
        'title_fr': 'Équations du premier degré à une inconnue',
        'content_ar':
            'المعادلة هي مساواة بين عبارتين جبريتين تحتوي على مجهول واحد أو أكثر (يرمز له غالباً بـ x).\n\nمثال تطبيقي:\nx + 2 = 5\n\nخطوات الحل:\n1. نطرح العدد 2 من الطرفين: x = 5 - 2\n2. نبسط النتيجة لنحصل على: x = 3\n3. التحقق: نعوض 3 في المعادلة الأصلية (3 + 2 = 5) فنجد المساواة محققة.',
        'summary_ar':
            '• لحل معادلة من الشكل ax + b = c:\n1) ننقل المعاليم إلى طرف والمجاهيل إلى طرف مع تغيير إشارة الحد المنقول.\n2) نحصل على ax = c - b.\n3) نقسم الطرفين على المعامل a (حيث a ≠ 0): x = (c - b) / a.',
        'mindmap_ar':
            '📌 المخطط الذهني للمعادلات:\n[معادلة ax + b = c] ⬅️ (نقل +b يصبح -b) ⬅️ [ax = c - b] ⬅️ (القسمة على a) ⬅️ [الحل الوحيد x = (c-b)/a]',
        'pdf_file': 'assets/math_equations_3am.pdf',
      },
      {
        'id': 'les_math_4am',
        'cycle': 'moyen',
        'level': '4AM',
        'subject': 'math',
        'unit_ar': 'الأعداد الطبيعية والأعداد الناطقة',
        'title_ar': 'القاسم المشترك الأكبر (PGCD) وخوارزمية إقليدس',
        'title_fr': 'Le PGCD et l\'algorithme d\'Euclide',
        'content_ar':
            'القاسم المشترك الأكبر لعددين طبيعيين a و b هو أكبر عدد طبيعي يقسم كلاً من a و b في آن واحد، ونرمز له بـ PGCD(a, b).\n\nطريقة القسمات المتتالية (خوارزمية إقليدس):\nنقسم العدد الأكبر على الأصغر، ثم نقسم القاسم على الباقي، ونكرر العملية حتى نحصل على باقٍ معدوم. القاسم المشترك الأكبر هو آخر باقٍ غير معدوم.',
        'summary_ar':
            '• العددان الأوليان فيما بينهما هما عددان قاسمهما المشترك الأكبر يساوي 1: PGCD(a, b) = 1.\n• لاختزال كسر a/b إلى كسر غير قابل للاختزال، نقسم كلاً من البسط والمقام على PGCD(a, b).',
        'mindmap_ar':
            '📌 حساب PGCD(a, b):\n1) طريقة الفروق المتتالية\n2) خوارزمية إقليدس (القسمات المتتالية - الأسرع في شهادة التعليم المتوسط)\n3) تطبيق مباشر: اختزال الكسور وحل وضعيات إدماجية.',
        'pdf_file': 'assets/bem_pgcd_summary.pdf',
      },
      {
        'id': 'les_ar_5ap',
        'cycle': 'primaire',
        'level': '5AP',
        'subject': 'arabic',
        'unit_ar': 'القواعد النحوية',
        'title_ar': 'الجملة الفعلية وأركانها ونائب الفاعل',
        'title_fr': 'La phrase verbale et ses composants',
        'content_ar':
            'تتكون الجملة الفعلية الأساسية من ركنين هما: الفعل والفاعل.\n• الفعل: ما دل على حدث مقترن بزمن (ماضٍ، مضارع، أمر).\n• الفاعل: اسم مرفوع يدل على من قام بالفعل، مثل: (نجحَ التلميذُ المجتهدُ).\n• إذا بُني الفعل للمجهول حُذف الفاعل وناب عنه المفعول به مرفوعاً ويسمى (نائب فاعل)، مثل: (كُتِبَ الدرسُ).',
        'summary_ar':
            '• علامات رفع الفاعل:\n- الضمة الظاهرة في المفرد وجمع التكسير وجمع المؤنث السالم.\n- الألف في المثنى (نجح التلميذان).\n- الواو في جمع المذكر السالم (فاز المجتهدون).',
        'mindmap_ar':
            '📌 الجملة الفعلية:\n[فعل مبني للمعلوم] + [فاعل مرفوع]\n[فعل مبني للمجهول] + [نائب فاعل مرفوع]',
        'pdf_file': 'assets/5ap_arabic_grammar.pdf',
      },
      {
        'id': 'les_phys_3as',
        'cycle': 'secondaire',
        'level': '3AS',
        'subject': 'physics',
        'unit_ar': 'الوحدة الأولى: المتابعة الزمنية لتحول كيميائي في وسط مائي',
        'title_ar': 'سرعة التفاعل وزمن نصف التفاعل t½',
        'title_fr': 'Vitesse de réaction et temps de demi-réaction',
        'content_ar':
            'تُصنف التحولات الكيميائية حسب مدتها الزمنية إلى ثلاثة أصناف:\n1. تحولات سريعة: تحدث لحظياً بمجرد تلامس المتفاعلات (مثل تفاعلات الترسيب).\n2. تحولات بطيئة: تستغرق من ثوانٍ إلى عدة ساعات ويمكن متابعتها بالعين أو بأجهزة القياس.\n3. تحولات بطيئة جداً: تستغرق أياماً أو أشهراً (مثل صدأ الحديد).\n\nزمن نصف التفاعل (t½): هو المدة الزمنية اللازمة لبلوغ تقدم التفاعل نصف قيمته النهائية: x(t½) = xf / 2.',
        'summary_ar':
            '• السرعة الحجمية للتفاعل: v_vol = (1/V) * (dx/dt)\n• العوامل الحركية: درجة الحرارة والتركيز المولي الابتدائي للمتفاعلات والوسيط تسرع التفاعل وتقلل من قيمة t½ دون تغيير الحالة النهائية.',
        'mindmap_ar':
            '📌 طرق المتابعة الزمنية في البكالوريا:\n1) قياس الناقلية الكهربائية G أو σ\n2) المعايرة اللونية\n3) قياس ضغط غاز أو حجم غاز منطلق',
        'pdf_file': 'assets/bac_physique_unite1.pdf',
      },
      {
        'id': 'les_fr_4am',
        'cycle': 'moyen',
        'level': '4AM',
        'subject': 'french',
        'unit_ar': 'النص الحجاجي (Le texte argumentatif)',
        'title_ar': 'كتابة مقدمة وخاتمة نص حجاجي في شهادة التعليم المتوسط',
        'title_fr': 'Rédiger un texte argumentatif (BEM)',
        'content_ar':
            'Structure du texte argumentatif :\n1. Introduction : Présenter le thème et formuler la thèse (opinion).\n2. Développement : Enchaîner les arguments introduits par des connecteurs logiques (D\'abord, Ensuite, De plus, Enfin) illustrés par des exemples (Par exemple, Ainsi).\n3. Conclusion : Réaffirmer la thèse avec un connecteur (En conclusion, Pour conclure).',
        'summary_ar':
            '• Les verbes d\'opinion : Je pense que, j\'estime que, je crois que, il me semble que.\n• Proposition subordonnée relative et complétive.',
        'mindmap_ar':
            '📌 Plan du texte argumentatif :\n[Introduction : Thème + Thèse] ➡️ [Développement : D\'abord + Ensuite + Enfin] ➡️ [Conclusion : Synthèse]',
        'pdf_file': 'assets/bem_francais_resume.pdf',
      },
    ];

    exams = [
      {
        'id': 'exam_5ap_2025',
        'cycle': 'primaire',
        'level': '5AP',
        'stream': '',
        'year': 2025,
        'subject': 'math',
        'title_ar': 'امتحان نهاية مرحلة التعليم الابتدائي (السانكيام) - الرياضيات 2025',
        'title_fr': 'Examen 5AP Mathématiques 2025',
        'duration_minutes': 90,
        'pdf_file': 'assets/5ap_math_2025.pdf',
        'subject_text_ar':
            'التمرين الأول (1.5 ن):\nأنجز العمليات التالية عمودياً:\n1) 458.25 + 132.75\n2) 900 - 345.6\n3) 125 × 24\n\nالتمرين الثاني (1.5 ن):\nحقل مستطيل الشكل طوله 120 m وعرضه 80 m.\n- احسب محيط هذا الحقل ثم مساحته.\n\nالوضعية الإدماجية (4 ن):\nاشترى فلاح 45 صندوقاً من التفاح، يزن كل صندوق 18 kg، وباع الكيلوغرام الواحد بـ 250 دج.\n1) ما هي كتلة كل التفاح؟\n2) ما هو ثمن بيع التفاح الكلي؟',
        'correction_text_ar':
            'التصحيح النموذجي:\nالتمرين الأول:\n1) 458.25 + 132.75 = 591\n2) 900 - 345.6 = 554.4\n3) 125 × 24 = 3000\n\nالتمرين الثاني:\n• المحيط: P = (120 + 80) × 2 = 400 m\n• المساحة: S = 120 × 80 = 9600 m²\n\nالوضعية الإدماجية:\n1) كتلة التفاح: 45 × 18 = 810 kg\n2) ثمن البيع الكلي: 810 × 250 = 202500 دج.',
      },
      {
        'id': 'exam_bem_2025',
        'cycle': 'moyen',
        'level': '4AM',
        'stream': '',
        'year': 2025,
        'subject': 'math',
        'title_ar': 'شهادة التعليم المتوسط (BEM) - موضوع الرياضيات دورة جوان 2025',
        'title_fr': 'Sujet BEM Mathématiques Session Juin 2025',
        'duration_minutes': 120,
        'pdf_file': 'assets/bem_math_2025.pdf',
        'subject_text_ar':
            'التمرين الأول (3 نقاط):\n1) احسب القاسم المشترك الأكبر للعددين 1053 و 832.\n2) اكتب الكسر 1053 / 832 على شكل كسر غير قابل للاختزال.\n\nالتمرين الثاني (3 نقاط):\nلتكن العبارة الجبرية: E = (2x - 3)² - (2x - 3)(x + 1)\n1) انشر وبسط العبارة E.\n2) حلل العبارة E إلى جداء عاملين من الدرجة الأولى.\n3) حل المعادلة: (2x - 3)(x - 4) = 0.',
        'correction_text_ar':
            'التصحيح النموذجي المفصل:\nالتمرين الأول:\n1) باستعمال خوارزمية إقليدس:\n1053 = 832 × 1 + 221\n832 = 221 × 3 + 169\n221 = 169 × 1 + 52\n169 = 52 × 3 + 13\n52 = 13 × 4 + 0\nإذن PGCD(1053, 832) = 13.\n2) الاختزال: (1053 ÷ 13) / (832 ÷ 13) = 81 / 64.\n\nالتمرين الثاني:\n1) النشر: E = (4x² - 12x + 9) - (2x² + 2x - 3x - 3) = 2x² - 11x + 12.\n2) التحليل: E = (2x - 3)[(2x - 3) - (x + 1)] = (2x - 3)(x - 4).\n3) الحلول: x = 4 أو x = 3/2 = 1.5.',
      },
      {
        'id': 'exam_bac_2025',
        'cycle': 'secondaire',
        'level': '3AS',
        'stream': 'SE',
        'year': 2025,
        'subject': 'physics',
        'title_ar': 'بكالوريا 2025 - العلوم الفيزيائية (شعبة علوم تجريبية)',
        'title_fr': 'Baccalauréat 2025 Sciences Physiques (Sciences Exp.)',
        'duration_minutes': 210,
        'pdf_file': 'assets/bac_physique_se_2025.pdf',
        'subject_text_ar':
            'التمرين الأول (7 نقاط) - المتابعة الزمنية:\nنغمر في اللحظة t = 0 صفيحة من الزنك Zn كتلتها m = 1.308 g في حجم V = 100 mL من محلول حمض كلور الماء (H₃O⁺ + Cl⁻) تركيزه المولي C = 0.4 mol/L.\nمعادلة التفاعل المنمذج للتحول:\nZn(s) + 2H₃O⁺(aq) = Zn²⁺(aq) + H₂(g) + 2H₂O(l)\n1) احسب كمية المادة الابتدائية للمتفاعلات.\n2) أنجز جدول تقدم التفاعل وحدد المتفاعل المحد والتقدم الأعظمي xmax.',
        'correction_text_ar':
            'التصحيح النموذجي:\n1) كمية المادة الابتدائية:\n• n₀(Zn) = m / M = 1.308 / 65.4 = 0.02 mol.\n• n₀(H₃O⁺) = C × V = 0.4 × 0.1 = 0.04 mol.\n2) من جدول التقدم:\n• بافتراض Zn محد: xmax = 0.02 mol.\n• بافتراض H₃O⁺ محد: 0.04 - 2xmax = 0 ومنه xmax = 0.02 mol.\nالمزيج الابتدائي ستوكيومتري والتقدم الأعظمي xmax = 0.02 mol.',
      },
    ];

    exercises = [
      {
        'id': 'ex_step_1',
        'cycle': 'moyen',
        'subject': 'math',
        'title_ar': 'تمرين محلول خطوة بخطوة: حل جملة معادلتين',
        'problem_ar':
            'حل في مجموعة الأعداد الحقيقية جملة المعادلتين التالية:\n(1) 2x + y = 7\n(2) x - y = 2',
        'steps_ar': [
          'الخطوة 1: نلاحظ أن معامل y في المعادلة (1) هو (+1) وفي المعادلة (2) هو (-1)، وهما متعاكسان.',
          'الخطوة 2: نجمع المعادلتين (1) و (2) طرفاً لطرف للتخلص من المجهول y:\n(2x + x) + (y - y) = 7 + 2\n3x = 9',
          'الخطوة 3: نقسم الطرفين على 3 فنجد قيمة x:\nx = 9 / 3 = 3',
          'الخطوة 4: نعوض قيمة x = 3 في المعادلة (1) لإيجاد y:\n2(3) + y = 7 ⟹ 6 + y = 7 ⟹ y = 1\nإذن الثنائية (3, 1) هي الحل الوحيد للجملة.',
        ],
      },
      {
        'id': 'ex_step_2',
        'cycle': 'secondaire',
        'subject': 'physics',
        'title_ar': 'تمرين محلول خطوة بخطوة: الدارة الكهربائية RC اثناء الشحن',
        'problem_ar':
            'نشحن مكثفة سعتها C = 100 μF عبر ناقل أومي مقاومته R = 1 kΩ بواسطة مولد للتوتر الثابت E = 6 V.\n1) احسب ثابت الزمن τ.\n2) احسب الطاقة الأعظمية المخزنة في المكثفة عند نهاية الشحن.',
        'steps_ar': [
          'الخطوة 1: تحويل الوحدات إلى الجملة الدولية (SI):\nR = 1 kΩ = 1000 Ω\nC = 100 μF = 100 × 10⁻⁶ F = 10⁻⁴ F',
          'الخطوة 2: حساب ثابت الزمن τ بتطبيق العلاقة:\nτ = R × C = 1000 × 10⁻⁴ = 0.1 s',
          'الخطوة 3: كتابة عبارة الطاقة الأعظمية المخزنة في المكثفة:\nE(c,max) = ½ × C × E²',
          'الخطوة 4: التطبيق العددي:\nE(c,max) = 0.5 × 10⁻⁴ × (6)² = 1.8 × 10⁻³ J.',
        ],
      },
      {
        'id': 'ex_step_3',
        'cycle': 'primaire',
        'subject': 'math',
        'title_ar': 'تمرين محلول خطوة بخطوة: التناسبية والنسبة المئوية',
        'problem_ar':
            'مدرسة ابتدائية بها 400 تلميذ، نجح منهم 90% في امتحان نهاية السنة.\nكم عدد التلاميذ الناجحين؟ وكم عدد الراسبين؟',
        'steps_ar': [
          'الخطوة 1: لحساب 90% من العدد 400 نضرب 400 في 90 ثم نقسم على 100.',
          'الخطوة 2: حساب البسط: 400 × 90 = 36000.',
          'الخطوة 3: القسمة على 100: 36000 ÷ 100 = 360 تلميذاً ناجحاً.',
          'الخطوة 4: عدد التلاميذ غير الناجحين: 400 - 360 = 40 تلميذاً.',
        ],
      },
    ];

    quizzes = [
      {
        'id': 'q_moyen_math',
        'cycle': 'moyen',
        'subject': 'math',
        'difficulty': 'متوسط',
        'title_ar': 'اختبار في الرياضيات: المعادلات والحساب الحرفي',
        'questions': [
          {
            'question_ar': 'حل المعادلة التالية: x + 7 = 12',
            'options_ar': ['x = 5', 'x = 7', 'x = 9', 'x = 12'],
            'correct_index': 0,
            'explanation_ar': 'بطرح 7 من الطرفين نحصل على: x = 12 - 7 = 5.',
          },
          {
            'question_ar': 'ما هو القاسم المشترك الأكبر للعددين 18 و 24؟',
            'options_ar': ['2', '3', '6', '8'],
            'correct_index': 2,
            'explanation_ar': 'قواسم 18 هي (1، 2، 3، 6، 9، 18) وقواسم 24 تشمل 6، إذن PGCD(24,18) = 6.',
          },
          {
            'question_ar': 'نشر الجداء الشهير (x + 3)² يساوي:',
            'options_ar': ['x² + 9', 'x² + 6x + 9', 'x² + 3x + 9', '2x + 6'],
            'correct_index': 1,
            'explanation_ar': '(a + b)² = a² + 2ab + b² ومنه (x + 3)² = x² + 6x + 9.',
          },
        ],
      },
      {
        'id': 'q_moyen_hisgeo',
        'cycle': 'moyen',
        'subject': 'hisgeo',
        'difficulty': 'سهل',
        'title_ar': 'اختبار في التاريخ والجغرافيا: الثورة التحريرية المجيدة',
        'questions': [
          {
            'question_ar': 'متى اندلعت الثورة التحريرية الجزائرية الكبرى؟',
            'options_ar': ['1 نوفمبر 1954', '20 أوت 1955', '20 أوت 1956', '5 جويلية 1962'],
            'correct_index': 0,
            'explanation_ar': 'اندلعت الثورة التحريرية المباركة يوم الفاتح من نوفمبر 1954.',
          },
          {
            'question_ar': 'أين انعقد مؤتمر الصومام التاريخي؟',
            'options_ar': ['إيفري أوزلاقن (الولاية الثالثة)', 'الأوراس (الولاية الأولى)', 'العاصمة', 'طرابلس'],
            'correct_index': 0,
            'explanation_ar': 'انعقد مؤتمر الصومام في 20 أوت 1956 بقرية إيفري أوزلاقن بالولاية التاريخية الثالثة.',
          },
          {
            'question_ar': 'ما هي الوثيقة السياسية التي أعلنت مبادئ وأهداف الثورة يوم اندلاعها؟',
            'options_ar': ['بيان أول نوفمبر 1954', 'ميثاق الصومام', 'ميثاق طرابلس', 'اتفاقيات إيفيان'],
            'correct_index': 0,
            'explanation_ar': 'بيان أول نوفمبر 1954 هو الوثيقة التأسيسية التي حددت شروط وأهداف الثورة.',
          },
        ],
      },
      {
        'id': 'q_prim_general',
        'cycle': 'primaire',
        'subject': 'arabic',
        'difficulty': 'سهل',
        'title_ar': 'تحدي الأبطال للطور الابتدائي 🌟',
        'questions': [
          {
            'question_ar': 'ما هو إعراب كلمة (التلميذُ) في جملة: نجحَ التلميذُ؟',
            'options_ar': ['فاعل مرفوع بالضمة', 'مفعول به منصوب', 'مبتدأ مرفوع', 'فعل ماضٍ'],
            'correct_index': 0,
            'explanation_ar': 'التلميذُ هو من قام بفعل النجاح فهو فاعل مرفوع وعلامة رفعه الضمة الظاهرة.',
          },
          {
            'question_ar': 'كم يساوي 8 × 7 ؟',
            'options_ar': ['54', '56', '64', '48'],
            'correct_index': 1,
            'explanation_ar': 'جدول الضرب: 8 × 7 = 56.',
          },
          {
            'question_ar': 'ما هي عاصمة الجزائر؟',
            'options_ar': ['الجزائر العاصمة', 'وهران', 'قسنطينة', 'عنابة'],
            'correct_index': 0,
            'explanation_ar': 'الجزائر العاصمة هي عاصمة الجمهورية الجزائرية الديمقراطية الشعبية.',
          },
        ],
      },
      {
        'id': 'q_sec_bac',
        'cycle': 'secondaire',
        'subject': 'physics',
        'difficulty': 'صعب',
        'title_ar': 'اختبار البكالوريا: الكيمياء الحركية والظواهر الكهربائية',
        'questions': [
          {
            'question_ar': 'ما هي وحدة ثابت الزمن τ في الدارة RC؟',
            'options_ar': ['الثانية (s)', 'الفاراد (F)', 'الأوم (Ω)', 'الفولط (V)'],
            'correct_index': 0,
            'explanation_ar': 'ثابت الزمن τ = R × C له بعد زمني ووحدته في الجملة الدولية هي الثانية (s).',
          },
          {
            'question_ar': 'عند رفع درجة حرارة الوسط التفاعلي لتفاعل بطيء فإن زمن نصف التفاعل t½:',
            'options_ar': ['يتناقص', 'يتزايد', 'يبقى ثابتاً', 'ينعدم'],
            'correct_index': 0,
            'explanation_ar': 'درجة الحرارة عامل حركي يسرع التفاعل فيبلغ نصف تقدمه النهائي في مدة أقصر.',
          },
          {
            'question_ar': 'العلاقة بين كمية المادة n وكتلة العينة m والكتلة المولية M هي:',
            'options_ar': ['n = m / M', 'n = m × M', 'n = M / m', 'n = m + M'],
            'correct_index': 0,
            'explanation_ar': 'كمية المادة بالمول تساوي حاصل قسمة الكتلة بالغرام على الكتلة المولية (n = m / M).',
          },
        ],
      },
    ];

    flashcards = [
      {
        'id': 'fc_1',
        'subject': 'math',
        'front_ar': 'متطابقة شهيرة رقم 1:\n(a + b)² = ?',
        'back_ar': 'a² + 2ab + b²',
      },
      {
        'id': 'fc_2',
        'subject': 'math',
        'front_ar': 'متطابقة شهيرة رقم 3:\n(a - b)(a + b) = ?',
        'back_ar': 'a² - b²',
      },
      {
        'id': 'fc_3',
        'subject': 'physics',
        'front_ar': 'قانون الغازات المثالية',
        'back_ar': 'P × V = n × R × T\n(P بالباسكال، V بالمتر المكعب، T بالكلفن)',
      },
      {
        'id': 'fc_4',
        'subject': 'hisgeo',
        'front_ar': 'تاريخ هجومات الشمال القسنطيني',
        'back_ar': '20 أوت 1955 بقيادة الشهيد زيغود يوسف',
      },
      {
        'id': 'fc_5',
        'subject': 'hisgeo',
        'front_ar': 'تاريخ استرجاع السيادة الوطنية واستقلال الجزائر',
        'back_ar': '5 جويلية 1962',
      },
      {
        'id': 'fc_6',
        'subject': 'french',
        'front_ar': 'الروابط المنطقية للترتيب بالفرنسية (Connecteurs d\'énumération)',
        'back_ar': 'D\'abord (أولاً), Ensuite (ثم), De plus (علاوة على ذلك), Enfin (أخيراً)',
      },
    ];

    calendarEvents = [
      {
        'id': 'cal_1',
        'title_ar': 'اختبارات الفصل الأول لجميع الأطوار',
        'date': '2026-12-01',
        'badge_ar': 'الفصل 1',
      },
      {
        'id': 'cal_2',
        'title_ar': 'اختبارات الفصل الثاني لجميع الأطوار',
        'date': '2027-03-07',
        'badge_ar': 'الفصل 2',
      },
      {
        'id': 'cal_3',
        'title_ar': 'امتحان شهادة التعليم المتوسط (BEM - البيام)',
        'date': '2027-06-01',
        'badge_ar': 'امتحان رسمي',
      },
      {
        'id': 'cal_4',
        'title_ar': 'امتحان شهادة البكالوريا (BAC)',
        'date': '2027-06-13',
        'badge_ar': 'امتحان رسمي',
      },
    ];
  }
}
