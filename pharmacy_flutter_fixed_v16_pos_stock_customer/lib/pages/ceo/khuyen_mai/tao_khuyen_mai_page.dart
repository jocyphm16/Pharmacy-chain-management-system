import 'package:flutter/material.dart';

class TaoKhuyenMaiPage extends StatefulWidget {
  const TaoKhuyenMaiPage({Key? key}) : super(key: key);

  @override
  State<TaoKhuyenMaiPage> createState() => _TaoKhuyenMaiPageState();
}

class _TaoKhuyenMaiPageState extends State<TaoKhuyenMaiPage> {
  bool _apDungAll = true;
  String _loaiGiamGia = 'Phần trăm (%)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Khuyến Mãi (Chuỗi)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin chương trình', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tên chương trình (VD: Lễ 30/4)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.campaign),
                filled: true, fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _loaiGiamGia,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true, fillColor: Colors.white,
                    ),
                    items: ['Phần trăm (%)', 'Tiền mặt (VNĐ)'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() => _loaiGiamGia = newValue!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Mức giảm',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true, fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Phạm vi áp dụng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            Card(
              margin: const EdgeInsets.only(top: 10),
              child: SwitchListTile(
                title: const Text('Áp dụng toàn bộ 3 chi nhánh'),
                value: _apDungAll,
                activeColor: Colors.blueAccent,
                onChanged: (val) => setState(() => _apDungAll = val),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã phát hành khuyến mãi hệ thống!')));
                  Navigator.pop(context); // Quay về trang trước
                },
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('PHÁT HÀNH KHUYẾN MÁI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}