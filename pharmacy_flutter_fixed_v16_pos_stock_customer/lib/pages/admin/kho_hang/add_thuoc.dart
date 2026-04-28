import 'package:flutter/material.dart';

class AddMedicineDialog extends StatefulWidget {
  const AddMedicineDialog({Key? key}) : super(key: key);

  @override
  State<AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<AddMedicineDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _activeIngredientController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _unitController = TextEditingController(text: 'Viên');
  final TextEditingController _importPriceController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _activeIngredientController.dispose();
    _manufacturerController.dispose();
    _unitController.dispose();
    _importPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.add_business, color: Colors.blueAccent),
          SizedBox(width: 10),
          Text('Thêm Thuốc Mới'),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, 'Tên thuốc', Icons.medication),
                const SizedBox(height: 12),
                _buildTextField(_activeIngredientController, 'Hoạt chất / mô tả', Icons.science_outlined),
                const SizedBox(height: 12),
                _buildTextField(_manufacturerController, 'Nhà sản xuất', Icons.factory_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_unitController, 'Đơn vị', Icons.unfold_more)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_stockController, 'Số lượng nhập', Icons.inventory, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_importPriceController, 'Giá nhập', Icons.download, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_sellPriceController, 'Giá bán', Icons.sell_outlined, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_expiryController, 'Hạn sử dụng (DD/MM/YYYY)', Icons.date_range),
                const SizedBox(height: 8),
                const Text(
                  '* Có thể thêm nhà sản xuất ngay khi nhập thuốc.',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('HỦY BỎ', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('LƯU KHO'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập' : null,
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'active': _activeIngredientController.text.trim(),
        'manufacturer': _manufacturerController.text.trim(),
        'unit': _unitController.text.trim(),
        'stock': _stockController.text.trim(),
        'import_price': _importPriceController.text.trim(),
        'sell_price': _sellPriceController.text.trim(),
        'expiry': _expiryController.text.trim(),
      });
    }
  }
}
