import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../main.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  int? _selectedTool;

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);

    if (_selectedTool != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _selectedTool = null),
          ),
          title: Text(_toolTitle(ctrl, _selectedTool!)),
        ),
        body: _buildToolBody(_selectedTool!),
      );
    }

    final tools = [
      {
        'idx': 0,
        'emoji': '🧮',
        'title': ctrl.tr('حاسبة المعدل الفصلي والرسمي', 'Calculateur de moyenne'),
        'sub': ctrl.tr('السانكيام، البيام، البكالوريا حسب الشعبة', '5ème, BEM, BAC'),
      },
      {
        'idx': 1,
        'emoji': '📅',
        'title': ctrl.tr('منظم الدراسة الذكي', 'Planificateur d\'étude'),
        'sub': ctrl.tr('جدول مراجعة يومي آلي وتذكيرات', 'Planning quotidien'),
      },
      {
        'idx': 2,
        'emoji': '🤖',
        'title': ctrl.tr('المساعد الذكي (AI Tutor)', 'Tuteur IA Gemini'),
        'sub': ctrl.tr('اشرح لي أي درس بالعربية أو الفرنسية', 'Posez vos questions'),
      },
      {
        'idx': 3,
        'emoji': '⏱️',
        'title': ctrl.tr('مؤقت بومودورو للتركيز', 'Minuteur Pomodoro'),
        'sub': ctrl.tr('25 دقيقة دراسة + إحصائيات كل مادة', 'Focus 25 min'),
      },
      {
        'idx': 4,
        'emoji': '📓',
        'title': ctrl.tr('المفكرة الرقمية والمحفوظات', 'Notes & Favoris'),
        'sub': ctrl.tr('ملاحظاتك الشخصية والدروس المحفوظة', 'Vos notes'),
      },
      {
        'idx': 5,
        'emoji': '📆',
        'title': ctrl.tr('رزنامة الامتحانات الرسمية', 'Calendrier officiel'),
        'sub': ctrl.tr('تواريخ الفصول وامتحانات ONEC', 'Dates importantes'),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(ctrl.tr('أدواتي الدراسية', 'Mes Outils')),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.02,
        ),
        itemCount: tools.length,
        itemBuilder: (context, idx) {
          final t = tools[idx];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => _selectedTool = t['idx'] as int),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t['emoji'] as String,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t['sub'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _toolTitle(AppController ctrl, int idx) {
    switch (idx) {
      case 0:
        return ctrl.tr('حاسبة المعدل الرسمي والفصلي', 'Calculateur de moyenne');
      case 1:
        return ctrl.tr('منظم الدراسة وجدول المراجعة', 'Planificateur');
      case 2:
        return ctrl.tr('المساعد الذكي (الذكاء الاصطناعي)', 'Tuteur IA');
      case 3:
        return ctrl.tr('مؤقت بومودورو للتركيز', 'Minuteur Pomodoro');
      case 4:
        return ctrl.tr('المفكرة الرقمية والمحفوظات', 'Notes & Favoris');
      default:
        return ctrl.tr('رزنامة الامتحانات الرسمية', 'Calendrier des examens');
    }
  }

  Widget _buildToolBody(int idx) {
    switch (idx) {
      case 0:
        return const _AverageCalculatorTool();
      case 1:
        return const _StudyPlannerTool();
      case 2:
        return const _AiTutorTool();
      case 3:
        return const _PomodoroTimerTool();
      case 4:
        return const _BookmarksAndNotesTool();
      default:
        return const _OfficialCalendarTool();
    }
  }
}

class _AverageCalculatorTool extends StatefulWidget {
  const _AverageCalculatorTool();

  @override
  State<_AverageCalculatorTool> createState() => _AverageCalculatorToolState();
}

class _AverageCalculatorToolState extends State<_AverageCalculatorTool> {
  final Map<String, double> _marks = {};
  double? _calculatedAvg;

  String _mentionFor(double avg, AppController ctrl) {
    if (avg >= 16) return ctrl.tr('تقدير: جيد جداً 🌟 (Très Bien)', 'Très Bien 🌟');
    if (avg >= 14) return ctrl.tr('تقدير: جيد 👏 (Bien)', 'Bien 👏');
    if (avg >= 12) return ctrl.tr('تقدير: قريب من الجيد / حسن (Assez Bien)', 'Assez Bien');
    if (avg >= 10) return ctrl.tr('تقدير: مقبول ✅ (Passable)', 'Passable ✅');
    return ctrl.tr('دون المعدل — واصل الاجتهاد وستنجح بإذن الله 💪', 'Ajourné');
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final subjects = ctrl.subjectsForCurrentProfile();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFFE8F5E9),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'المستوى الحالي: ${ctrl.levelLabel(ctrl.currentProfile.levelCode)} '
              '${ctrl.currentProfile.streamCode.isNotEmpty ? "• ${ctrl.streamLabel(ctrl.currentProfile.streamCode)}" : ""}\n'
              'أدخل علامة كل مادة من 20 وسيتم ضربها تلقائياً في المعامل الرسمي.',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF075E2F),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final s in subjects)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '${s['emoji']} ${ctrl.tr(s['ar'] as String, s['fr'] as String)} '
                    '(معامل ${ctrl.getSubjectCoefficient(s['id'] as String)})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: (_marks[s['id']] ?? 14.0).toString(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      suffixText: '/ 20',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) {
                        _marks[s['id'] as String] = parsed.clamp(0.0, 20.0);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0B7A3E),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: () {
            double weightedSum = 0;
            int totalCoeff = 0;
            for (final s in subjects) {
              final id = s['id'] as String;
              final coeff = ctrl.getSubjectCoefficient(id);
              final mark = _marks[id] ?? 14.0;
              weightedSum += mark * coeff;
              totalCoeff += coeff;
            }
            final avg = totalCoeff == 0 ? 0.0 : weightedSum / totalCoeff;
            setState(() => _calculatedAvg = avg);
            ctrl.currentProfile.averageHistory.insert(0, {
              'level': ctrl.currentProfile.levelCode,
              'avg': avg.toStringAsFixed(2),
              'date': DateTime.now().toIso8601String().substring(0, 10),
            });
            ctrl.saveState();
          },
          icon: const Icon(Icons.calculate),
          label: Text(ctrl.tr('احسب المعدل الآن', 'Calculer la moyenne')),
        ),
        if (_calculatedAvg != null) ...[
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFFFFF8E1),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    'المعدل العام: ${_calculatedAvg!.toStringAsFixed(2)} / 20',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0B7A3E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _mentionFor(_calculatedAvg!, ctrl),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (ctrl.currentProfile.averageHistory.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            ctrl.tr('سجل المعدلات المحفوظة:', 'Historique des calculs :'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          for (final h in ctrl.currentProfile.averageHistory.take(5))
            ListTile(
              dense: true,
              leading: const Icon(Icons.bookmark_added, color: Color(0xFF0B7A3E)),
              title: Text('المعدل: ${h['avg']} / 20 (${h['level']})'),
              subtitle: Text('${h['date']}'),
            ),
        ],
      ],
    );
  }
}

class _StudyPlannerTool extends StatelessWidget {
  const _StudyPlannerTool();

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final p = ctrl.currentProfile;
    final weak = p.weakSubjects;
    final daysAr = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final allSubjs = ctrl.subjectsForCurrentProfile();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.event, color: Color(0xFF0B7A3E)),
            title: Text(
              ctrl.tr(
                'تاريخ الامتحان المستهدف: ${p.targetExamDate}',
                'Date de l\'examen : ${p.targetExamDate}',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              ctrl.tr('اضغط لتغيير التاريخ وإعادة توليد البرنامج الذكي', 'Modifier la date'),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    DateTime.tryParse(p.targetExamDate) ?? DateTime(2027, 6, 7),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                p.targetExamDate = picked.toIso8601String().substring(0, 10);
                ctrl.saveState();
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          ctrl.tr(
            'جدول المراجعة الأسبوعي الذكي (يركز على نقاط ضعفك ومعاملاتك):',
            'Planning hebdomadaire adapté à vos points faibles :',
          ),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < daysAr.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0B7A3E),
                foregroundColor: Colors.white,
                child: Text('${i + 1}'),
              ),
              title: Text(
                daysAr[i],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'الفترة 1 (تركيز): ${ctrl.subjectName(weak[i % weak.length])} (45 د)\n'
                'الفترة 2 (مراجعة): ${ctrl.subjectName(allSubjs[i % allSubjs.length]['id'] as String)} (30 د)',
              ),
            ),
          ),
      ],
    );
  }
}

class _AiTutorTool extends StatefulWidget {
  const _AiTutorTool();

  @override
  State<_AiTutorTool> createState() => _AiTutorToolState();
}

class _AiTutorToolState extends State<_AiTutorTool> {
  final _msgCtrl = TextEditingController();
  final List> _messages = [
    {
      'role': 'ai',
      'text':
          'مرحباً بك! أنا أستاذك الذكي في ستدي دي زد 🤖🇩🇿.\nاسألني بالعربية أو الفرنسية أو الدارجة حول أي درس أو تمرين!',
    },
  ];
  bool _loading = false;

  Future<void> _sendMessage(AppController ctrl) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });

    if (ctrl.geminiApiKey.trim().isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _loading = false;
        _messages.add({
          'role': 'ai',
          'text': _offlineSmartAnswer(text, ctrl),
        });
      });
      return;
    }

    try {
      final client = HttpClient();
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${ctrl.geminiApiKey.trim()}',
      );
      final req = await client.postUrl(uri);
      req.headers.set('Content-Type', 'application/json; charset=utf-8');
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'أنت أستاذ جزائري خبير لطيف تساعد تلاميذ الجزائر (${ctrl.currentProfile.levelCode}). أجب بوضوح واختصار: $text',
              }
            ]
          }
        ]
      });
      req.add(utf8.encode(body));
      final resp = await req.close().timeout(const Duration(seconds: 15));
      final respBody = await resp.transform(utf8.decoder).join();
      final decoded = jsonDecode(respBody);
      final reply = decoded['candidates']?[0]?['content']?['parts']?[0]?['text']
              ?.toString() ??
          _offlineSmartAnswer(text, ctrl);
      setState(() {
        _loading = false;
        _messages.add({'role': 'ai', 'text': reply});
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _messages.add({
          'role': 'ai',
          'text':
              'تعذر الاتصال بالإنترنت حالياً. إليك الشرح المحلي بدون إنترنت:\n\n${_offlineSmartAnswer(text, ctrl)}',
        });
      });
    }
  }

  String _offlineSmartAnswer(String query, AppController ctrl) {
    final q = query.toLowerCase();
    for (final l in ctrl.lessons) {
      final title = (l['title_ar'] ?? '').toString();
      if (q.contains('معادل') || q.contains('pgcd') || title.contains(query)) {
        return '📘 من دروس التطبيق (${l['title_ar']}):\n${l['summary_ar']}\n\n(ملاحظة: لتفعيل الذكاء الاصطناعي السحابي المباشر، يمكنك لصق مفتاح Gemini المجاني في الإعدادات بحسابي).';
      }
    }
    return '💡 نصيحة منهجية لسؤالك:\n1) حدد المعطيات والمطلوب بدقة.\n2) اكتب القانون الحرفي قبل التطبيق العددي.\n3) يمكنك لصق مفتاح Gemini API المجاني من قسم (حسابي > الإعدادات) للحصول على إجابات ذكية مخصصة عند توفر الإنترنت.';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: const Color(0xFFFFF8E1),
          child: Text(
            ctrl.tr(
              '⚠️ تنبيه: إجابات الذكاء الاصطناعي قد تحتمل الخطأ، راجع دائماً دروسك الرسمية.',
              '⚠️ Les réponses de l\'IA peuvent contenir des erreurs.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6D4C00)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, idx) {
              final m = _messages[idx];
              final isUser = m['role'] == 'user';
              return Align(
                alignment: isUser
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  constraints: const BoxConstraints(maxWidth: 310),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF0B7A3E)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    m['text'] ?? '',
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF103820),
                      height: 1.45,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  decoration: InputDecoration(
                    hintText: ctrl.tr(
                      'اكتب سؤالك هنا (بالعربية، الفرنسية أو الدارجة)...',
                      'Posez votre question...',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A3E),
                ),
                onPressed: () => _sendMessage(ctrl),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PomodoroTimerTool extends StatefulWidget {
  const _PomodoroTimerTool();

  @override
  State<_PomodoroTimerTool> createState() => _PomodoroTimerToolState();
}

class _PomodoroTimerToolState extends State<_PomodoroTimerTool> {
  int _secondsLeft = 25 * 60;
  bool _running = false;
  String _selectedSubject = 'math';
  Timer? _timer;

  void _toggleTimer(AppController ctrl) {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft <= 1) {
          _timer?.cancel();
          ctrl.recordStudyProgress(
            subjectId: _selectedSubject,
            minutesAdded: 25,
            xpAdded: 50,
          );
          if (mounted) {
            setState(() {
              _running = false;
              _secondsLeft = 25 * 60;
            });
          }
        } else if (mounted) {
          setState(() => _secondsLeft--);
        }
      });
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
    final mins = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsLeft % 60).toString().padLeft(2, '0');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String>(
          value: _selectedSubject,
          decoration: InputDecoration(
            labelText: ctrl.tr('المادة قيد المراجعة', 'Matière étudiée'),
            border: const OutlineInputBorder(),
          ),
          items: ctrl
              .subjectsForCurrentProfile()
              .map(
                (s) => DropdownMenuItem<String>(
                  value: s['id'] as String,
                  child: Text(
                      '${s['emoji']} ${ctrl.tr(s['ar'] as String, s['fr'] as String)}'),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedSubject = v);
          },
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0B7A3E), width: 8),
            ),
            child: Center(
              child: Text(
                '$mins:$secs',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0B7A3E),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A3E),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () => _toggleTimer(ctrl),
              icon: Icon(_running ? Icons.pause : Icons.play_arrow),
              label: Text(_running ? 'إيقاف مؤقت' : 'بدء جلسة التركيز'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                _timer?.cancel();
                setState(() {
                  _running = false;
                  _secondsLeft = 25 * 60;
                });
              },
              child: const Text('إعادة ضبط'),
            ),
          ],
        ),
      ],
    );
  }
}

class _BookmarksAndNotesTool extends StatelessWidget {
  const _BookmarksAndNotesTool();

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final p = ctrl.currentProfile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          ctrl.tr('العناصر المحفوظة (Bookmarks):', 'Éléments enregistrés :'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (p.bookmarks.isEmpty)
          Text(ctrl.tr('لم تقم بحفظ أي درس أو موضوع بعد.', 'Aucun favori.'))
        else
          for (final b in p.bookmarks)
            Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark, color: Color(0xFF0B7A3E)),
                title: Text(b),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ctrl.toggleBookmark(b),
                ),
              ),
            ),
        const SizedBox(height: 20),
        Text(
          ctrl.tr('ملاحظاتي الشخصية:', 'Mes notes personnelles :'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (p.notes.isEmpty)
          Text(ctrl.tr('لا توجد ملاحظات مكتوبة بعد.', 'Aucune note.'))
        else
          for (final entry in p.notes.entries)
            Card(
              child: ListTile(
                leading: const Icon(Icons.note, color: Color(0xFFF5B800)),
                title: Text(entry.value),
                subtitle: Text('المعرف: ${entry.key}'),
              ),
            ),
      ],
    );
  }
}

class _OfficialCalendarTool extends StatelessWidget {
  const _OfficialCalendarTool();

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF5B800)),
          ),
          child: Text(
            ctrl.tr(
              '⚠️ تنبيه هام: هذه التواريخ استرشادية ويجب التحقق دائماً من الرزنامة الرسمية الصادرة عن وزارة التربية الوطنية والديوان الوطني للامتحانات والمسابقات (ONEC).',
              '⚠️ Vérifiez toujours les dates officielles auprès du Ministère et de l\'ONEC.',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6D4C00),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final ev in ctrl.calendarEvents)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Text('📆', style: TextStyle(fontSize: 28)),
              title: Text(
                ev['title_ar']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('التاريخ: ${ev['date']}'),
              trailing: Chip(
                label: Text(ev['badge_ar']?.toString() ?? ''),
              ),
            ),
          ),
      ],
    );
  }
}
