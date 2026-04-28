// lib/data/request_data.dart

// Danh sách lưu trữ các yêu cầu nhập hàng từ Dược sĩ gửi lên Admin
List<Map<String, dynamic>> globalRequests = [
  // Dữ liệu mẫu ban đầu để Admin có cái nhìn ngay
  {
    'id': 'YC99812',
    'medicineName': 'Siro Prospan',
    'pharmacist': 'Nguyễn Văn A',
    'time': '10:30 - Hôm nay',
    'status': 'Chờ duyệt', // Trạng thái: Chờ duyệt, Đã nhập, Từ chối
  }
];