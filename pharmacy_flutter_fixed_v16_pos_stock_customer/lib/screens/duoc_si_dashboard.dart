import 'package:flutter/material.dart';

import 'package:fl_quan_li_ban_thuoc/tabs/duoc_si/home_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/duoc_si/orders_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/duoc_si/products_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/duoc_si/noti_tab.dart';
import 'package:fl_quan_li_ban_thuoc/tabs/duoc_si/profile_tab.dart';

class DuocSiDashboard extends StatefulWidget {
  final String fullName;

  DuocSiDashboard({required this.fullName});

  @override
  _DuocSiDashboardState createState() => _DuocSiDashboardState();
}

class _DuocSiDashboardState extends State<DuocSiDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _fragments;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các Tab
    _fragments = [
      HomeTab(
        fullName: widget.fullName,
        onChangeTab: _onItemTapped,
      ),
      OrdersTab(),
      ProductsTab(),
      NotiTab(),
      ProfileTab(fullName: widget.fullName),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SỬ DỤNG IndexedStack THAY VÌ GỌI TRỰC TIẾP _fragments[_selectedIndex]
      // IndexedStack sẽ giữ cho tất cả các tab không bị reload khi chuyển tab
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _fragments,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đơn hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Sản phẩm'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}