import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

/// Auth state — persists user to a plain JSON file in the app's cache dir.
/// No third-party storage plugin needed; uses a MethodChannel to get the
/// cache directory path from Android directly.
class AuthProvider extends ChangeNotifier {
  static const _platform =
      MethodChannel('com.example.flutter_application_1/paths');

  final ApiService _api = ApiService();

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // ── Storage helpers ───────────────────────────────────────────────────────

  Future<File> _sessionFile() async {
    final dir = await _platform.invokeMethod<String>('getCacheDir');
    return File('$dir/session.json');
  }

  Future<void> tryRestoreSession() async {
    try {
      final file = await _sessionFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        _user = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (_) {
      // corrupt / missing file — stay logged out
    }
  }

  Future<void> _persistUser() async {
    if (_user == null) return;
    try {
      final file = await _sessionFile();
      await file.writeAsString(
        jsonEncode({
          'id': _user!.id,
          'first_name': _user!.firstName,
          'last_name': _user!.lastName,
          'email': _user!.email,
          'role': _user!.role,
        }),
      );
    } catch (_) {}
  }

  Future<void> _clearSession() async {
    try {
      final file = await _sessionFile();
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  // ── Auth actions ──────────────────────────────────────────────────────────

  Future<bool> register({
    required String firstName,
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _api.register(
        firstName: firstName,
        email: email,
        password: password,
      );
      await _persistUser();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _api.login(email: email, password: password);
      await _persistUser();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await _clearSession();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
