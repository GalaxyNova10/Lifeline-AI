import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/role_selection_screen.dart';
import 'screens/dashboard_screen.dart';
import 'providers/user_provider.dart';
import 'providers/wellness_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WellnessProvider()),
      ],
      child: const LifelineApp(),
    ),
  );
}

/// Root widget — Lifeline AI application.
class LifelineApp extends StatelessWidget {
  const LifelineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifeline AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _EntryGate(),
    );
  }
}

/// Checks for a saved token on launch.
/// If found → auto-navigate to Dashboard. Otherwise → RoleSelection.
class _EntryGate extends StatefulWidget {
  const _EntryGate();

  @override
  State<_EntryGate> createState() => _EntryGateState();
}

class _EntryGateState extends State<_EntryGate> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final provider = context.read<UserProvider>();
      final restored = await provider.loadToken()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      if (mounted) {
        if (restored) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          setState(() => _checking = false);
        }
      }
    } catch (e) {
      // SharedPreferences or any other init failure — skip to role selection
      debugPrint('Session check failed: $e');
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
    }
    return const RoleSelectionScreen();
  }
}
