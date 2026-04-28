import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  // Biến cờ (flag) để tránh việc Camera quét trúng 1 mã liên tục nhiều lần trong 1 giây
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đưa mã vạch vào khung', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange, // Đồng bộ màu cam với trang Bán tại quầy
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. Khung Camera hiển thị toàn màn hình
          MobileScanner(
            onDetect: (capture) {
              // Nếu đã quét thành công rồi thì khóa lại không quét tiếp
              if (_isScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => _isScanned = true);
                  final String code = barcode.rawValue!;

                  // Đóng màn hình quét và TRẢ MÃ CODE VỀ cho trang Bán tại quầy
                  Navigator.pop(context, code);
                  break;
                }
              }
            },
          ),

          // 2. Vẽ khung vuông nhắm mục tiêu (Overlay)
          Center(
            child: Container(
              width: 250,
              height: 100, // Thường mã vạch thuốc là hình chữ nhật ngang
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // 3. Text hướng dẫn (Đã sửa lại cú pháp chuẩn)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: const Text(
                  'Hệ thống sẽ tự động nhận diện mã',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}