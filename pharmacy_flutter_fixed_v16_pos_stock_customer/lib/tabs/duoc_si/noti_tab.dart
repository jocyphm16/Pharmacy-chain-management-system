// lib/tabs/duoc_si/noti_tab.dart

import 'package:flutter/material.dart';
import '../../data/notification_data.dart'; // IMPORT DATA

class NotiTab extends StatefulWidget {
  const NotiTab({Key? key}) : super(key: key);

  @override
  _NotiTabState createState() => _NotiTabState();
}

class _NotiTabState extends State<NotiTab> {

  @override
  void initState() {
    super.initState();
    // LOGIC: Chỉ khởi tạo nếu danh sách toàn cục đang trống để tránh bị reset khi chuyển tab
    if (globalStaffNotifications.isEmpty) {
      globalStaffNotifications = getDynamicNotifications();
    }
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'order': return Icons.shopping_bag;
      case 'warning': return Icons.warning_amber_rounded;
      case 'danger': return Icons.error_outline;
      case 'success': return Icons.check_circle;
      case 'system': return Icons.info;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order': return Colors.blue;
      case 'warning': return Colors.orange;
      case 'danger': return Colors.redAccent;
      case 'success': return Colors.green;
      case 'system': return Colors.grey.shade700;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text('THÔNG BÁO TỪ KHO', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      // Cập nhật vào danh sách toàn cục
                      for (var noti in globalStaffNotifications) {
                        noti['isUnread'] = false;
                      }
                    });
                  },
                  icon: const Icon(Icons.done_all, color: Colors.blue, size: 20),
                  label: const Text('Đánh dấu tất cả đã đọc', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          Expanded(
            child: globalStaffNotifications.isEmpty
                ? const Center(child: Text('Bạn không có thông báo nào.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: globalStaffNotifications.length,
              itemBuilder: (context, index) {
                final noti = globalStaffNotifications[index];
                bool isUnread = noti['isUnread'] ?? false;

                return InkWell(
                  onTap: () => setState(() => noti['isUnread'] = false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // SỬA LỖI MÀU: Chưa đọc thì hiện màu xanh nhạt, Đã đọc thì hiện màu TRẮNG
                      color: isUnread ? Colors.blue.shade50 : Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: _getIconColor(noti['type']).withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(_getIconData(noti['type']), color: _getIconColor(noti['type']), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  noti['title'],
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                      color: isUnread ? Colors.blue.shade900 : Colors.black87
                                  )
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  noti['content'] ?? '',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: isUnread ? Colors.black87 : Colors.grey[600]
                                  )
                              ),
                              const SizedBox(height: 8),
                              Text(noti['time'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        if (isUnread)
                          Container(margin: const EdgeInsets.only(top: 8), width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}