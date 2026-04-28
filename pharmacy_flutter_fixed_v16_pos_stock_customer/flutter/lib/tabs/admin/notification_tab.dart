// lib/tabs/admin/notification_tab.dart

import 'package:flutter/material.dart';
import '../../data/notification_data.dart';
import '../../data/request_data.dart';
import '../../data/medicine_data.dart'; // ĐÃ THÊM: Import kho thuốc để cộng số lượng

class NotificationTab extends StatefulWidget {
  const NotificationTab({Key? key}) : super(key: key);

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {

  @override
  void initState() {
    super.initState();
    if (globalAdminNotifications.isEmpty) {
      globalAdminNotifications = getDynamicNotifications();
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var item in globalAdminNotifications) {
        item['isUnread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc'), behavior: SnackBarBehavior.floating),
    );
  }

  void _markAsRead(int id) {
    setState(() {
      final index = globalAdminNotifications.indexWhere((element) => element['id'] == id);
      if (index != -1) {
        globalAdminNotifications[index]['isUnread'] = false;
      }
    });
  }

  // ==========================================
  // HÀM XỬ LÝ DUYỆT YÊU CẦU & CỘNG VÀO KHO
  // ==========================================
  void _handleRequest(Map<String, dynamic> request, String newStatus) {
    setState(() {
      // 1. Cập nhật trạng thái hiển thị của yêu cầu
      request['status'] = newStatus;

      // 2. NẾU ADMIN BẤM "ĐÃ DUYỆT" -> CỘNG THUỐC VÀO KHO
      if (newStatus == 'Đã duyệt') {
        String medicineName = request['medicineName'];

        // Tìm thuốc trong kho dựa vào tên
        int medIndex = globalMedicines.indexWhere((m) => m['name'] == medicineName);

        if (medIndex != -1) {
          // Lấy số lượng yêu cầu (nếu trong data không có field quantity, mặc định cộng 50)
          int importQuantity = request['quantity'] ?? 50;

          // Cộng vào tồn kho
          globalMedicines[medIndex]['stock'] += importQuantity;
        }
      }
    });

    // 3. Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            newStatus == 'Đã duyệt'
                ? 'Đã duyệt và nhập thêm thuốc ${request['medicineName']} vào kho!'
                : 'Đã từ chối yêu cầu nhập ${request['medicineName']}'
        ),
        backgroundColor: newStatus == 'Đã duyệt' ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadList = globalAdminNotifications.where((n) => n['isUnread'] == true).toList();
    final readList = globalAdminNotifications.where((n) => n['isUnread'] == false).toList();

    // Lọc ra các yêu cầu chưa duyệt
    final pendingRequests = globalRequests.where((req) => req['status'] == 'Chờ duyệt').toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thông báo hệ thống', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (unreadList.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Đánh dấu tất cả', style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // YÊU CẦU TỪ DƯỢC SĨ
          if (pendingRequests.isNotEmpty) ...[
            _buildSectionHeader('Yêu cầu từ Dược sĩ (${pendingRequests.length})'),
            ...pendingRequests.map((req) => _buildRequestItem(req)),
            const SizedBox(height: 16),
          ],

          // CẢNH BÁO HỆ THỐNG (CHƯA ĐỌC)
          if (unreadList.isNotEmpty) ...[
            _buildSectionHeader('Cảnh báo tự động (${unreadList.length})'),
            ...unreadList.map((n) => _buildNotificationItem(n)),
          ],

          // ĐÃ ĐỌC
          if (readList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader('Đã đọc'),
            ...readList.map((n) => _buildNotificationItem(n)),
          ],

          if (globalAdminNotifications.isEmpty && pendingRequests.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.only(top: 100),
              child: Text('Hệ thống đang hoạt động ổn định, không có cảnh báo hay yêu cầu nào.'),
            )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12, letterSpacing: 1.1)),
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request) {
    // Hiển thị thêm số lượng yêu cầu nhập nếu có
    String qtyText = request['quantity'] != null ? ' - SL: ${request['quantity']} hộp' : ' - SL: 50 hộp';

    return Card(
      elevation: 2, margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withOpacity(0.5))),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.add_shopping_cart, color: Colors.orange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yêu cầu nhập: ${request['medicineName']}$qtyText', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('${request['pharmacist']} • ${request['time']}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => _handleRequest(request, 'Từ chối'), child: const Text('Từ chối', style: TextStyle(color: Colors.red))),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _handleRequest(request, 'Đã duyệt'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('Duyệt nhập'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data) {
    bool isUnread = data['isUnread'];
    Color color = data['color'] ?? Colors.blue;

    return Card(
      elevation: isUnread ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnread ? BorderSide(color: color.withOpacity(0.3)) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _markAsRead(data['id']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: isUnread ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(data['icon'], color: isUnread ? color : Colors.grey, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(data['title'], style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w500, color: isUnread ? Colors.black : Colors.grey[600], fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (isUnread) Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(data['content'], style: TextStyle(fontSize: 13, color: isUnread ? Colors.black87 : Colors.grey, height: 1.4)),
                    const SizedBox(height: 8),
                    Text(data['time'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}