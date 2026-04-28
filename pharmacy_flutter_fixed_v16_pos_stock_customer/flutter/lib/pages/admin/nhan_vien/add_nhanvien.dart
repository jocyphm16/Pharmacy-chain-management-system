import 'package:flutter/material.dart';

class AddStaffDialog extends StatefulWidget {
  const AddStaffDialog({Key? key}) : super(key: key);

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  // Key để quản lý trạng thái và validate Form
  final _formKey = GlobalKey<FormState>();

  // Bộ điều khiển để lấy văn bản từ các ô nhập liệu
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Giá trị mặc định cho trạng thái nhân viên
  String _selectedStatus = 'Hoạt động';

  @override
  void dispose() {
    // Giải phóng bộ nhớ của các controller khi đóng dialog
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // Kiểm tra tính hợp lệ của dữ liệu trước khi lưu
    if (_formKey.currentState!.validate()) {
      // Trả về dữ liệu kiểu Map khớp với cấu trúc trong StaffTab
      Navigator.pop(context, {
        'id': _idController.text.trim(),
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'status': _selectedStatus,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Thêm Nhân Sự Mới',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ô nhập Mã nhân viên
              _buildTextField(
                controller: _idController,
                label: 'Mã nhân viên (VD: DS003)',
                icon: Icons.badge_outlined,
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập mã' : null,
              ),
              const SizedBox(height: 16),

              // Ô nhập Họ và tên
              _buildTextField(
                controller: _nameController,
                label: 'Họ và tên dược sĩ',
                icon: Icons.person_outline,
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),

              // Ô nhập Số điện thoại
              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone_android_outlined,
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập SĐT' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown chọn Trạng thái
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Trạng thái làm việc',
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Hoạt động', 'Nghỉ phép'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('THÊM MỚI', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Widget hỗ trợ tạo nhanh các ô nhập liệu
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }
}