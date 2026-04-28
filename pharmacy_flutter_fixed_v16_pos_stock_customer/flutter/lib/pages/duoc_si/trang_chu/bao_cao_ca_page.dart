// lib/pages/duoc_si/trang_chu/bao_cao_ca_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';

class BaoCaoCaPage extends StatefulWidget {
  const BaoCaoCaPage({Key? key}) : super(key: key);

  @override
  State<BaoCaoCaPage> createState() => _BaoCaoCaPageState();
}

class _BaoCaoCaPageState extends State<BaoCaoCaPage> {
  final ApiService _apiService = ApiService();
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  bool _isLoadingData = true;
  bool _isSubmitting = false;

  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _fetchShiftData();
  }

  Future<void> _fetchShiftData() async {
    setState(() => _isLoadingData = true);
    try {
      final data = await _apiService.getShiftSummary();
      if (mounted) {
        setState(() {
          _summary = data;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  // ĐÃ SỬA: Viết liền tên hàm _guiBaoCao
  Future<void> _guiBaoCao() async {
    setState(() => _isSubmitting = true);

    final reportData = {
      'id': 'BC${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'pharmacist': 'Nguyễn Văn A',
      'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'totalOrders': _summary['orderCount'],
      'cashRevenue': _summary['cashTotal'],
      'transferRevenue': _summary['transferTotal'],
      'totalRevenue': _summary['totalRevenue'],
      'status': 'Đã nộp'
    };

    final result = await _apiService.submitShiftReport(reportData);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success']) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.cloud_done, color: Colors.blue, size: 50),
            SizedBox(height: 10),
            Text('ĐÃ GỬI BÁO CÁO', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Dữ liệu doanh thu (Tiền mặt & Chuyển khoản) đã được đồng bộ lên hệ thống công ty.', textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('HOÀN TẤT CA TRỰC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kết Thúc Ca Trực', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade500]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('TỔNG DOANH THU CA', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(formatCurrency.format(_summary['totalRevenue'] ?? 0), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('Số đơn hàng', '${_summary['orderCount'] ?? 0}', Icons.receipt_long),
                      _buildMiniStat('Nhân viên', 'Văn A', Icons.person),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('CHI TIẾT NGUỒN TIỀN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildPaymentRow(Icons.payments, 'Tiền mặt tại quầy', (_summary['cashTotal'] ?? 0).toDouble(), Colors.green),
                  const Divider(height: 1),
                  _buildPaymentRow(Icons.qr_code_scanner, 'Chuyển khoản (QR/App)', (_summary['transferTotal'] ?? 0).toDouble(), Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 10),
                  Expanded(child: Text('Dữ liệu chuyển khoản đã được hệ thống đối soát tự động với ngân hàng công ty.', style: TextStyle(fontSize: 13, color: Colors.blue))),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // ĐÃ SỬA: Gọi đúng hàm _guiBaoCao
                onPressed: _isSubmitting ? null : _guiBaoCao,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('XÁC NHẬN & GỬI TỔNG KẾT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildPaymentRow(IconData icon, String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          Text(formatCurrency.format(amount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}