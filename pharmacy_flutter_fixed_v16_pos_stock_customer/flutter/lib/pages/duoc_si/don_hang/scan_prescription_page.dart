import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/prescription_data.dart';
import 'ban_tai_quay.dart'; // Import trang POS để chuyển data sang

class ScanPrescriptionPage extends StatefulWidget {
  const ScanPrescriptionPage({Key? key}) : super(key: key);

  @override
  State<ScanPrescriptionPage> createState() => _ScanPrescriptionPageState();
}

class _ScanPrescriptionPageState extends State<ScanPrescriptionPage> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isScanned = false;
  Map<String, dynamic>? _scannedPrescription;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        String code = barcode.rawValue!.trim();
        print("MÃ ĐƠN THUỐC QUÉT ĐƯỢC: $code");

        // Dò tìm đơn thuốc trong hệ thống
        int index = globalPrescriptions.indexWhere((p) => p['id'] == code);

        if (index != -1) {
          setState(() {
            _isScanned = true;
            _scannedPrescription = globalPrescriptions[index];
          });
          _cameraController.stop(); // Dừng camera lại
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy toa thuốc mã: $code'), backgroundColor: Colors.red),
          );
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quét Đơn Thuốc', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isScanned && _scannedPrescription != null
          ? _buildPrescriptionDetail() // Nếu quét thành công -> Hiện Toa thuốc
          : Stack( // Nếu chưa quét -> Hiện Camera
        children: [
          MobileScanner(controller: _cameraController, onDetect: _onDetect),
          Center(
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 4), borderRadius: BorderRadius.circular(20)),
            ),
          ),
          // ĐÃ SỬA LỖI CONST Ở ĐÂY
          Positioned(
            bottom: 50, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                child: const Text('Đưa mã QR trên toa thuốc vào khung', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Giao diện chi tiết Toa Thuốc sau khi quét thành công
  Widget _buildPrescriptionDetail() {
    final pre = _scannedPrescription!;
    final List medicines = pre['medicines'];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text(pre['hospital'].toString().toUpperCase(), style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 16))),
                  const SizedBox(height: 10),
                  const Center(child: Text('ĐƠN THUỐC ĐIỆN TỬ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  Center(child: Text('Mã đơn: ${pre['id']}', style: const TextStyle(color: Colors.grey))),
                  const Divider(height: 30, thickness: 1),

                  _buildRow('Họ tên BN:', pre['patientName']),
                  _buildRow('SĐT:', pre['phone']),
                  _buildRow('Chẩn đoán:', pre['diagnosis']),
                  _buildRow('Bác sĩ kê toa:', pre['doctor']),

                  const SizedBox(height: 20),
                  const Text('Chỉ định thuốc:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                  const SizedBox(height: 10),

                  // Danh sách thuốc trong đơn
                  ...medicines.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${m['name']} (SL: ${m['qty']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('  HDSD: ${m['dosage']}', style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
        ),

        // 2 Nút thao tác dưới cùng
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() { _isScanned = false; _scannedPrescription = null; });
                    _cameraController.start(); // Quét lại
                  },
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text('QUÉT LẠI', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    // Chuyển dữ liệu sang trang Bán Tại Quầy
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => BanTaiQuayWidget(initialPrescription: _scannedPrescription)),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text('BÁN THUỐC (POS)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}