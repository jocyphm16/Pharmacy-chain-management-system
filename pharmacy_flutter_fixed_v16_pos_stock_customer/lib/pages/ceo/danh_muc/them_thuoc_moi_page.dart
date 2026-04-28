import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class ThemThuocMoiPage extends StatefulWidget {
  const ThemThuocMoiPage({Key? key}) : super(key: key);

  @override
  State<ThemThuocMoiPage> createState() => _ThemThuocMoiPageState();
}

class _ThemThuocMoiPageState extends State<ThemThuocMoiPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _importPriceController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  final _expiryController = TextEditingController();

  String _dvt = 'Hộp';
  bool _saving = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _manufacturerController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _importPriceController.dispose();
    _quantityController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  String? _toIsoDate(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final parts = input.trim().split('/');
    if (parts.length != 3) return null;
    return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final session = await _authService.currentSession();
      final branchId = session?.branchId ?? 1;
      final code = _barcodeController.text.trim().isEmpty
          ? 'TH${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
          : _barcodeController.text.trim();
      await _apiService.createMedicine({
        'code': code,
        'name': _nameController.text.trim(),
        'unit': _dvt,
        'manufacturer': _manufacturerController.text.trim(),
        'description': _descriptionController.text.trim(),
        'expiryDate': _toIsoDate(_expiryController.text),
        'quantity': int.tryParse(_quantityController.text.trim()) ?? 0,
        'importPrice': num.tryParse(_importPriceController.text.trim()) ?? 0,
        'salePrice': num.tryParse(_priceController.text.trim()) ?? 0,
        'categoryId': 1,
        'branchId': branchId,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thuốc vào cửa hàng thành công'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thuốc thất bại: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm thuốc cho cửa hàng'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: const Icon(Icons.medication_outlined, size: 40, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(controller: _barcodeController, decoration: _input('Mã barcode / mã thuốc', Icons.qr_code)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _input('Tên thuốc / biệt dược', Icons.medical_services),
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên thuốc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _manufacturerController,
                decoration: _input('Nhà sản xuất', Icons.factory_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập nhà sản xuất' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: _input('Hoạt chất / mô tả', Icons.science_outlined),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _dvt,
                      decoration: InputDecoration(labelText: 'Đơn vị tính', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      items: ['Hộp', 'Vỉ', 'Viên', 'Lọ', 'Tuýp'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _dvt = val ?? 'Hộp'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Số lượng đầu', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _importPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Giá nhập (VNĐ)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập giá nhập' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Giá bán (VNĐ)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập giá bán' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiryController,
                decoration: _input('Hạn dùng (DD/MM/YYYY)', Icons.date_range),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('LƯU THUỐC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
