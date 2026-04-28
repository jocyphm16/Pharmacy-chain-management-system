import 'package:flutter/material.dart';
import '../../pages/ceo/danh_muc/them_thuoc_moi_page.dart';
import '../../services/api_service.dart';

class CeoCatalogTab extends StatefulWidget {
  const CeoCatalogTab({Key? key}) : super(key: key);

  @override
  State<CeoCatalogTab> createState() => _CeoCatalogTabState();
}

class _CeoCatalogTabState extends State<CeoCatalogTab> {
  final ApiService _apiService = ApiService();
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _allMedicines = [];
  List<Map<String, dynamic>> _foundMedicines = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final medicines = await _apiService.fetchMedicines();
      if (!mounted) return;
      setState(() {
        _allMedicines = medicines;
        _foundMedicines = medicines;
        _loading = false;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _runFilter(String keyword) {
    final query = keyword.trim().toLowerCase();
    setState(() {
      _foundMedicines = query.isEmpty
          ? _allMedicines
          : _allMedicines.where((m) {
              final name = (m['name'] ?? '').toString().toLowerCase();
              final barcode = (m['barcode'] ?? '').toString().toLowerCase();
              final manufacturer = (m['manufacturer'] ?? '').toString().toLowerCase();
              return name.contains(query) || barcode.contains(query) || manufacturer.contains(query);
            }).toList();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _runFilter,
              decoration: InputDecoration(
                hintText: 'Tìm thuốc, barcode, nhà sản xuất...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error)))
                    : RefreshIndicator(
                        onRefresh: _loadMedicines,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            if (_foundMedicines.isEmpty)
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('Không có thuốc nào trong danh mục.'),
                                ),
                              )
                            else
                              ..._foundMedicines.map(_buildDrugItem),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ThemThuocMoiPage())).then((_) => _loadMedicines());
        },
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm thuốc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDrugItem(Map<String, dynamic> medicine) {
    final stock = medicine['stock'] ?? 0;
    final barcode = medicine['barcode']?.toString() ?? '';
    final manufacturer = medicine['manufacturer']?.toString() ?? 'Chưa cập nhật';
    final price = money(medicine['price'] ?? 0);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.medical_services, color: Colors.blueAccent),
        ),
        title: Text(medicine['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Barcode: $barcode\nNSX: $manufacturer\nTồn kho: $stock • Giá bán: $price'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
