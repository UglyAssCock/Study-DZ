import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAccount {
  final String name;
  final String? email;
  final String? passwordHash;
  final bool isGuest;

  LocalAccount({
    required this.name,
    this.email,
    this.passwordHash,
    required this.isGuest,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'isGuest': isGuest,
      };

  factory LocalAccount.fromJson(Map<String, dynamic> json) => LocalAccount(
        name: json['name'] as String? ?? 'ضيف',
        email: json['email'] as String?,
        passwordHash: json['passwordHash'] as String?,
        isGuest: json['isGuest'] as bool? ?? true,
      );
}

/// AuthService manages optional local accounts and guest sessions.
/// Designed cleanly so future cloud authentication (e.g. Google Sign-In or Supabase)
/// can be plugged into [linkAccountLater] and [createAccount] without changing UI code.
class AuthService {
  static const String _accountKey = 'study_dz_local_account';

  Future<LocalAccount?> getCurrentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountKey);
    if (raw == null) return null;
    try {
      return LocalAccount.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<LocalAccount> continueAsGuest({String defaultName = 'تلميذ ستدي دي زد'}) async {
    final account = LocalAccount(name: defaultName, isGuest: true);
    await _saveAccount(account);
    return account;
  }

  Future<LocalAccount> createAccount({
    required String name,
    String? email,
    String? password,
  }) async {
    final account = LocalAccount(
      name: name.trim().isEmpty ? 'تلميذ ستدي دي زد' : name.trim(),
      email: email?.trim(),
      passwordHash: password != null && password.isNotEmpty
          ? base64Encode(utf8.encode(password))
          : null,
      isGuest: false,
    );
    await _saveAccount(account);
    return account;
  }

  /// Links a guest session to a full local account without losing any study progress.
  Future<LocalAccount> linkAccountLater({
    required String name,
    String? email,
    String? password,
  }) async {
    return createAccount(name: name, email: email, password: password);
  }

  Future<void> _saveAccount(LocalAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountKey, jsonEncode(account.toJson()));
  }
}
