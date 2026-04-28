import '../data/customer_data.dart';
import '../data/medicine_data.dart';
import '../data/order_data.dart';
import '../data/staff_data.dart';
import '../models/app_session.dart';
import 'api_service.dart';

class BootstrapService {
  final ApiService _api = ApiService();

  Future<void> syncCoreData(AppSession session) async {
    final int? branchId = session.isAdmin ? null : session.branchId;

    try {
      final medicines = await _api.fetchMedicines(branchId: branchId);
      globalMedicines
        ..clear()
        ..addAll(medicines);
    } catch (_) {}

    try {
      final staffs = await _api.fetchStaffs(branchId: branchId);
      globalStaffs
        ..clear()
        ..addAll(staffs.map<Map<String, String>>((e) => e.map((k, v) => MapEntry(k, v?.toString() ?? ''))));
    } catch (_) {}

    try {
      final invoices = await _api.fetchInvoices(branchId: branchId);
      globalOrders
        ..clear()
        ..addAll(invoices);
      final customers = <String, Map<String, dynamic>>{};
      for (final order in invoices) {
        final phone = (order['phone'] ?? '').toString();
        if (phone.isEmpty) continue;
        customers[phone] = {
          'name': order['customerName'] ?? 'Khách hàng',
          'phone': phone,
          'address': 'Chưa cập nhật',
          'points': order['pointsPlus'] ?? 0,
          'level': 'Bạc',
          'totalSpent': (order['total'] ?? 0).toString(),
          'lastVisit': order['date'] ?? '',
        };
      }
      globalCustomers
        ..clear()
        ..addAll(customers.values);
    } catch (_) {}
  }
}
