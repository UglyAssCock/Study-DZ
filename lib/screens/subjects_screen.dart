import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String? _openedSubjectId;

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    if (ctrl.selectedSubjectFilter != null) {
      _openedSubjectId = ctrl.selectedSubjectFilter;
      ctrl.selectedSubjectFilter = null;
    }

    if (_openedSubjectId != null) {
      return _SubjectDetailView(
        subjectId: _openedSubjectId!,
        onBack: () => setState(() => _openedSubjectId = null),
      );
    }

    final profile = ctrl.currentProfile;
    final subjects = ctrl.subjectsForCurrentProfile();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${ctrl.tr("مواد", "Matières")} ${ctrl.levelLabel(profile.levelCode)}',
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF0B7A3E).withValues(alpha: 0.08),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF0B7A3E), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ctrl.tr(
                      'اختر المادة لتصفح الدروس، الملخصات، المواضيع الرسمية مع الحلول، والتمارين خطوة بخطوة.',
                      'Sélectionnez une matière pour voir les cours, résumés, sujets et exercices.',
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.12,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subj = subjects[index];
                final id = subj['id'] as String;
                final coeff = ctrl.getSubjectCoefficient(id);
                final bgColor = Color(subj['color'] as int);

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => _openedSubjectId = id),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ctrl.isDarkMode
                          ? const Color(0xFF1C2921)
                          : bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF0B7A3E).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subj['emoji'] as String,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ctrl.tr(subj['ar'] as String, subj['fr'] as String),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0B7A3E).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${ctrl.tr("المعامل", "Coeff")} : $coeff',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B7A3E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectDetailView extends StatefulWidget {
  final String subjectId;
  final VoidCallback onBack;

  const _SubjectDetailView({
    required this.subjectId,
    required this.onBack,
  });

  @override
  State<_SubjectDetailView> createState() => _SubjectDetailViewState();
}

class _SubjectDetailViewState extends State<_SubjectDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final subjectLessons = ctrl.lessons
        .where((l) => l['subject'] == widget.subjectId)
        .toList();
    final displayedLessons =
        subjectLessons.isNotEmpty ? subjectLessons : ctrl.lessons;

    final subjectExams = ctrl.exams
        .where((e) => e['subject'] == widget.subjectId)
        .toList();
    final displayedExams =
        subjectExams.isNotEmpty ? subjectExams : ctrl.exams;

    final subjectExercises = ctrl.exercises
        .where((ex) => ex['subject'] == widget.subjectId)
        .toList();
    final displayedExercises =
        subjectExercises.isNotEmpty ? subjectExercises : ctrl.exercises;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(ctrl.subjectName(widget.subjectId)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF5B800),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: ctrl.tr('الدروس والملخصات', 'Leçons & Résumés')),
            Tab(text: ctrl.tr('المواضيع والحلول', 'Sujets & Corrigés')),
            Tab(text: ctrl.tr('تمارين خطوة بخطوة', 'Exercices guidés')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLessonsList(context, ctrl, displayedLessons),
          _buildExamsList(context, ctrl, displayedExams),
          _buildStepByStepExercises(context, ctrl, displayedExercises),
        ],
      ),
    );
  }

  Widget _buildLessonsList(
    BuildContext context,
    AppController ctrl,
    List> items,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final lesson = items[idx];
        final id = lesson['id']?.toString() ?? 'les_$idx';
        final isBookmarked = ctrl.currentProfile.bookmarks.contains(id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0B7A3E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('📘', style: TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              ctrl.tr(
                lesson['title_ar']?.toString() ?? '',
                lesson['title_fr']?.toString() ?? '',
              ),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                lesson['unit_ar']?.toString() ?? '',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: const Color(0xFF0B7A3E),
              ),
              onPressed: () => ctrl.toggleBookmark(id),
            ),
            onTap: () {
              ctrl.recordStudyProgress(
                subjectId: widget.subjectId,
                minutesAdded: 10,
                xpAdded: 30,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _LessonReaderPage(lesson: lesson),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildExamsList(
    BuildContext context,
    AppController ctrl,
    List> items,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final exam = items[idx];
        final id = exam['id']?.toString() ?? 'ex_$idx';
        final isBookmarked = ctrl.currentProfile.bookmarks.contains(id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5B800).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('📄', style: TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              ctrl.tr(
                exam['title_ar']?.toString() ?? '',
                exam['title_fr']?.toString() ?? '',
              ),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              '${ctrl.tr("دورة", "Session")} ${exam['year'] ?? 2025} • ${exam['duration_minutes'] ?? 120} ${ctrl.tr("دقيقة", "min")}',
            ),
            trailing: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: const Color(0xFF0B7A3E),
              ),
              onPressed: () => ctrl.toggleBookmark(id),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _ExamViewerPage(exam: exam),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStepByStepExercises(
    BuildContext context,
    AppController ctrl,
    List> items,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        return _StepByStepExerciseCard(exercise: items[idx]);
      },
    );
  }
}

class _LessonReaderPage extends StatefulWidget {
  final Map<String, dynamic> lesson;

  const _LessonReaderPage({required this.lesson});

  @override
  State<_LessonReaderPage> createState() => _LessonReaderPageState();
}

class _LessonReaderPageState extends State<_LessonReaderPage> {
  int _selectedSubTab = 0;

  Future<void> _openOrExportPdf(BuildContext context, String pdfAssetPath) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final data = await rootBundle.load(pdfAssetPath);
      final bytes = data.buffer.asUint8List();
      final outFile = File(
        '${Directory.systemTemp.path}/${pdfAssetPath.split('/').last}',
      );
      await outFile.writeAsBytes(bytes);
      messenger.showSnackBar(
        SnackBar(
          content: Text('تم استخراج ملف PDF جاهز للفتح: ${outFile.path}'),
        ),
      );
    } catch (_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('معاينة وتحميل الدرس PDF'),
          content: Text(
            'مسار الملف المرتبط في JSON:\n$pdfAssetPath\n\nيمكنك رفع ملف الـ PDF بهذا الاسم داخل مجلد assets/ في GitHub ليتم فتحه مباشرة دون إنترنت.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final id = widget.lesson['id']?.toString() ?? 'lesson_1';
    final currentNote = ctrl.currentProfile.notes[id] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ctrl.tr(
            widget.lesson['title_ar']?.toString() ?? '',
            widget.lesson['title_fr']?.toString() ?? '',
          ),
        ),
        actions: [
          IconButton(
            tooltip: ctrl.tr('ملاحظتي الشخصية', 'Ma note'),
            icon: const Icon(Icons.edit_note),
            onPressed: () => _showNoteDialog(context, ctrl, id, currentNote),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 0,
                label: Text(ctrl.tr('الدرس', 'Cours')),
                icon: const Icon(Icons.article_outlined),
              ),
              ButtonSegment(
                value: 1,
                label: Text(ctrl.tr('ملخص', 'Résumé')),
                icon: const Icon(Icons.summarize_outlined),
              ),
              ButtonSegment(
                value: 2,
                label: Text(ctrl.tr('مخطط ذهني', 'Carte mentale')),
                icon: const Icon(Icons.account_tree_outlined),
              ),
            ],
            selected: {_selectedSubTab},
            onSelectionChanged: (s) =>
                setState(() => _selectedSubTab = s.first),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson['title_ar']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF15549A),
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    _selectedSubTab == 0
                        ? (widget.lesson['content_ar']?.toString() ?? '')
                        : _selectedSubTab == 1
                            ? (widget.lesson['summary_ar']?.toString() ??
                                widget.lesson['content_ar']?.toString() ??
                                '')
                            : (widget.lesson['mindmap_ar']?.toString() ??
                                widget.lesson['summary_ar']?.toString() ??
                                ''),
                    style: const TextStyle(fontSize: 16, height: 1.65),
                  ),
                ],
              ),
            ),
          ),
          if (currentNote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF5B800)),
              ),
              child: Text('📝 ملاحظتي: $currentNote'),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0B7A3E),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _openOrExportPdf(
              context,
              widget.lesson['pdf_file']?.toString() ?? 'assets/lesson.pdf',
            ),
            icon: const Icon(Icons.download_for_offline),
            label: Text(ctrl.tr('تحميل / فتح الدرس PDF', 'Ouvrir le PDF')),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    AppController ctrl,
    String itemId,
    String existing,
  ) {
    final textCtrl = TextEditingController(text: existing);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctrl.tr('ملاحظة شخصية على الدرس', 'Note personnelle')),
        content: TextField(
          controller: textCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: ctrl.tr('اكتب ملخصك أو ملاحظتك هنا...', 'Votre note...'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctrl.tr('إلغاء', 'Annuler')),
          ),
          FilledButton(
            onPressed: () {
              ctrl.saveNote(itemId, textCtrl.text);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: Text(ctrl.tr('حفظ', 'Enregistrer')),
          ),
        ],
      ),
    );
  }
}

class _ExamViewerPage extends StatelessWidget {
  final Map<String, dynamic> exam;

  const _ExamViewerPage({required this.exam});

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(exam['title_ar']?.toString() ?? ''),
          bottom: TabBar(
            indicatorColor: const Color(0xFFF5B800),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: ctrl.tr('الموضوع (Sujet)', 'Sujet')),
              Tab(text: ctrl.tr('التصحيح النموذجي (Corrigé)', 'Corrigé')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      exam['subject_text_ar']?.toString() ?? '',
                      style: const TextStyle(fontSize: 16, height: 1.65),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A3E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'ملف PDF المرفق: ${exam['pdf_file'] ?? 'assets/exam.pdf'}',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(
                    ctrl.tr('فتح ملف الموضوع PDF', 'Ouvrir le sujet PDF'),
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: const Color(0xFFE8F5E9),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      exam['correction_text_ar']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.65,
                        color: Color(0xFF103820),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepByStepExerciseCard extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const _StepByStepExerciseCard({required this.exercise});

  @override
  State<_StepByStepExerciseCard> createState() =>
      _StepByStepExerciseCardState();
}

class _StepByStepExerciseCardState extends State<_StepByStepExerciseCard> {
  int _revealedCount = 0;

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final steps = ((widget.exercise['steps_ar'] as List?) ?? [])
        .map((e) => e.toString())
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exercise['title_ar']?.toString() ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF0B7A3E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.exercise['problem_ar']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF2B2106),
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < _revealedCount && i < steps.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  steps[i],
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF103820),
                  ),
                ),
              ),
            Row(
              children: [
                if (_revealedCount < steps.length)
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0B7A3E),
                      ),
                      onPressed: () {
                        setState(() => _revealedCount++);
                        if (_revealedCount == steps.length) {
                          ctrl.recordStudyProgress(
                            subjectId:
                                widget.exercise['subject']?.toString() ?? 'math',
                            minutesAdded: 5,
                            xpAdded: 20,
                          );
                        }
                      },
                      icon: const Icon(Icons.visibility),
                      label: Text(
                        ctrl.tr(
                          'إظهار الخطوة ${_revealedCount + 1} من ${steps.length}',
                          'Afficher l\'étape ${_revealedCount + 1}/${steps.length}',
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _revealedCount = 0),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        ctrl.tr('إخفاء الحل والمحاولة من جديد', 'Masquer'),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
