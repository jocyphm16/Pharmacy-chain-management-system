import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/bootstrap_service.dart';
import 'admin_dashboard.dart';
import 'ceo_dashboard.dart';
import 'duoc_si_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController edtUsername = TextEditingController();
  final TextEditingController edtPassword = TextEditingController();
  final AuthService _authService = AuthService();
  final BootstrapService _bootstrapService = BootstrapService();

  bool _obscureText = true;
  bool _loading = false;

  Future<void> _handleLogin() async {
    final user = edtUsername.text.trim();
    final pass = edtPassword.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    setState(() => _loading = true);
    final userModel = await _authService.login(user, pass);
    final session = await _authService.currentSession();

    if (userModel != null && session != null) {
      await _bootstrapService.syncCoreData(session);
      if (!mounted) return;
      Widget dashboard;
      if (userModel.role == 'admin') {
        dashboard = const AdminDashboard();
      } else if (userModel.role == 'manager') {
        dashboard = const CeoDashboard();
      } else {
        dashboard = DuocSiDashboard(fullName: userModel.fullName ?? userModel.username);
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dashboard));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sai tài khoản hoặc mật khẩu!'),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final bgImage = isDesktop ? 'assets/images/bg_desktop.png' : 'assets/images/bg_mobile.jpg';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isDesktop ? 400 : screenWidth * 0.85,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_pharmacy, size: 80, color: Colors.blue[700]),
                  const SizedBox(height: 16),
                  Text(
                    'ĐĂNG NHẬP',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: edtUsername,
                    decoration: InputDecoration(
                      labelText: 'Tên đăng nhập',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: edtPassword,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tài khoản test:\nadmin / admin123 (CEO tổng)\nmanager1 / manager123 (Quản lý cửa hàng)\nstaff1 / staff123 (Dược sĩ)',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
