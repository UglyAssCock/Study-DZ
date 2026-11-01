import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final p = ctrl.currentProfile;

    final badges = [
      {'emoji': '🌟', 'title': 'بداية موفقة', 'unlocked': p.xp >= 100},
      {'emoji': '🔥', 'title': 'مواظب 7 أيام', 'unlocked': p.streakDays >= 7},
      {'emoji': '🧮', 'title': 'بطل الرياضيات', 'unlocked': (p.subjectMinutes['math'] ?? 0) >= 30},
      {'emoji': '🎓', 'title': 'نجم الامتحانات', 'unlocked': p.xp >= 500},
    ];

    final sortedProfiles = [...ctrl.profiles]
      ..sort((a, b) => b.xp.compareTo(a.xp));

    return Scaffold(
      appBar: AppBar(
        title: Text(ctrl.tr('حسابي والإعدادات', 'Mon Profil & Paramètres')),
        actions: [
          IconButton(
            tooltip: ctrl.tr('فضاء الأولياء (محمي بـ PIN)', 'Mode Parent'),
            icon: const Icon(Icons.family_restroom),
            onPressed: () => _openParentModePinDialog(context, ctrl),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF0B7A3E),
                        child: Text(
                          p.name.characters.first,
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(ctrl.levelLabel(p.levelCode)),
                            Text(
                              'المستوى ${p.levelNumber} • ${p.xp} XP • ${ctrl.isGuest ? "وضع الضيف" : "حساب محلي مرتبط"}',
                              style: const TextStyle(
                                color: Color(0xFF0B7A3E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: ctrl.tr('إضافة ملف تلميذ آخر', 'Ajouter un profil'),
                        icon: const Icon(Icons.person_add_alt_1),
                        onPressed: () => _showAddProfileDialog(context, ctrl),
                      ),
                    ],
                  ),
                  if (ctrl.profiles.length > 1) ...[
                    const Divider(height: 24),
                    Wrap(
                      spacing: 8,
                      children: List.generate(ctrl.profiles.length, (i) {
                        final prof = ctrl.profiles[i];
                        return ChoiceChip(
                          label: Text('${prof.name} (${prof.levelCode})'),
                          selected: ctrl.activeProfileIndex == i,
                          onSelected: (_) {
                            ctrl.activeProfileIndex = i;
                            ctrl.saveState();
                          },
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            ctrl.tr('الأوسمة والشارات المكتسبة:', 'Badges débloqués :'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: badges.map((b) {
              final unlocked = b['unlocked'] == true;
              return Expanded(
                child: Card(
                  color: unlocked ? null : Colors.grey.withValues(alpha: 0.15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          b['emoji'].toString(),
                          style: TextStyle(
                            fontSize: 28,
                            color: unlocked ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b['title'].toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            ctrl.tr('مخطط وقت الدراسة حسب المادة (بالدقائق):', 'Temps d\'étude par matière :'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 150,
                child: CustomPaint(
                  painter: _StudyBarChartPainter(
                    data: p.subjectMinutes,
                    isDark: ctrl.isDarkMode,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ctrl.tr('ترتيب الإخوة والتلاميذ على هذا الهاتف:', 'Classement local :'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < sortedProfiles.length; i++)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: i == 0
                      ? const Color(0xFFF5B800)
                      : const Color(0xFF0B7A3E),
                  foregroundColor: Colors.white,
                  child: Text('#${i + 1}'),
                ),
                title: Text(sortedProfiles[i].name),
                subtitle: Text(sortedProfiles[i].levelCode),
                trailing: Text(
                  '${sortedProfiles[i].xp} XP',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            ctrl.tr('الإعدادات والتخصيص:', 'Paramètres :'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                if (ctrl.isGuest)
                  ListTile(
                    leading: const Icon(Icons.link, color: Color(0xFF0B7A3E)),
                    title: Text(
                      ctrl.tr(
                        'ربط الحساب لاحقاً (دون فقدان تقدمك)',
                        'Lier un compte maintenant',
                      ),
                    ),
                    subtitle: Text(
                      ctrl.tr(
                        'تحويل وضع الضيف إلى حساب محلي محفوظ',
                        'Convertir le profil invité en compte local',
                      ),
                    ),
                    onTap: () => _showLinkAccountDialog(context, ctrl),
                  ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(ctrl.tr('الوضع الليلي المظلم', 'Mode Sombre')),
                  value: ctrl.isDarkMode,
                  onChanged: (v) {
                    ctrl.isDarkMode = v;
                    ctrl.saveState();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(ctrl.tr('لغة التطبيق', 'Langue de l\'application')),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'ar', label: Text('العربية')),
                      ButtonSegment(value: 'fr', label: Text('Français')),
                    ],
                    selected: {ctrl.languageCode},
                    onSelectionChanged: (s) {
                      ctrl.languageCode = s.first;
                      ctrl.saveState();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.format_size),
                      const SizedBox(width: 14),
                      Text(ctrl.tr('حجم الخط', 'Taille de police')),
                      Expanded(
                        child: Slider(
                          value: ctrl.fontScale,
                          min: 0.85,
                          max: 1.30,
                          divisions: 9,
                          label: '${(ctrl.fontScale * 100).round()}%',
                          onChanged: (v) {
                            ctrl.fontScale = v;
                            ctrl.saveState();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: Text(ctrl.tr('تذكيرات المراجعة اليومية', 'Rappels quotidiens')),
                  value: ctrl.notificationsEnabled,
                  onChanged: (v) {
                    ctrl.notificationsEnabled = v;
                    ctrl.saveState();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.key),
                  title: Text(ctrl.tr('مفتاح Gemini API للمساعد الذكي', 'Clé API Gemini')),
                  subtitle: Text(
                    ctrl.geminiApiKey.isEmpty
                        ? ctrl.tr('غير مضاف (يعمل بالوضع المحلي)', 'Non configurée')
                        : '••••••••••••',
                  ),
                  onTap: () => _showApiKeyDialog(context, ctrl),
                ),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: Text(
                    ctrl.tr('نسخ احتياطي واستعادة البيانات (JSON)', 'Sauvegarde & Restauration'),
                  ),
                  onTap: () => _showBackupDialog(context, ctrl),
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: Text(ctrl.tr('مشاركة التطبيق وإرسال ملاحظة', 'Partager l\'application')),
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(
                        text: 'تطبيق ستدي دي زد (Study DZ) للدراسة في الجزائر بدون إنترنت 🇩🇿🎓',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ رسالة المشاركة للحافظة!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(ctrl.tr('حول التطبيق وإخلاء المسؤولية', 'À propos & Mentions')),
                  onTap: () => _showAboutDialog(context, ctrl),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(
                    ctrl.tr('إعادة ضبط ومسح جميع البيانات', 'Réinitialiser les données'),
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () => ctrl.resetAllData(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openParentModePinDialog(BuildContext context, AppController ctrl) {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctrl.tr('فضاء الأولياء (الرمز السري 1234)', 'Mode Parent (PIN)')),
        content: TextField(
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'أدخل رمز PIN المكون من 4 أرقام',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (pinCtrl.text.trim() == ctrl.parentPin) {
                Navigator.pop(ctx);
                _showParentDashboard(context, ctrl);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('رمز PIN غير صحيح (الافتراضي: 1234)')),
                );
              }
            },
            child: const Text('دخول'),
          ),
        ],
      ),
    );
  }

  void _showParentDashboard(BuildContext context, AppController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '👨‍👩‍👧‍👦 لوحة متابعة الأولياء',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              for (final prof in ctrl.profiles)
                Card(
                  child: ListTile(
                    title: Text(
                      '${prof.name} (${prof.levelCode})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'وقت الدراسة اليوم: ${prof.todayStudyMinutes} / ${prof.dailyGoalMinutes} د\n'
                      'المواد الضعيفة: ${prof.weakSubjects.map((s) => ctrl.subjectName(s)).join("، ")}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.flag, color: Color(0xFF0B7A3E)),
                      onPressed: () {
                        prof.dailyGoalMinutes =
                            prof.dailyGoalMinutes == 45 ? 60 : 45;
                        ctrl.saveState();
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddProfileDialog(BuildContext context, AppController ctrl) {
    final nameCtrl = TextEditingController();
    String lvl = '5AP';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة ملف تلميذ جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'اسم التلميذ(ة)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: lvl,
              items: AppController.allLevels
                  .map(
                    (e) => DropdownMenuItem(
                      value: e['code'],
                      child: Text(e['ar']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) lvl = v;
              },
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              ctrl.profiles.add(
                StudentProfile(
                  id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim().isEmpty
                      ? 'تلميذ جديد'
                      : nameCtrl.text.trim(),
                  levelCode: lvl,
                ),
              );
              ctrl.activeProfileIndex = ctrl.profiles.length - 1;
              ctrl.saveState();
              Navigator.pop(ctx);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showLinkAccountDialog(BuildContext context, AppController ctrl) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ربط الحساب المحلي'),
        content: TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني (اختياري)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              ctrl.isGuest = false;
              ctrl.accountName = ctrl.currentProfile.name;
              ctrl.accountEmail = emailCtrl.text.trim();
              ctrl.saveState();
              Navigator.pop(ctx);
            },
            child: const Text('ربط وحفظ التقدم'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, AppController ctrl) {
    final keyCtrl = TextEditingController(text: ctrl.geminiApiKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعداد مفتاح Google Gemini API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'للحصول على مفتاح مجاني: افتح aistudio.google.com ثم اضغط Get API Key والصقه هنا (يُحفظ في هاتفك فقط).',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: keyCtrl,
              decoration: const InputDecoration(
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              ctrl.geminiApiKey = keyCtrl.text.trim();
              ctrl.saveState();
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context, AppController ctrl) {
    final jsonCtrl = TextEditingController(text: ctrl.exportBackupJson());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('النسخ الاحتياطي والاستعادة (JSON)'),
        content: TextField(
          controller: jsonCtrl,
          maxLines: 8,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonCtrl.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ النسخة الاحتياطية!')),
              );
            },
            child: const Text('نسخ'),
          ),
          FilledButton(
            onPressed: () {
              ctrl.restoreFromBackupJson(jsonCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('استعادة'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppController ctrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حول ستدي دي زد (Study DZ)'),
        content: const Text(
          'تطبيق تعليمي مجاني ومستقل لمرافقة التلاميذ الجزائريين في الأطوار الثلاثة (الابتدائي، المتوسط، الثانوي).\n\n'
          'إخلاء مسؤولية هام:\n'
          'هذا التطبيق غير رسمي وغير تابع لوزارة التربية الوطنية الجزائرية ولا للديوان الوطني للامتحانات والمسابقات (ONEC).',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _StudyBarChartPainter extends CustomPainter {
  final Map<String, int> data;
  final bool isDark;

  _StudyBarChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final entries = data.entries.toList();
    if (entries.isEmpty) return;

    int maxVal = 10;
    for (final e in entries) {
      if (e.value > maxVal) maxVal = e.value;
    }

    final barWidth = (size.width / (entries.length * 2)).clamp(16.0, 44.0);
    final paint = Paint()
      ..color = const Color(0xFF0B7A3E)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < entries.length; i++) {
      final ratio = entries[i].value / maxVal;
      final barHeight = (size.height - 36) * ratio;
      final x = (i * 2 + 0.5) * barWidth;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - 24 - barHeight, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);

      final tp = TextPainter(
        text: TextSpan(
          text: '${entries[i].value}د',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, Offset(x, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant _StudyBarChartPainter oldDelegate) => true;
}
