import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Unified API client for all Lifeline AI backend communication.
/// Every method is wrapped in try/catch with a [MockData] fallback
/// so the app NEVER crashes — even if the backend is completely offline.
class ApiService {
  // ─── Base URL (auto-detect platform) ───
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    // Android emulator uses 10.0.2.2 to reach host machine's localhost
    return 'http://10.0.2.2:8000';
  }

  static String get _wsBase {
    if (kIsWeb) return 'ws://localhost:8000';
    return 'ws://10.0.2.2:8000';
  }

  /// Stored auth token — set after login/register.
  static String? _token;
  static String? get token => _token;
  static set token(String? t) => _token = t;

  /// Common headers with optional Bearer auth.
  static Map<String, String> get _headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  // ═══════════════════════════════════════════════════════════════
  //  1. REGISTER / LOGIN  →  POST /register
  // ═══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> register({
    required String name,
    required int age,
    String bloodType = 'O+',
    String allergies = '',
    String conditions = '',
    String contact = '',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/register').replace(queryParameters: {
        'name': name,
        'age': age.toString(),
        'blood_type': bloodType,
        'allergies': allergies,
        'conditions': conditions,
        'contact': contact,
      });
      final res = await http.post(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['token'];
        return data;
      }
    } catch (e) {
      debugPrint('⚠️ ApiService.register failed: $e');
    }
    // ── Mock Fallback ──
    return MockData.register(name);
  }

  /// Convenience login — uses same /register endpoint for demo.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Extract name from email for demo purposes
    final name = email.split('@').first;
    try {
      final uri = Uri.parse('$_baseUrl/register').replace(queryParameters: {
        'name': name,
        'age': '30',
        'blood_type': 'O+',
        'allergies': '',
        'conditions': '',
        'contact': email,
      });
      final res = await http.post(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['token'];
        return data;
      }
    } catch (e) {
      debugPrint('⚠️ ApiService.login failed: $e');
    }
    return MockData.register(name);
  }

  // ═══════════════════════════════════════════════════════════════
  //  2. TRIAGE  →  POST /triage/process
  // ═══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> triageProcess({
    required int age,
    int heartRate = 72,
    List<String> symptoms = const [],
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/triage/process');
      // Backend expects Form data, not JSON
      final req = http.MultipartRequest('POST', uri)
        ..fields['age'] = age.toString()
        ..fields['heart_rate'] = heartRate.toString()
        ..fields['manual_symptoms'] = _mapSymptoms(symptoms);
      if (_token != null) req.fields['qr_token'] = _token!;

      final streamed = await req.send().timeout(const Duration(seconds: 8));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('⚠️ ApiService.triageProcess failed: $e');
    }
    return MockData.triageResult();
  }

  /// Map UI display names → backend symptom keys.
  static String _mapSymptoms(List<String> uiSymptoms) {
    const mapping = {
      'Chest Pain': 'chest_pain',
      'Shortness of Breath': 'shortness_of_breath',
      'Dizziness': 'dizziness',
      'Nausea': 'vomiting',
      'Fever': 'fever',
      'Headache': 'headache',
      'Abdominal Pain': 'abdominal_pain',
      'Fatigue': 'fatigue',
      'Cough': 'cough',
      'Back Pain': 'back_pain',
      'Joint Pain': 'joint_pain',
      'Anxiety': 'anxiety',
    };
    return uiSymptoms
        .map((s) => mapping[s] ?? s.toLowerCase().replaceAll(' ', '_'))
        .join(',');
  }

  // ═══════════════════════════════════════════════════════════════
  //  3. APPOINTMENTS  →  GET /appointments/calculate?score=N
  // ═══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getWaitTime(int score) async {
    try {
      final uri = Uri.parse('$_baseUrl/appointments/calculate')
          .replace(queryParameters: {'score': score.toString()});
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      debugPrint('⚠️ ApiService.getWaitTime failed: $e');
    }
    return MockData.appointment(score);
  }

  // ═══════════════════════════════════════════════════════════════
  //  4. EMERGENCY LOOKUP  →  GET /emergency/{token}
  // ═══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> emergencyLookup(String token) async {
    try {
      final uri = Uri.parse('$_baseUrl/emergency/$token');
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      debugPrint('⚠️ ApiService.emergencyLookup failed: $e');
    }
    return MockData.emergencyLookup();
  }

  // ═══════════════════════════════════════════════════════════════
  //  5. VITALS — WebSocket  →  WS /vitals/heartrate/ws?token=X
  // ═══════════════════════════════════════════════════════════════
  static WebSocketChannel? connectHeartRateWS() {
    if (_token == null) return null;
    try {
      final uri = Uri.parse('$_wsBase/vitals/heartrate/ws?token=$_token');
      return WebSocketChannel.connect(uri);
    } catch (e) {
      debugPrint('⚠️ ApiService.connectHeartRateWS failed: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  6. VITALS — POST frame  →  POST /vitals/process_frame
  // ═══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> processFrame(String base64Image) async {
    try {
      final uri = Uri.parse('$_baseUrl/vitals/process_frame');
      final req = http.MultipartRequest('POST', uri)
        ..fields['token'] = _token ?? 'demo'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          base64Decode(base64Image),
          filename: 'frame.jpg',
        ));
      final streamed = await req.send().timeout(const Duration(seconds: 5));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      debugPrint('⚠️ ApiService.processFrame failed: $e');
    }
    return MockData.vitalsFrame();
  }

  // ═══════════════════════════════════════════════════════════════
  //  7. HEALTH CHECK  →  GET /
  // ═══════════════════════════════════════════════════════════════
  static Future<bool> healthCheck() async {
    try {
      final res = await http.get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  MOCK DATA — High-fidelity fallback for every endpoint
// ═══════════════════════════════════════════════════════════════════
class MockData {
  static Map<String, dynamic> register(String name) => {
    'status': 'success',
    'token': 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
    'qr_code_ready': true,
    'name': name,
  };

  static Map<String, dynamic> triageResult() => {
    'status': 'success',
    'triage': {'score': 45, 'risk': 'MODERATE'},
    'analysis': {
      'transcription': '',
      'detected_symptoms': ['symptom_fever', 'symptom_dizziness'],
      'severity': 'Moderate',
    },
    'appointment': {
      'wait_time': 25,
      'severity': 'Moderate',
      'slot': 'Next available in 25 min',
      'facility': 'General Hospital',
    },
    'history_noted': '',
  };

  static Map<String, dynamic> appointment(int score) {
    final wait = score > 80 ? 5 : (score > 50 ? 15 : 30);
    return {
      'wait_time': wait,
      'severity': score > 80 ? 'Critical' : (score > 50 ? 'Urgent' : 'Stable'),
      'slot': 'Next available in $wait min',
    };
  }

  static Map<String, dynamic> emergencyLookup() => {
    'mode': 'EMERGENCY_ACCESS',
    'data': {
      'name': 'Demo Patient',
      'age': 30,
      'blood_type': 'O+',
      'allergies': 'None',
      'chronic_conditions': 'None',
    },
  };

  static Map<String, dynamic> vitalsFrame() => {
    'status': 'success',
    'bpm': 72 + (DateTime.now().second % 15),
  };
}
