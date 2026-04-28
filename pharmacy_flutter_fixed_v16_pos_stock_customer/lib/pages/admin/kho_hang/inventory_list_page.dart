import 'package:flutter/material.dart';

import '../../../data/medicine_data.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import 'add_thuoc.dart';

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({Key? key}) : super(key: key);

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _allMedicines = [];
  List<Map<String, dynamic>> _foundMedicines = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final session = await _authService.currentSession();
      final branchId = session == null || session.role == 'CEO' ? null : session.branchId;
      final data = await _apiService.fetchMedicines(branchId: branchId);
      if (!mounted) return;
      setState(() {
        _allMedicines = data;
        _foundMedicines = data;
        globalMedicines
          ..clear()
          ..addAll(data);
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _runFilter(String enteredKeyword) {
    final query = enteredKeyword.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _foundMedicines = List.from(_allMedicines);
      } else {
        _foundMedicines = _allMedicines.where((medicine) {
          final name = (medicine['name'] ?? '').toString().toLowerCase();
          final manufacturer = (medicine['manufacturer'] ?? '').toString().toLowerCase();
          final active = (medicine['activeIngredient'] ?? '').toString().toLowerCase();
          return name.contains(query) || manufacturer.contains(query) || active.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _showAddMedicineDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddMedicineDialog(),
    );

    if (result == null) return;

    try {
      final session = await _authService.currentSession();
      final branchId = session?.branchId ?? 1;
      final body = {
        'code': 'TH${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'name': result['name'],
        'unit': result['unit'] ?? 'Viên',
        'manufacturer': (result['manufacturer'] ?? '').toString(),
        'description': result['active'] ?? '',
        'expiryDate': _toIsoDate(result['expiry']?.toString()),
        'quantity': int.tryParse(result['stock'].toString()) ?? 0,
        'importPrice': num.tryParse(result['import_price'].toString()) ?? 0,
        'salePrice': num.tryParse(result['sell_price'].toString()) ?? 0,
        'categoryId': 1,
        'branchId': branchId,
      };
      await _apiService.createMedicine(body);
      await _loadMedicines();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm thuốc mới thành công'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi thêm thuốc: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String? _toIsoDate(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final text = input.trim();
    final parts = text.split('/');
    if (parts.length == 3) return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_error, textAlign: TextAlign.center),
      ));
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _runFilter,
              decoration: InputDecoration(
                hintText: 'Tìm tên thuốc, hoạt chất, nhà sản xuất...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMedicines,
              child: _foundMedicines.isEmpty
                  ? const Center(child: Text('Không tìm thấy thuốc'))
                  : ListView.builder(
                      itemCount: _foundMedicines.length,
                      itemBuilder: (context, index) {
                        final item = _foundMedicines[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.medication, color: Colors.blue),
                            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'NSX: ${item['manufacturer'] ?? 'Chưa cập nhật'}\nTồn kho: ${item['stock']} | HSD: ${item['expiry']}',
                            ),
                            isThreeLine: true,
                            trailing: Text('${item['price']}đ'),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddMedicineDialog, child: const Icon(Icons.add)),
    );
  }
}
