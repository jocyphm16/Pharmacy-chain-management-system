import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChiTietHoaDonPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const ChiTietHoaDonPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final List<dynamic> items = order['items'] ?? [];
    final String paymentMethod = order['paymentMethod'] ?? 'Tiền mặt';
    final String qrAsset = (order['qrAsset'] ?? 'assets/images/payment_qr_mb.png').toString();
    final String dynamicQrUrl = (order['dynamicQrUrl'] ?? '').toString();
    final String bankName = (order['bankName'] ?? 'MB Bank').toString();
    final String bankNumber = (order['bankNumber'] ?? '0868928126').toString();
    final String bankOwner = (order['bankOwner'] ?? 'NGUYEN TRUNG KIEN').toString();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Chi tiết Hóa Đơn', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ hóa đơn',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang tạo link chia sẻ...')));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.local_pharmacy, size: 40, color: Colors.blueAccent),
                  const SizedBox(height: 8),
                  const Text('NHÀ THUỐC TẬN TÂM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text((order['branchName'] ?? '123 Đường Láng, Đống Đa, Hà Nội').toString(), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const Text('Hotline: 0988.123.456', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 20),
                  _buildDashedLine(),
                  const SizedBox(height: 20),
                  const Text('HÓA ĐƠN THANH TOÁN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildInfoRow('Mã hóa đơn:', order['id'] ?? 'N/A'),
                  _buildInfoRow('Thời gian:', '${order['time']} - ${order['date']}'),
                  _buildInfoRow('Khách hàng:', order['customerName'] ?? 'Khách lẻ'),
                  _buildInfoRow('Nhân viên:', order['staffName'] ?? 'Chưa có'),
                  _buildInfoRow('Hình thức:', paymentMethod),
                  const SizedBox(height: 20),
                  _buildDashedLine(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(flex: 3, child: Text('Tên sản phẩm', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('SL', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Thành tiền', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('Không có dữ liệu chi tiết sản phẩm.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final int qty = item['qty'] ?? 1;
                            final double price = (item['price'] ?? 0).toDouble();
                            final double amount = qty * price;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'] ?? '', style: const TextStyle(fontSize: 14)),
                                        Text(formatCurrency.format(price), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 1, child: Text(qty.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14))),
                                  Expanded(flex: 2, child: Text(formatCurrency.format(amount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14))),
                                ],
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 20),
                  _buildDashedLine(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TỔNG CỘNG:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(formatCurrency.format(order['total'] ?? 0), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Điểm tích lũy:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('+${order['pointsPlus'] ?? 0} điểm', style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (paymentMethod == 'Chuyển khoản') ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        children: [
                          const Text('QR THANH TOÁN CỦA BẠN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: dynamicQrUrl.isNotEmpty
                                ? Image.network(
                                    dynamicQrUrl,
                                    height: 240,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Image.asset(qrAsset, height: 220, fit: BoxFit.contain),
                                  )
                                : Image.asset(qrAsset, height: 220, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 12),
                          Text('Ngân hàng: $bankName', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('Số nhận tiền/SDT: $bankNumber', style: const TextStyle(fontSize: 13)),
                          Text('Chủ TK: $bankOwner', style: const TextStyle(fontSize: 12)),
                          Text('Nội dung CK: Thanh toan ${order['id']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text('Khách quét là ra sẵn đúng số tiền của hóa đơn.', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ] else if (paymentMethod == 'Thanh toán khi nhận hàng') ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          const Text('SHIP COD: THU HỘ TIỀN MẶT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  const Text('Cảm ơn Quý khách và hẹn gặp lại!', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Icon(Icons.qr_code, size: 50, color: Colors.grey[400]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(flex: 5, child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) => const SizedBox(width: dashWidth, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)))),
        );
      },
    );
  }
}
