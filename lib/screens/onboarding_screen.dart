import 'package:flutter/material.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _creatingAccount = false;

  final _nameCtrl = TextEditingController(text: 'أمين');
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _selectedCycle = 'moyen';
  String _selectedLevel = '3AM';
  String _selectedStream = 'SE';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  List> _levelsForCycle(String cycle) {
    return AppController.allLevels.where((l) => l['cycle'] == cycle).toList();
  }

  void _completeOnboarding(AppController ctrl) {
    final studentName =
        _nameCtrl.text.trim().isEmpty ? 'تلميذ النجاح' : _nameCtrl.text.trim();
    ctrl.isGuest = !_creatingAccount;
    if (_creatingAccount) {
      ctrl.accountName = studentName;
      ctrl.accountEmail = _emailCtrl.text.trim();
      ctrl.accountPassword = _passCtrl.text.trim();
    }

    final needsStream = _selectedLevel == '1AS' ||
        _selectedLevel == '2AS' ||
        _selectedLevel == '3AS' ||
        _selectedLevel == '3AS_LIBRE';

    final profile = StudentProfile(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: studentName,
      levelCode: _selectedLevel,
      streamCode: needsStream ? _selectedStream : '',
    );

    ctrl.profiles = [profile];
    ctrl.activeProfileIndex = 0;
    ctrl.hasCompletedOnboarding = true;
    ctrl.saveState();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF065A2C), Color(0xFF0B7A3E), Color(0xFF14944F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _step == 0
              ? _buildWelcomeStep(ctrl)
              : _buildProfileSetupStep(ctrl),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep(AppController ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
              ),
              onPressed: () {
                ctrl.languageCode = ctrl.languageCode == 'ar' ? 'fr' : 'ar';
                ctrl.saveState();
              },
              icon: const Icon(Icons.language, size: 18),
              label: Text(ctrl.languageCode == 'ar' ? 'Français' : 'العربية'),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 145,
            height: 145,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF5B800), width: 3),
            ),
            child: const Center(
              child: Text(
                '🇩🇿🎓\n📚⏱️',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 44, height: 1.2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ستدي دي زد',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
              children: [
                TextSpan(text: 'Study ', style: TextStyle(color: Colors.white)),
                TextSpan(
                  text: 'DZ',
                  style: TextStyle(color: Color(0xFFF5B800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ctrl.tr(
              'معاً نحو التفوق والنجاح في جميع الأطوار التعليمية بالجزائر\n(الابتدائي • المتوسط BEM • الثانوي BAC)',
              'Ensemble vers la réussite scolaire en Algérie\n(Primaire • Moyen BEM • Secondaire BAC)',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ctrl.tr(
                    'ابدأ رحلتك الدراسية الآن (100% بدون إنترنت)',
                    'Commencez maintenant (100% Hors-ligne)',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0B7A3E),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _creatingAccount = false;
                      _step = 1;
                    });
                  },
                  icon: const Icon(Icons.rocket_launch),
                  label: Text(
                    ctrl.tr(
                      'المتابعة كضيف (كل الميزات مفتوحة)',
                      'Continuer en tant qu\'invité',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B7A3E),
                    side: const BorderSide(color: Color(0xFF0B7A3E), width: 1.8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _creatingAccount = true;
                      _step = 1;
                    });
                  },
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(
                    ctrl.tr(
                      'إنشاء حساب محلي (اختياري لحفظ النسخ)',
                      'Créer un compte local (Optionnel)',
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSetupStep(AppController ctrl) {
    final cycleLevels = _levelsForCycle(_selectedCycle);
    final is1AS = _selectedLevel == '1AS';
    final is2ASor3AS = _selectedLevel == '2AS' ||
        _selectedLevel == '3AS' ||
        _selectedLevel == '3AS_LIBRE';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _step = 0),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0B7A3E)),
                ),
                Expanded(
                  child: Text(
                    ctrl.tr('اختر المستوى الدراسي', 'Choisissez votre niveau'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0B7A3E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: ctrl.tr('اسم التلميذ(ة)', 'Prénom de l\'élève'),
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (_creatingAccount) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: ctrl.tr(
                    'البريد الإلكتروني (اختياري)',
                    'E-mail (Optionnel)',
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: ctrl.tr(
                    'كلمة المرور المحلية (اختياري)',
                    'Mot de passe local (Optionnel)',
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              ctrl.tr('1. اختر الطور التعليمي:', '1. Choisissez le cycle :'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            _buildCycleCard(
              cycleCode: 'primaire',
              title: ctrl.tr('الابتدائي', 'Primaire'),
              subtitle: ctrl.tr(
                'من السنة الأولى إلى الخامسة (5ème)',
                'De la 1AP à la 5AP',
              ),
              emoji: '🎒',
              bgColor: const Color(0xFFE3F2FD),
            ),
            const SizedBox(height: 8),
            _buildCycleCard(
              cycleCode: 'moyen',
              title: ctrl.tr('المتوسط (CEM)', 'Moyen (CEM)'),
              subtitle: ctrl.tr(
                'من السنة الأولى إلى الرابعة (BEM)',
                'De la 1AM à la 4AM (BEM)',
              ),
              emoji: '📚',
              bgColor: const Color(0xFFE8F5E9),
            ),
            const SizedBox(height: 8),
            _buildCycleCard(
              cycleCode: 'secondaire',
              title: ctrl.tr('الثانوي', 'Secondaire (Lycée)'),
              subtitle: ctrl.tr(
                'من السنة الأولى إلى الثالثة (BAC)',
                'De la 1AS à la 3AS (BAC)',
              ),
              emoji: '🎓',
              bgColor: const Color(0xFFEDE7F6),
            ),
            const SizedBox(height: 16),
            Text(
              ctrl.tr('2. اختر السنة الدراسية:', '2. Choisissez l\'année :'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: cycleLevels.any((e) => e['code'] == _selectedLevel)
                  ? _selectedLevel
                  : cycleLevels.first['code'],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: cycleLevels
                  .map(
                    (lvl) => DropdownMenuItem<String>(
                      value: lvl['code'],
                      child: Text(ctrl.tr(lvl['ar']!, lvl['fr']!)),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _selectedLevel = val;
                  if (_selectedLevel == '1AS') {
                    _selectedStream = 'TC_ST';
                  } else if (_selectedLevel == '2AS' ||
                      _selectedLevel == '3AS' ||
                      _selectedLevel == '3AS_LIBRE') {
                    _selectedStream = 'SE';
                  }
                });
              },
            ),
            if (is1AS || is2ASor3AS) ...[
              const SizedBox(height: 16),
              Text(
                ctrl.tr('3. اختر الشعبة / الجذع المشترك:', '3. Choisissez la filière :'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStream,
                decoration: InputDecoration(
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
                    setState(() => _selectedStream = val);
                  }
                },
              ),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A3E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _completeOnboarding(ctrl),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                ctrl.tr('دخول إلى التطبيق الآن', 'Accéder à Study DZ'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleCard({
    required String cycleCode,
    required String title,
    required String subtitle,
    required String emoji,
    required Color bgColor,
  }) {
    final selected = _selectedCycle == cycleCode;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _selectedCycle = cycleCode;
          final lvls = _levelsForCycle(cycleCode);
          _selectedLevel = lvls.first['code']!;
          if (_selectedLevel == '1AS') {
            _selectedStream = 'TC_ST';
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF0B7A3E) : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: Color(0xFF1A2520),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF425248),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: const Color(0xFF0B7A3E),
            ),
          ],
        ),
      ),
    );
  }
}
