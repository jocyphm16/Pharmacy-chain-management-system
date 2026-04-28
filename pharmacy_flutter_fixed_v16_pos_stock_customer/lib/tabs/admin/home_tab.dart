import 'package:flutter/material.dart';

import '../../pages/ceo/tong_quan/chi_tiet_doanh_thu_page.dart';
import '../../services/api_service.dart';

class HomeTab extends StatefulWidget {
  final Function(int)? onChangeTab;
  const HomeTab({Key? key, this.onChangeTab}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String _error = '';
  Map<String, dynamic> _summary = const {};
  List<Map<String, dynamic>> _branches = const [];
  List<Map<String, dynamic>> _invoices = const [];
  List<Map<String, dynamic>> _medicines = const [];
  List<Map<String, dynamic>> _staffs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final summary = await _api.fetchDashboardSummary(branchId: null);
      final branches = await _api.fetchBranches();
      final invoices = await _api.fetchInvoices(branchId: null);
      final medicines = await _api.fetchMedicines(branchId: null);
      final staffs = await _api.fetchStaffs(branchId: null);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _branches = branches;
        _invoices = invoices;
        _medicines = medicines;
        _staffs = staffs;
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
    final s = n.toString();
    final out = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      out.write(s[i]);
      final rem = s.length - i - 1;
      if (rem > 0 && rem % 3 == 0) out.write(',');
    }
    return '${out.toString()} đ';
  }

  Map<int, int> _branchRevenue() {
    final map = <int, int>{};
    for (final inv in _invoices) {
      final id = inv['branchId'] as int?;
      if (id == null) continue;
      map[id] = (map[id] ?? 0) + ((inv['total'] ?? 0) as int);
    }
    return map;
  }

  Map<int, int> _branchProfit() {
    final byName = <String, double>{};
    for (final medicine in _medicines) {
      byName[(medicine['name'] ?? '').toString().trim().toLowerCase()] = (medicine['importPrice'] ?? 0) is num
          ? (medicine['importPrice'] ?? 0).toDouble()
          : double.tryParse('${medicine['importPrice']}') ?? 0;
    }
    final map = <int, int>{};
    for (final inv in _invoices) {
      final branchId = inv['branchId'] as int?;
      if (branchId == null) continue;
      final items = List<Map<String, dynamic>>.from(inv['items'] ?? const []);
      for (final item in items) {
        final name = (item['name'] ?? '').toString().trim().toLowerCase();
        final importPrice = byName[name] ?? 0;
        final qty = item['qty'] is num ? (item['qty'] as num).toInt() : int.tryParse('${item['qty']}') ?? 0;
        final salePrice = item['price'] is num ? (item['price'] as num).toDouble() : double.tryParse('${item['price']}') ?? 0;
        map[branchId] = (map[branchId] ?? 0) + ((salePrice - importPrice) * qty).round();
      }
    }
    return map;
  }

  Widget _metric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: Row(children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error)));
    final revenues = _branchRevenue();
    final profits = _branchProfit();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('DOANH THU TOÀN HỆ THỐNG', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(money(_summary['todayRevenue'] ?? 0), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${_summary['todayInvoices'] ?? 0} hóa đơn hôm nay', style: const TextStyle(color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 20),
          _metric('Tổng số thuốc', '${_summary['totalMedicines'] ?? 0}', Icons.medication, Colors.blue),
          const SizedBox(height: 12),
          _metric('Tổng nhân sự', '${_summary['totalStaffs'] ?? 0}', Icons.people, Colors.green),
          const SizedBox(height: 12),
          _metric('Thuốc sắp hết', '${_summary['lowStockMedicines'] ?? 0}', Icons.warning_amber, Colors.orange),
          const SizedBox(height: 12),
          _metric('Thuốc sắp hết hạn', '${_summary['expiringMedicines'] ?? 0}', Icons.event_busy, Colors.red),
          const SizedBox(height: 24),
          const Text('Doanh thu theo cửa hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._branches.map((b) {
            final branchId = b['id'] as int;
            final branchInvoices = _invoices.where((e) => e['branchId'] == branchId).toList();
            final branchMedicines = _medicines.where((e) => e['branchId'] == branchId).toList();
            final lowStock = branchMedicines.where((e) {
              final stock = e['stock'] is num ? (e['stock'] as num).toInt() : int.tryParse('${e['stock']}') ?? 0;
              return stock <= 10;
            }).length;
            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChiTietDoanhThuPage(
                        branch: b,
                        invoices: branchInvoices,
                        medicines: branchMedicines,
                        staffs: _staffs.where((e) => e['branchId'] == branchId).toList(),
                      ),
                    ),
                  );
                },
                leading: const CircleAvatar(child: Icon(Icons.storefront)),
                title: Text(b['name'].toString()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doanh thu: ${money(revenues[branchId] ?? 0)}'),
                    Text('Lãi tạm tính: ${money(profits[branchId] ?? 0)} • ${branchInvoices.length} hóa đơn • $lowStock thuốc sắp hết'),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          }),
        ],
      ),
    );
  }
}
