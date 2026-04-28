import 'package:flutter/material.dart';

class CapNhatThongTinPage extends StatefulWidget {
  final String fullName;
  const CapNhatThongTinPage({Key? key, required this.fullName}) : super(key: key);

  @override
  State<CapNhatThongTinPage> createState() => _CapNhatThongTinPageState();
}

class _CapNhatThongTinPageState extends State<CapNhatThongTinPage> {
  late TextEditingController _nameController;
  final TextEditingController _phoneController = TextEditingController(text: '0987654321');
  final TextEditingController _emailController = TextEditingController(text: 'duocsi@nhathuoc.com');
  final TextEditingController _addressController = TextEditingController(text: '123 Đường Láng, Hà Nội');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật thông tin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(
              child: Stack(
                children: [
                  CircleAvatar(radius: 50, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 50, color: Colors.white)),
                  Positioned(
                    bottom: 0, right: 0,
                    child: CircleAvatar(backgroundColor: Colors.white, radius: 18, child: Icon(Icons.camera_alt, color: Colors.blue, size: 20)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField('Họ và tên', _nameController, Icons.person),
            const SizedBox(height: 16),
            _buildTextField('Số điện thoại', _phoneController, Icons.phone, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, Icons.email),
            const SizedBox(height: 16),
            _buildTextField('Địa chỉ', _addressController, Icons.location_on),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('LƯU THAY ĐỔI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
      ),
    );
  }
}