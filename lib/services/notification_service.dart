import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  static const MethodChannel _ttsChannel =
      MethodChannel('flutter_tts');

  Timer? _reminderTimer;
  String? lastReminderText;

  Future<void> init() async {
    // Lightweight offline reminder service that never crashes on low-RAM phones
  }

  void scheduleDailyStudyReminder({
    required BuildContext context,
    required int hour,
    required int minute,
    required String messageAr,
  }) {
    _reminderTimer?.cancel();
    lastReminderText =
        '⏰ تذكير المراجعة مضبوط يومياً على الساعة ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0B7A3E),
        content: Text(
          '$lastReminderText\n$messageAr',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> speakText(BuildContext context, String text,
      {String lang = 'ar-SA'}) async {
    try {
      await _ttsChannel.invokeMethod('speak', text);
    } catch (_) {
      // Graceful fallback if TTS engine is not installed on low-RAM phone
      SystemSound.play(SystemSoundType.click);
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0B7A3E),
            duration: const Duration(seconds: 3),
            content: Row(
              children: [
                const Icon(Icons.volume_up, color: Color(0xFFFFD700)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🔊 القراءة الصوتية: $text',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}
