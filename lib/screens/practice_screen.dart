import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _modeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ctrl.tr('التمارين والاختبارات التفاعلية', 'Exercices & Quiz')),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _buildChip(0, '🏆 ${ctrl.tr("اختبارات QCM", "Quiz QCM")}'),
                const SizedBox(width: 8),
                _buildChip(1, '⏱️ ${ctrl.tr("محاكي الامتحان", "Simulateur")}'),
                const SizedBox(width: 8),
                _buildChip(2, '🃏 ${ctrl.tr("البطاقات الذكية", "Flashcards")}'),
                const SizedBox(width: 8),
                _buildChip(3, '📕 ${ctrl.tr("دفتر الأخطاء", "Mes erreurs")}'),
                const SizedBox(width: 8),
                _buildChip(4, '🔊 ${ctrl.tr("طور الابتدائي الصوتي", "Primaire Audio")}'),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _modeIndex,
              children: const [
                _QuizzesView(),
                _TimedExamSimulatorView(),
                _FlashcardsSpacedRepetitionView(),
                _WrongAnswersNotebookView(),
                _PrimaireVoiceGamifiedView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(int index, String label) {
    final selected = _modeIndex == index;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : null,
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFF0B7A3E),
      onSelected: (_) => setState(() => _modeIndex = index),
    );
  }
}

class _QuizzesView extends StatefulWidget {
  const _QuizzesView();

  @override
  State<_QuizzesView> createState() => _QuizzesViewState();
}

class _QuizzesViewState extends State<_QuizzesView> {
  Map<String, dynamic>? _activeQuiz;
  int _qIndex = 0;
  int? _selectedOption;
  int _correctCount = 0;

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    if (_activeQuiz == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3949AB), Color(0xFF5E35B1)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 48)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    ctrl.tr(
                      'اختبر معلوماتك في مختلف المواد مع تصحيح فوري وشرح مفصل!',
                      'Testez vos connaissances dans toutes les matières !',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final quiz in ctrl.quizzes)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: Text(
                  ctrl.subjectMeta(quiz['subject']?.toString() ?? 'math')['emoji']
                      .toString(),
                  style: const TextStyle(fontSize: 32),
                ),
                title: Text(
                  quiz['title_ar']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '${((quiz['questions'] as List?) ?? []).length} ${ctrl.tr("أسئلة", "questions")} • ${quiz['difficulty'] ?? 'متوسط'}',
                ),
                trailing: const Icon(Icons.play_circle_fill,
                    color: Color(0xFF0B7A3E), size: 32),
                onTap: () {
                  setState(() {
                    _activeQuiz = quiz;
                    _qIndex = 0;
                    _selectedOption = null;
                    _correctCount = 0;
                  });
                },
              ),
            ),
        ],
      );
    }

    final questions = (_activeQuiz!['questions'] as List?) ?? [];
    if (_qIndex >= questions.length) {
      final scorePercent =
          questions.isEmpty ? 100 : ((_correctCount / questions.length) * 100).round();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 54)),
                  const SizedBox(height: 10),
                  Text(
                    ctrl.tr('النتيجة النهائية: $scorePercent%', 'Score : $scorePercent%'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0B7A3E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أجبت بشكل صحيح على $_correctCount من أصل ${questions.length}',
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0B7A3E),
                    ),
                    onPressed: () {
                      ctrl.recordStudyProgress(
                        subjectId:
                            _activeQuiz!['subject']?.toString() ?? 'math',
                        minutesAdded: 8,
                        xpAdded: 40,
                        quizScorePercent: scorePercent,
                      );
                      setState(() => _activeQuiz = null);
                    },
                    child: Text(ctrl.tr('حفظ النتيجة والعودة', 'Terminer')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final q = Map<String, dynamic>.from(questions[_qIndex] as Map);
    final options = ((q['options_ar'] as List?) ?? []).map((e) => e.toString()).toList();
    final correctIdx = int.tryParse(q['correct_index']?.toString() ?? '0') ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _activeQuiz = null),
              icon: const Icon(Icons.close),
              label: Text(ctrl.tr('خروج', 'Quitter')),
            ),
            Text(
              'السؤال ${_qIndex + 1} من ${questions.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              q['question_ar']?.toString() ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _selectedOption != null
                  ? null
                  : () {
                      setState(() {
                        _selectedOption = i;
                        if (i == correctIdx) {
                          _correctCount++;
                        } else {
                          ctrl.addWrongAnswer(
                            questionAr: q['question_ar']?.toString() ?? '',
                            correctAnswerAr: options[correctIdx],
                            explanationAr: q['explanation_ar']?.toString() ?? '',
                            subjectId:
                                _activeQuiz!['subject']?.toString() ?? 'math',
                          );
                        }
                      });
                    },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedOption == null
                      ? Colors.white
                      : i == correctIdx
                          ? const Color(0xFFE8F5E9)
                          : (_selectedOption == i
                              ? const Color(0xFFFFEBEE)
                              : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedOption == null
                        ? Colors.grey.shade300
                        : i == correctIdx
                            ? const Color(0xFF0B7A3E)
                            : (_selectedOption == i
                                ? Colors.red
                                : Colors.grey.shade300),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        options[i],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (_selectedOption != null && i == correctIdx)
                      const Icon(Icons.check_circle, color: Color(0xFF0B7A3E)),
                    if (_selectedOption == i && i != correctIdx)
                      const Icon(Icons.cancel, color: Colors.red),
                  ],
                ),
              ),
            ),
          ),
        if (_selectedOption != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '💡 الشرح: ${q['explanation_ar'] ?? ''}',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0B7A3E),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () {
              setState(() {
                _qIndex++;
                _selectedOption = null;
              });
            },
            child: Text(ctrl.tr('السؤال التالي', 'Suivant')),
          ),
        ],
      ],
    );
  }
}

class _TimedExamSimulatorView extends StatefulWidget {
  const _TimedExamSimulatorView();

  @override
  State<_TimedExamSimulatorView> createState() =>
      _TimedExamSimulatorViewState();
}

class _TimedExamSimulatorViewState extends State<_TimedExamSimulatorView> {
  bool _running = false;
  late DateTime _endTime;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _qIdx = 0;
  int _score = 0;
  List> _examQuestions = [];

  void _startExam(AppController ctrl) {
    final allQ = >[];
    for (final qz in ctrl.quizzes) {
      final list = (qz['questions'] as List?) ?? [];
      for (final item in list) {
        allQ.add(Map<String, dynamic>.from(item as Map));
      }
    }
    setState(() {
      _examQuestions = allQ;
      _qIdx = 0;
      _score = 0;
      _running = true;
      _endTime = DateTime.now().add(const Duration(minutes: 15));
      _remainingSeconds = 15 * 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = _endTime.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        _finishExam(ctrl);
      } else if (mounted) {
        setState(() => _remainingSeconds = diff);
      }
    });
  }

  void _finishExam(AppController ctrl) {
    _timer?.cancel();
    final total = _examQuestions.isEmpty ? 1 : _examQuestions.length;
    final mark20 = ((_score / total) * 20).toStringAsFixed(1);
    ctrl.currentProfile.examAttempts.insert(0, {
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'score': '$mark20 / 20',
    });
    ctrl.saveState();
    if (mounted) {
      setState(() => _running = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    if (!_running) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    ctrl.tr(
                      'محاكي الامتحانات الرسمية (مضاد للإيقاف المؤقت)',
                      'Simulateur d\'examen chronométré',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ctrl.tr(
                      'يحسب الوقت الحقيقي بدون إمكانية إيقاف العداد لتدريبك على ظروف امتحان السانكيام، البيام والبكالوريا.',
                      'Chronomètre réel sans pause pour vous entraîner aux conditions d\'examen.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0B7A3E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () => _startExam(ctrl),
                    icon: const Icon(Icons.timer),
                    label: Text(ctrl.tr('بدء الامتحان التجريبي الآن', 'Démarrer')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ctrl.tr('سجل محاولاتك السابقة:', 'Historique des tentatives :'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (ctrl.currentProfile.examAttempts.isEmpty)
            Text(ctrl.tr('لا توجد محاولات مسجلة بعد.', 'Aucune tentative.'))
          else
            for (final att in ctrl.currentProfile.examAttempts)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history, color: Color(0xFF0B7A3E)),
                  title: Text('العلامة: ${att['score']}'),
                  subtitle: Text('التاريخ: ${att['date']}'),
                ),
              ),
        ],
      );
    }

    final mins = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final q = _examQuestions[_qIdx];
    final opts = ((q['options_ar'] as List?) ?? []).map((e) => e.toString()).toList();
    final correct = int.tryParse(q['correct_index']?.toString() ?? '0') ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⏱️ الوقت المتبقي: $mins:$secs',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              Text('السؤال ${_qIdx + 1} / ${_examQuestions.length}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              q['question_ar']?.toString() ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < opts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () {
                if (i == correct) _score++;
                if (_qIdx + 1 >= _examQuestions.length) {
                  _finishExam(ctrl);
                } else {
                  setState(() => _qIdx++);
                }
              },
              child: Text(opts[i]),
            ),
          ),
      ],
    );
  }
}

class _FlashcardsSpacedRepetitionView extends StatefulWidget {
  const _FlashcardsSpacedRepetitionView();

  @override
  State<_FlashcardsSpacedRepetitionView> createState() =>
      _FlashcardsSpacedRepetitionViewState();
}

class _FlashcardsSpacedRepetitionViewState
    extends State<_FlashcardsSpacedRepetitionView> {
  int _index = 0;
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final cards = ctrl.flashcards;
    if (cards.isEmpty) return const SizedBox.shrink();
    final card = cards[_index % cards.length];
    final id = card['id']?.toString() ?? 'fc_$_index';
    final mastery = ctrl.currentProfile.flashcardMastery[id] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            ctrl.tr(
              'اضغط على البطاقة لقلبها (نظام التكرار المتباعد)',
              'Touchez la carte pour la retourner',
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showBack = !_showBack),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Container(
                  key: ValueKey(_showBack),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _showBack
                          ? [const Color(0xFF1565C0), const Color(0xFF1E88E5)]
                          : [const Color(0xFF0B7A3E), const Color(0xFF149952)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showBack
                            ? ctrl.tr('الإجابة / القانون', 'Réponse')
                            : ctrl.tr('السؤال / المصطلح', 'Question'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showBack
                            ? (card['back_ar']?.toString() ?? '')
                            : (card['front_ar']?.toString() ?? ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'مستوى الإتقان: $mastery ⭐',
                        style: const TextStyle(color: Color(0xFFF5B800)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    ctrl.currentProfile.flashcardMastery[id] =
                        max(0, mastery - 1);
                    ctrl.saveState();
                    setState(() {
                      _showBack = false;
                      _index++;
                    });
                  },
                  icon: const Icon(Icons.replay),
                  label: Text(ctrl.tr('لم أعرفها (مراجعة قريباً)', 'À revoir')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A3E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    ctrl.currentProfile.flashcardMastery[id] = mastery + 1;
                    ctrl.recordStudyProgress(
                      subjectId: card['subject']?.toString() ?? 'math',
                      minutesAdded: 2,
                      xpAdded: 10,
                    );
                    setState(() {
                      _showBack = false;
                      _index++;
                    });
                  },
                  icon: const Icon(Icons.check),
                  label: Text(ctrl.tr('عرفتها! (+10 XP)', 'Je savais !')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WrongAnswersNotebookView extends StatelessWidget {
  const _WrongAnswersNotebookView();

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final list = ctrl.currentProfile.wrongAnswers;
    if (list.isEmpty) {
      return Center(
        child: Text(
          ctrl.tr(
            'ممتاز! لا توجد أخطاء مسجلة في دفتر المراجعة حالياً 🎉',
            'Aucune erreur enregistrée pour le moment 🎉',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final item = list[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '❓ ${item['question_ar']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '✅ الإجابة الصحيحة: ${item['correct_ar']}',
                  style: const TextStyle(
                    color: Color(0xFF0B7A3E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('💡 الشرح: ${item['explanation_ar']}'),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: () {
                      ctrl.currentProfile.wrongAnswers.removeAt(idx);
                      ctrl.saveState();
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(ctrl.tr('فهمتها (حذف من الدفتر)', 'Compris')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrimaireVoiceGamifiedView extends StatefulWidget {
  const _PrimaireVoiceGamifiedView();

  @override
  State<_PrimaireVoiceGamifiedView> createState() =>
      _PrimaireVoiceGamifiedViewState();
}

class _PrimaireVoiceGamifiedViewState
    extends State<_PrimaireVoiceGamifiedView> {
  int _idx = 0;
  int _stars = 3;

  Future<void> _speakQuestion(BuildContext context, String text) async {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
    const channel = MethodChannel('flutter_tts');
    try {
      await channel.invokeMethod('setLanguage', 'ar-SA');
      await channel.invokeMethod('speak', text);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔊 قراءة صوتية للسؤال: $text'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final primQuiz = ctrl.quizzes.firstWhere(
      (q) => q['cycle'] == 'primaire',
      orElse: () => ctrl.quizzes.first,
    );
    final questions = (primQuiz['questions'] as List?) ?? [];
    final q = Map<String, dynamic>.from(
      questions[_idx % questions.length] as Map,
    );
    final options =
        ((q['options_ar'] as List?) ?? []).map((e) => e.toString()).toList();
    final correct = int.tryParse(q['correct_index']?.toString() ?? '0') ?? 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF5B800), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🌟 وضع أبطال الابتدائي 🌟',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6D4C00),
                ),
              ),
              Text(
                '⭐ × $_stars',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFFE3F2FD),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Text(
                  q['question_ar']?.toString() ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                  onPressed: () => _speakQuestion(
                    context,
                    q['question_ar']?.toString() ?? '',
                  ),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('استمع للسؤال بالصوت 🔊'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const [
                  Color(0xFF0B7A3E),
                  Color(0xFF1976D2),
                  Color(0xFF8E24AA),
                  Color(0xFFE65100),
                ][i % 4],
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                if (i == correct) {
                  setState(() {
                    _stars++;
                    _idx++;
                  });
                  ctrl.recordStudyProgress(
                    subjectId: 'arabic',
                    minutesAdded: 3,
                    xpAdded: 25,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('حاول مرة أخرى يا بطل! 💪'),
                    ),
                  );
                }
              },
              child: Text(
                options[i],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
