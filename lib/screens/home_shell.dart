import 'package:flutter/material.dart';
import '../main.dart';
import 'subjects_screen.dart';
import 'practice_screen.dart';
import 'tools_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final screens = const [
      _HomeDashboardTab(),
      SubjectsScreen(),
      PracticeScreen(),
      ToolsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: ctrl.currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: ctrl.currentTabIndex,
        onDestinationSelected: (idx) => ctrl.setTab(idx),
        indicatorColor: const Color(0xFF0B7A3E).withValues(alpha: 0.16),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: Color(0xFF0B7A3E)),
            label: ctrl.tr('الرئيسية', 'Accueil'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book, color: Color(0xFF0B7A3E)),
            label: ctrl.tr('الدراسة', 'Matières'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon:
                const Icon(Icons.emoji_events, color: Color(0xFF0B7A3E)),
            label: ctrl.tr('التمارين', 'Exercices'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.handyman_outlined),
            selectedIcon: const Icon(Icons.handyman, color: Color(0xFF0B7A3E)),
            label: ctrl.tr('أدواتي', 'Outils'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: Color(0xFF0B7A3E)),
            label: ctrl.tr('حسابي', 'Profil'),
          ),
        ],
      ),
    );
  }
}

class _HomeDashboardTab extends StatelessWidget {
  const _HomeDashboardTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final profile = ctrl.currentProfile;
    final goalProgress =
        (profile.todayStudyMinutes / profile.dailyGoalMinutes).clamp(0.0, 1.0);

    final examDate =
        DateTime.tryParse(profile.targetExamDate) ?? DateTime(2027, 6, 7);
    final daysRemaining =
        examDate.difference(DateTime.now()).inDays.clamp(0, 999);

    const tipsAr = [
      'نصيحة اليوم: حل المواضيع السابقة مع احترام الوقت الرسمي يمنحك ثقة مضاعفة يوم الامتحان!',
      'نصيحة اليوم: راجع دروسك بطريقة البطاقات الذكية (Flashcards) لمدة 15 دقيقة قبل النوم لتثبيت الحفظ.',
      'نصيحة اليوم: ركّز على المواد ذات المعاملات العالية دون إهمال المواد المكملة لرفع معدلك العام.',
    ];
    final dailyTip = tipsAr[DateTime.now().day % tipsAr.length];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: ctrl.tr('البحث الشامل', 'Recherche'),
          icon: const Icon(Icons.search),
          onPressed: () => _showGlobalSearchSheet(context, ctrl),
        ),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            children: [
              TextSpan(text: 'ستدي دي زد • ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Study ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'DZ', style: TextStyle(color: Color(0xFFF5B800))),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: ctrl.tr('تبديل المستوى أو التلميذ', 'Changer de profil'),
            icon: const Icon(Icons.switch_account),
            onPressed: () => _showLevelAndProfileDialog(context, ctrl),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (ctrl.shouldSuggestSeptemberPromotion())
            Card(
              color: const Color(0xFFFFF8E1),
              child: ListTile(
                leading: const Text('🎉', style: TextStyle(fontSize: 28)),
                title: Text(
                  ctrl.tr(
                    'دخول مدرسي موفق! هل انتقلت إلى القسم الأعلى؟',
                    'Bonne rentrée ! Passer au niveau supérieur ?',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: FilledButton(
                  onPressed: ctrl.promoteToNextGrade,
                  child: Text(ctrl.tr('ترقية القسم', 'Monter')),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B7A3E), Color(0xFF149952)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('👦🏻', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ctrl.tr(
                              'مرحباً بك مجدداً 👋 يا ${profile.name}',
                              'Bon retour 👋 ${profile.name}',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () =>
                                _showLevelAndProfileDialog(context, ctrl),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🎓 ', style: TextStyle(fontSize: 14)),
                                  Flexible(
                                    child: Text(
                                      ctrl.levelLabel(profile.levelCode) +
                                          (profile.streamCode.isNotEmpty
                                              ? ' • ${ctrl.streamLabel(profile.streamCode)}'
                                              : ''),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ctrl.tr('نسبة التقدم اليومي', 'Objectif du jour'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${(goalProgress * 100).round()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                color: Color(0xFF0B7A3E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: goalProgress,
                            minHeight: 11,
                            backgroundColor: const Color(0xFFDCE7DF),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0B7A3E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ctrl.tr(
                            'درست اليوم ${profile.todayStudyMinutes} د من أصل ${profile.dailyGoalMinutes} د • الرصيد: ${profile.xp} XP',
                            '${profile.todayStudyMinutes} / ${profile.dailyGoalMinutes} min • ${profile.xp} XP',
                          ),
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('🏆', style: TextStyle(fontSize: 42)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  emoji: '🔥',
                  value: '${profile.streakDays}',
                  label: ctrl.tr('أيام متتالية', 'Jours suivis'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  emoji: '✅',
                  value: '${profile.solvedExercisesCount}',
                  label: ctrl.tr('تمرين محلول', 'Exercices'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  emoji: '⭐',
                  value: '${profile.overallAveragePercent.round()}%',
                  label: ctrl.tr('متوسطك', 'Moyenne'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            color: const Color(0xFFE8F5E9),
            child: ListTile(
              leading: const Text('⏳', style: TextStyle(fontSize: 30)),
              title: Text(
                ctrl.tr(
                  'العد التنازلي للامتحان: باقي $daysRemaining يوماً',
                  'Compte à rebours : $daysRemaining jours restants',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF075E2F),
                ),
              ),
              subtitle: Text(
                ctrl.tr(
                  'تاريخ الهدف: ${profile.targetExamDate} • اضغط لفتح منظم الدراسة',
                  'Date cible : ${profile.targetExamDate}',
                ),
                style: const TextStyle(color: Color(0xFF1F4B32)),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF075E2F),
              ),
              onTap: () => ctrl.setTab(3),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('⭐ ', style: TextStyle(fontSize: 18)),
              Text(
                ctrl.tr('مستجدات اليوم ومتابعة الدراسة', 'Continuer à étudier'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF5D47A)),
            ),
            child: Row(
              children: [
                const Text('📘', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctrl.tr(
                          'درس مقترح في مادة الرياضيات',
                          'Leçon recommandée en Mathématiques',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Color(0xFF2B2106),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ctrl.lessons.first['title_ar']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF5A4814),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0B7A3E),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () =>
                            ctrl.setTab(1, subjectFilter: 'math'),
                        icon: const Icon(Icons.menu_book, size: 16),
                        label: Text(ctrl.tr('اقرأ الآن', 'Lire maintenant')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ctrl.tr(
              'مواد تحتاج للمراجعة (نقاط الضعف المقترحة):',
              'Matières à renforcer :',
            ),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.weakSubjects.map((subjId) {
              final meta = ctrl.subjectMeta(subjId);
              return ActionChip(
                avatar: Text(meta['emoji'].toString()),
                label: Text(
                  '${ctrl.subjectName(subjId)} (${ctrl.tr("معامل", "Coeff")} ${ctrl.getSubjectCoefficient(subjId)})',
                ),
                onPressed: () => ctrl.setTab(1, subjectFilter: subjId),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dailyTip,
                      style: const TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String value,
    required String label,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelAndProfileDialog(BuildContext context, AppController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final p = ctrl.currentProfile;
            final is1AS = p.levelCode == '1AS';
            final is2AS3AS = p.levelCode == '2AS' ||
                p.levelCode == '3AS' ||
                p.levelCode == '3AS_LIBRE';

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ctrl.tr('تغيير السنة الدراسية والشعبة', 'Changer de niveau'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: p.levelCode,
                    decoration: InputDecoration(
                      labelText: ctrl.tr('السنة الدراسية (13 مستوى)', 'Niveau'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: AppController.allLevels
                        .map(
                          (lvl) => DropdownMenuItem<String>(
                            value: lvl['code'],
                            child: Text(ctrl.tr(lvl['ar']!, lvl['fr']!)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        p.levelCode = val;
                        if (val == '1AS') {
                          p.streamCode = 'TC_ST';
                        } else if (val == '2AS' ||
                            val == '3AS' ||
                            val == '3AS_LIBRE') {
                          if (p.streamCode.isEmpty ||
                              p.streamCode.startsWith('TC_')) {
                            p.streamCode = 'SE';
                          }
                        } else {
                          p.streamCode = '';
                        }
                        ctrl.saveState();
                        setSheetState(() {});
                      }
                    },
                  ),
                  if (is1AS || is2AS3AS) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: (is1AS
                                  ? AppController.streams1AS
                                  : AppController.streams2AS3AS)
                              .any((s) => s['code'] == p.streamCode)
                          ? p.streamCode
                          : (is1AS ? 'TC_ST' : 'SE'),
                      decoration: InputDecoration(
                        labelText: ctrl.tr('الشعبة', 'Filière'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: (is1AS
                              ? AppController.streams1AS
                              : AppController.streams2AS3AS)
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s['code'],
                              child: Text(ctrl.tr(s['ar']!, s['fr']!)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          p.streamCode = val;
                          ctrl.saveState();
                          setSheetState(() {});
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(ctrl.tr('تم', 'Fermer')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGlobalSearchSheet(BuildContext context, AppController ctrl) {
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final q = query.trim().toLowerCase();
            final matchedLessons = ctrl.lessons.where((l) {
              final t = (l['title_ar'] ?? '').toString().toLowerCase();
              final c = (l['content_ar'] ?? '').toString().toLowerCase();
              return q.isNotEmpty && (t.contains(q) || c.contains(q));
            }).toList();
            final matchedExams = ctrl.exams.where((e) {
              final t = (e['title_ar'] ?? '').toString().toLowerCase();
              final c = (e['subject_text_ar'] ?? '').toString().toLowerCase();
              return q.isNotEmpty && (t.contains(q) || c.contains(q));
            }).toList();
            final matchedExercises = ctrl.exercises.where((ex) {
              final t = (ex['title_ar'] ?? '').toString().toLowerCase();
              final c = (ex['problem_ar'] ?? '').toString().toLowerCase();
              return q.isNotEmpty && (t.contains(q) || c.contains(q));
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: ctrl.tr(
                            'ابحث في الدروس، الملخصات، المواضيع والتمارين...',
                            'Rechercher une leçon, un sujet ou un exercice...',
                          ),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onChanged: (val) => setModalState(() => query = val),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: q.isEmpty
                            ? Center(
                                child: Text(
                                  ctrl.tr(
                                    'اكتب كلمة مفتاحية مثل: معادلات، PGCD، بكالوريا، ثورة...',
                                    'Tapez un mot-clé (ex: PGCD, équation, BAC...)',
                                  ),
                                ),
                              )
                            : ListView(
                                controller: scrollCtrl,
                                children: [
                                  for (final l in matchedLessons)
                                    ListTile(
                                      leading: const Text('📘',
                                          style: TextStyle(fontSize: 24)),
                                      title: Text(l['title_ar'].toString()),
                                      subtitle: Text(ctrl.tr('درس وملخص', 'Leçon')),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        ctrl.setTab(1,
                                            subjectFilter:
                                                l['subject']?.toString());
                                      },
                                    ),
                                  for (final e in matchedExams)
                                    ListTile(
                                      leading: const Text('📄',
                                          style: TextStyle(fontSize: 24)),
                                      title: Text(e['title_ar'].toString()),
                                      subtitle:
                                          Text(ctrl.tr('موضوع امتحان مرفق بالحل', 'Examen')),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        ctrl.setTab(1,
                                            subjectFilter:
                                                e['subject']?.toString());
                                      },
                                    ),
                                  for (final ex in matchedExercises)
                                    ListTile(
                                      leading: const Text('✍️',
                                          style: TextStyle(fontSize: 24)),
                                      title: Text(ex['title_ar'].toString()),
                                      subtitle: Text(ctrl.tr(
                                          'تمرين محلول خطوة بخطوة', 'Exercice')),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        ctrl.setTab(1,
                                            subjectFilter:
                                                ex['subject']?.toString());
                                      },
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
