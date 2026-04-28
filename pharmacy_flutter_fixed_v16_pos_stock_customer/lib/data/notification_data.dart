import 'package:flutter/material.dart';
import 'medicine_data.dart'; // Import kho thuốc để quét

// 1. CÁC THÔNG BÁO TĨNH (Hệ thống, Đơn hàng...)
List<Map<String, dynamic>> staticNotifications = [
  {
    'id': 901,
    'title': 'Cập nhật hệ thống',
    'content': 'Hệ thống sẽ bảo trì từ 23:00 đến 00:00 tối nay. Quý khách lưu ý.',
    'time': 'Hôm qua, 09:00',
    'type': 'system',
    'icon': Icons.info,
    'color': Colors.grey,
    'isUnread': false,
  },
];

// THÊM BIẾN NÀY ĐỂ LƯU TRẠNG THÁI TOÀN CỤC
List<Map<String, dynamic>> globalAdminNotifications = [];

// THÊM BIẾN NÀY ĐỂ LƯU TRẠNG THÁI CHO DƯỢC SĨ
List<Map<String, dynamic>> globalStaffNotifications = [];

// 2. HÀM TỰ ĐỘNG QUÉT KHO VÀ SINH CẢNH BÁO (DYNAMIC LOGIC)
List<Map<String, dynamic>> getDynamicNotifications() {
  List<Map<String, dynamic>> dynamicList = [];
  int notiId = 1;
  DateTime now = DateTime.now();

  // Quét toàn bộ danh sách thuốc hiện có trong globalMedicines
  for (var med in globalMedicines) {
    String name = med['name'];
    int stock = med['stock'];
    String expiryStr = med['expiry']; // Định dạng: MM/YYYY
    String batch = med['batch'];

    // --- LOGIC 1: KIỂM TRA TỒN KHO ---
    if (stock == 0) {
      dynamicList.add({
        'id': notiId++,
        'title': 'Cảnh báo: HẾT HÀNG',
        'content': 'Sản phẩm $name (Lô: $batch) đã hết sạch trong kho. Vui lòng lập phiếu nhập ngay!',
        'time': 'Hệ thống tự động',
        'type': 'warning',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.red,
        'isUnread': true,
      });
    } else if (stock <= 20) {
      dynamicList.add({
        'id': notiId++,
        'title': 'Nhắc nhở: Sắp hết hàng',
        'content': 'Sản phẩm $name chỉ còn tồn $stock ${med['unit']}. Cần lưu ý nhập thêm.',
        'time': 'Hệ thống tự động',
        'type': 'warning',
        'icon': Icons.inventory_2_outlined,
        'color': Colors.orange,
        'isUnread': true,
      });
    }

    // --- LOGIC 2: KIỂM TRA HẠN SỬ DỤNG ---
    try {
      if (expiryStr.contains('/')) {
        List<String> parts = expiryStr.split('/');
        int month = int.parse(parts[0]);
        int year = int.parse(parts[1]);

        // Quy ước ngày hết hạn là ngày 1 của tháng đó
        DateTime expDate = DateTime(year, month, 1);
        int daysDiff = expDate.difference(now).inDays;

        if (daysDiff < 0) {
          // Đã hết hạn
          dynamicList.add({
            'id': notiId++,
            'title': 'NGUY HIỂM: THUỐC ĐÃ HẾT HẠN!',
            'content': 'Lô thuốc $name ($batch) đã quá hạn sử dụng. Yêu cầu đưa vào khu vực chờ hủy ngay lập tức.',
            'time': 'Hệ thống tự động',
            'type': 'danger',
            'icon': Icons.error_outline,
            'color': Colors.redAccent,
            'isUnread': true,
          });
        } else if (daysDiff <= 90) {
          // Sắp hết hạn (Dưới 3 tháng / 90 ngày)
          dynamicList.add({
            'id': notiId++,
            'title': 'Cảnh báo: Thuốc cận Date',
            'content': 'Lô thuốc $name ($batch) sẽ hết hạn trong khoảng ${daysDiff ~/ 30} tháng tới.',
            'time': 'Hệ thống tự động',
            'type': 'warning',
            'icon': Icons.history_toggle_off,
            'color': Colors.orangeAccent,
            'isUnread': true,
          });
        }
      }
    } catch (e) {
      // Bỏ qua nếu lỗi parse Date
    }
  }

  // Nối thêm các thông báo tĩnh (Cập nhật hệ thống) vào cuối
  dynamicList.addAll(staticNotifications);

  return dynamicList;
}