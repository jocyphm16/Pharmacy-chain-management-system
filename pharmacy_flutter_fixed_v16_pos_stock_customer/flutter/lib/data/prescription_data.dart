// lib/data/prescription_data.dart

List<Map<String, dynamic>> globalPrescriptions = [
  {
    'id': 'DT-12345', // Mã QR của đơn thuốc này
    'patientName': 'Nguyễn Văn A',
    'phone': '0987654321',
    'doctor': 'BS. Nguyễn Trọng Hưng',
    'hospital': 'Bệnh viện Đa khoa Tâm Anh',
    'diagnosis': 'Viêm phế quản cấp, Ho khan',
    'date': '28/03/2026',
    'medicines': [
      // Thông tin thuốc khớp với globalMedicines của bạn
      {'name': 'Augmentin 625mg', 'qty': 2, 'price': 180000, 'dosage': 'Sáng 1 viên, tối 1 viên (Sau ăn)'},
      {'name': 'Siro Prospan', 'qty': 1, 'price': 75000, 'dosage': 'Uống 5ml/lần x 3 lần/ngày'},
    ]
  },
  {
    'id': 'DT-67890',
    'patientName': 'Trần Thị B',
    'phone': '0912345678',
    'doctor': 'BS. Lê Kim Dung',
    'hospital': 'Phòng khám Đa khoa Thu Cúc',
    'diagnosis': 'Suy nhược cơ thể, Thiếu Vitamin C',
    'date': '28/03/2026',
    'medicines': [
      {'name': 'Panadol Extra', 'qty': 1, 'price': 5000, 'dosage': 'Uống 1 viên khi đau đầu, sốt'},
      {'name': 'Vitamin C 1000mg', 'qty': 2, 'price': 85000, 'dosage': 'Sáng 1 viên sủi hòa tan với 200ml nước'},
    ]
  }
];