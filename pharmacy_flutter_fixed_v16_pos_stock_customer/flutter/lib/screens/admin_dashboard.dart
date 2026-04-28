// lib/screens/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/admin/home_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/admin/inventory_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/admin/setting_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/admin/staff_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/admin/notification_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Đưa danh sách tabs vào trong hàm build để luôn làm mới dữ liệu khi chuyển tab
    final List<Widget> tabs = [
      HomeTab(
        // TRUYỀN HÀM CHUYỂN TAB VÀO TRANG CHỦ
        onChangeTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const InventoryTab(),    // Index 1
      const StaffTab(),        // Index 2
      const NotificationTab(), // Index 3
      const SettingsTab(),     // Index 4
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CEO tổng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Kho'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Nhân viên'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}