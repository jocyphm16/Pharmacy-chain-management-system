import 'package:flutter/material.dart';
import 'package:fl_quan_li_ban_thuoc/pages/admin/kho_hang/inventory_list_page.dart';
import 'package:fl_quan_li_ban_thuoc/pages/admin/kho_hang/category_page.dart';
import 'package:fl_quan_li_ban_thuoc/pages/admin/kho_hang/supplier_page.dart';

class InventoryTab extends StatelessWidget {
  const InventoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 phân hệ: Sản phẩm, Loại, Nhà cung cấp
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 0, // Ẩn phần title để tối ưu không gian
          bottom: const TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Sản phẩm', icon: Icon(Icons.medication, size: 20)),
              Tab(text: 'Loại thuốc', icon: Icon(Icons.category, size: 20)),
              Tab(text: 'Nhà cung cấp', icon: Icon(Icons.local_shipping, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            InventoryListPage(), // Danh sách thuốc (CRUD)
            CategoryTab(),       // Giao diện Loại thuốc đã code
            SupplierTab(),       // Giao diện Nhà cung cấp đã code
          ],
        ),
      ),
    );
  }
}