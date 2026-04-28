// lib/pages/duoc_si/tai_khoan/doi_mat_khau_page.dart
import 'package:flutter/material.dart';
import '../../../services/api_service.dart'; // Import service gọi API

class DoiMatKhauPage extends StatefulWidget {
  const DoiMatKhauPage({Key? key}) : super(key: key);

  @override
  State<DoiMatKhauPage> createState() => _DoiMatKhauPageState();
}

class _DoiMatKhauPageState extends State<DoiMatKhauPage> {
  final ApiService _apiService = ApiService(); // Khởi tạo service

  // Các Controller để lấy text từ ô nhập
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Biến trạng thái để hiện vòng quay loading
  bool _isLoading = false;

  // Các biến trạng thái để Ẩn/Hiện mật khẩu
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Hàm xử lý đổi mật khẩu BẤT ĐỒNG BỘ (async)
  Future<void> _handleUpdatePassword() async {
    String oldPass = _oldPassController.text;
    String newPass = _newPassController.text;
    String confirmPass = _confirmPassController.text;

    // 1. Kiểm tra logic ở frontend
    if (oldPass.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')));
      return;
    }
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu mới không khớp!')));
      return;
    }

    // 2. Bật trạng thái Loading
    setState(() {
      _isLoading = true;
    });

    // 3. GỌI API LÊN SERVER VÀ CHỜ KẾT QUẢ
        final result = await _apiService.changePassword('staff1', oldPass, newPass);

    // 4. Tắt trạng thái Loading
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // 5. Xử lý kết quả từ Server trả về
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Trở về trang trước nếu thành công
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  // Hàm xây dựng UI cho từng ô nhập mật khẩu
  Widget _buildPasswordField(String label, TextEditingController controller, bool isObscure, VoidCallback onToggle) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: onToggle
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
                'Lưu ý: Mật khẩu mới sẽ được đồng bộ lên máy chủ và có hiệu lực ngay lập tức cho lần đăng nhập sau.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)
            ),
            const SizedBox(height: 30),

            // GỌI HÀM VẼ GIAO DIỆN Ô NHẬP
            _buildPasswordField('Mật khẩu hiện tại', _oldPassController, _obscureOld, () => setState(() => _obscureOld = !_obscureOld)),
            const SizedBox(height: 16),
            _buildPasswordField('Mật khẩu mới', _newPassController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            const SizedBox(height: 16),
            _buildPasswordField('Xác nhận mật khẩu mới', _confirmPassController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),

            const SizedBox(height: 30),

            // NÚT BẤM CẬP NHẬT
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                // NẾU ĐANG LOADING THÌ KHÓA NÚT BẤM (onPressed = null)
                onPressed: _isLoading ? null : _handleUpdatePassword,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                // HIỂN THỊ VÒNG QUAY NẾU LOADING
                child: _isLoading
                    ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
                    : const Text('CẬP NHẬT MẬT KHẨU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}