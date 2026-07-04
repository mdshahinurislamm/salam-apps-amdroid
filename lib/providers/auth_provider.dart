import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

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
  String get token => _user?.accessToken ?? '';

  // ── Session persistence ───────────────────────────────────────────────────

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
    } catch (_) {}
  }

  Future<void> _persistUser() async {
    if (_user == null) return;
    try {
      final file = await _sessionFile();
      await file.writeAsString(jsonEncode(_user!.toJson()));
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
    required String lastName,
    required String email,
    required String password,
    required String age,
    required String country,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        age: age,
        country: country,
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

  // ── Profile actions ───────────────────────────────────────────────────────

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String age,
    required String country,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _api.updateProfile(
        token: token,
        firstName: firstName,
        lastName: lastName,
        email: email,
        age: age,
        country: country,
      );
      // Preserve the token from the existing session
      _user = updated.copyWith(accessToken: token);
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

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.changePassword(
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.deleteProfile(token: token);
      _user = null;
      await _clearSession();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update local user data without API call (e.g. after profile fetch)
  void setUser(UserModel u) {
    _user = u;
    _persistUser();
    notifyListeners();
  }
}
