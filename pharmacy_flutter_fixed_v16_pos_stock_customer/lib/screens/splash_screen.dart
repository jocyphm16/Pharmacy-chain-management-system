import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/bootstrap_service.dart';
import 'admin_dashboard.dart';
import 'ceo_dashboard.dart';
import 'duoc_si_dashboard.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final BootstrapService _bootstrapService = BootstrapService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final session = await _authService.currentSession();
    Widget nextScreen = const LoginScreen();

    if (session != null) {
      if (session.flutterRole == 'admin') {
        nextScreen = const AdminDashboard();
      } else if (session.flutterRole == 'manager') {
        nextScreen = const CeoDashboard();
      } else {
        nextScreen = DuocSiDashboard(fullName: session.fullName);
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));

    if (session != null) {
      Future.microtask(() async {
        try {
          await _bootstrapService.syncCoreData(session).timeout(const Duration(seconds: 8));
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
