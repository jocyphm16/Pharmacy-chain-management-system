import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

// Import 5 file từ thư mục tabs/ceo của bạn
import 'package:fl_quan_li_ban_thuoc/tabs/ceo/home_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/ceo/catalog_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/ceo/admins_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/ceo/promotion_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/ceo/profile_tab.dart';

class CeoDashboard extends StatefulWidget {
  const CeoDashboard({Key? key}) : super(key: key);

  @override
  State<CeoDashboard> createState() => _CeoDashboardState();
}

class _CeoDashboardState extends State<CeoDashboard> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  void _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  // Khai báo danh sách các màn hình của CEO
  final List<Widget> _tabs = [
    const CeoHomeTab(),
    const CeoCatalogTab(),
    const CeoAdminsTab(),
    const CeoPromotionTab(),
    const CeoProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard quản lý', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _tabs[_selectedIndex], // Hiển thị nội dung Tab

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Danh mục'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Nhân sự'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Khuyến mãi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}