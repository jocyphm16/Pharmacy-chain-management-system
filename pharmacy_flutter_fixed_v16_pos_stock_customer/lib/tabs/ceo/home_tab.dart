import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class CeoHomeTab extends StatefulWidget {
  const CeoHomeTab({Key? key}) : super(key: key);

  @override
  State<CeoHomeTab> createState() => _CeoHomeTabState();
}

class _CeoHomeTabState extends State<CeoHomeTab> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _loading = true;
  String _error = '';
  String _branchName = 'Chi nhánh';
  Map<String, dynamic> _summary = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final session = await _authService.currentSession();
      final summary = await _apiService.fetchDashboardSummary();
      if (!mounted) return;
      setState(() {
        _branchName = session?.branchName ?? summary['branchName']?.toString() ?? 'Chi nhánh';
        _summary = summary;
        _loading = false;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String money(dynamic value) {
    final n = value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;
    final text = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final pos = text.length - i;
      buffer.write(text[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write(',');
    }
    return '${buffer.toString()} đ';
  }

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DOANH THU HÔM NAY',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _branchName,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          money(_summary['todayRevenue'] ?? 0),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_summary['todayInvoices'] ?? 0} hóa đơn hôm nay',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.storefront, color: Colors.white, size: 48),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Tổng quan cửa hàng của bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _metricCard(
              icon: Icons.medication,
              title: 'Tổng số thuốc',
              value: '${_summary['totalMedicines'] ?? 0}',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _metricCard(
              icon: Icons.people,
              title: 'Nhân sự cửa hàng',
              value: '${_summary['totalStaffs'] ?? 0}',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _metricCard(
              icon: Icons.warning_amber,
              title: 'Thuốc sắp hết',
              value: '${_summary['lowStockMedicines'] ?? 0}',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _metricCard(
              icon: Icons.event_busy,
              title: 'Thuốc sắp hết hạn',
              value: '${_summary['expiringMedicines'] ?? 0}',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
