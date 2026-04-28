// lib/data/order_data.dart

List<Map<String, dynamic>> globalOrders = [
  {
    'id': 'DH1024',
    'date': '20/03/2026',
    'time': '14:30',
    'customerName': 'Nguyễn Văn A',
    'phone': '0987654321',
    'total': 350000,
    'status': 'Hoàn thành',
    'pointsPlus': 35,
    'type': 'Bán tại quầy',
    // ĐÃ THÊM: Danh sách chi tiết thuốc khách mua
    'items': [
      {'name': 'Paracetamol 500mg', 'qty': 2, 'price': 25000},
      {'name': 'Vitamin C 1000mg', 'qty': 1, 'price': 300000},
    ]
  },
  {
    'id': 'DH1025',
    'date': '20/03/2026',
    'time': '15:00',
    'customerName': 'Trần Thị B',
    'phone': '0912345678',
    'total': 125000,
    'status': 'Đang giao',
    'pointsPlus': 12,
    'type': 'Giao hàng',
    'items': [
      {'name': 'Khẩu trang y tế 4 lớp', 'qty': 5, 'price': 25000},
    ]
  },
];