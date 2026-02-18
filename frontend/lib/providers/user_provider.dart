import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

/// Global state holder for the authenticated user session.
/// Wraps MaterialApp via ChangeNotifierProvider so every screen
/// can read/write token, profile data, and vitals without prop-drilling.
class UserProvider extends ChangeNotifier {
  String? _token;
  String _name = 'Patient';
  String _role = 'patient'; // 'patient' or 'doctor'
  int _age = 30;
  String _bloodType = 'O+';
  String _conditions = '';
  String _allergies = '';
  int? _lastBpm;

  // ── Getters ──
  String? get token => _token;
  String get name => _name;
  String get role => _role;
  int get age => _age;
  String get bloodType => _bloodType;
  String get conditions => _conditions;
  String get allergies => _allergies;
  int? get lastBpm => _lastBpm;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  bool get isDoctor => _role == 'doctor';

  // ── Setters ──
  void setProfile({
    required String token,
    required String name,
    String role = 'patient',
    int age = 30,
    String bloodType = 'O+',
    String conditions = '',
    String allergies = '',
  }) {
    _token = token;
    _name = name;
    _role = role;
    _age = age;
    _bloodType = bloodType;
    _conditions = conditions;
    _allergies = allergies;
    ApiService.token = token;
    notifyListeners();
  }

  void updateBpm(int bpm) {
    _lastBpm = bpm;
    notifyListeners();
  }

  // ── Token Persistence ──
  Future<void> persistToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token ?? '');
    await prefs.setString('name', _name);
    await prefs.setString('role', _role);
    await prefs.setInt('age', _age);
    await prefs.setString('bloodType', _bloodType);
    await prefs.setString('conditions', _conditions);
  }

  /// Returns true if a saved session was restored.
  Future<bool> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('token');
    if (saved != null && saved.isNotEmpty) {
      _token = saved;
      _name = prefs.getString('name') ?? 'Patient';
      _role = prefs.getString('role') ?? 'patient';
      _age = prefs.getInt('age') ?? 30;
      _bloodType = prefs.getString('bloodType') ?? 'O+';
      _conditions = prefs.getString('conditions') ?? '';
      ApiService.token = _token;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _name = 'Patient';
    _role = 'patient';
    _lastBpm = null;
    ApiService.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
