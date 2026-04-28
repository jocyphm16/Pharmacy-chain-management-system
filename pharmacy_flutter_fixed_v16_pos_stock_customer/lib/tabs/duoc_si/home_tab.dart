// lib/tabs/duoc_si/home_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import để định dạng tiền tệ vnđ

// Import các trang chức năng
import '../../pages/duoc_si/don_hang/don_giao_hang.dart';
import '../../pages/duoc_si/don_hang/ban_tai_quay.dart';
import '../../pages/duoc_si/don_hang/scan_prescription_page.dart';
import '../../pages/duoc_si/trang_chu/khach_hang_page.dart';
import '../../pages/duoc_si/trang_chu/bao_cao_ca_page.dart';
import '../../pages/duoc_si/trang_chu/ton_kho_page.dart';
import '../../pages/duoc_si/don_hang/chi_tiet_hoa_don_page.dart'; // ĐÃ THÊM IMPORT TRANG HÓA ĐƠN

// Import Data dùng chung
import '../../data/order_data.dart';

// =============================================================
// 1. TRANG CHỦ DƯỢC SĨ (MÀN HÌNH CHÍNH)
// =============================================================
class HomeTab extends StatefulWidget {
  final String fullName;
  final Function(int) onChangeTab;

  const HomeTab({
    super.key,
    required this.fullName,
    required this.onChangeTab,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  @override
  Widget build(BuildContext context) {
    // --- LOGIC TÍNH TOÁN ĐỒNG BỘ DỮ LIỆU ---
    double todayRevenue = 0;
    int completedOrdersCount = 0;

    // Duyệt qua globalOrders để tính toán số liệu thực tế
    for (var order in globalOrders) {
      if (order['date'] == 'Hôm nay' || order['date'].toString().contains('2026')) {
        todayRevenue += (order['total'] as num).toDouble();
        if (order['status'] == 'Hoàn thành') {
          completedOrdersCount++;
        }
      }
    }

    // Định dạng hiển thị tiền tệ chung
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final String displayRevenue = currencyFormatter.format(todayRevenue);
    // --------------------------------------

    // Lấy 3 đơn hàng mới nhất để hiển thị ở mục Hóa đơn gần đây
    final recentOrders = globalOrders.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PHẦN HEADER & THẺ THỐNG KÊ
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blue, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Dược sĩ trực:", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text(widget.fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 90, left: 16, right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    const Text("Doanh số cá nhân hôm nay", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(displayRevenue, style: const TextStyle(color: Colors.blue, fontSize: 26, fontWeight: FontWeight.bold)),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSubStat("Thưởng đơn", "150K", Colors.orange, Icons.stars),
                        Container(height: 40, width: 1, color: Colors.grey[300]),
                        _buildSubStat("Đơn hoàn thành", completedOrdersCount.toString(), Colors.green, Icons.check_circle),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // CHỨC NĂNG CHÍNH BÁN HÀNG
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ActionCard(
                    title: "BÁN TẠI QUẦY",
                    icon: Icons.point_of_sale,
                    iconColor: Colors.orange,
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const BanTaiQuayWidget()));
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionCard(
                    title: "ĐƠN GIAO HÀNG",
                    icon: Icons.local_shipping,
                    iconColor: Colors.cyan,
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const DonGiaoHangWidget()));
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // TIỆN ÍCH
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Tiện ích", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
              children: [
                QuickActionButton(
                    title: "Quét đơn thuốc",
                    icon: Icons.camera_alt_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScanPrescriptionPage()),
                      );
                    }
                ),
                QuickActionButton(
                    title: "Khách hàng",
                    icon: Icons.people_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KhachHangPage()),
                      );
                    }
                ),
                QuickActionButton(
                    title: "Báo cáo ca",
                    icon: Icons.analytics_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BaoCaoCaPage()),
                      ).then((_) => setState(() {}));
                    }
                ),
                QuickActionButton(
                    title: "Kiểm kho",
                    icon: Icons.inventory_2_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TonKhoPage()),
                      );
                    }
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // HÓA ĐƠN GẦN ĐÂY
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hóa đơn gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => widget.onChangeTab(1), // Chuyển sang tab Đơn Hàng (index 1)
                  child: const Text('Xem tất cả', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: recentOrders.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text("Chưa có giao dịch nào trong ca.", style: TextStyle(color: Colors.grey))),
            )
                : Column(
              children: recentOrders.map((order) {
                bool isDelivery = order['type'] == 'Giao hàng';
                Color iconBg = isDelivery ? Colors.cyan : Colors.orange;
                IconData icon = isDelivery ? Icons.local_shipping : Icons.point_of_sale;

                return _buildOrderCard(context, order, iconBg, icon);
              }).toList(),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ĐÃ SỬA: Chuyển trang Hóa Đơn mới thay cho popup
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order, Color iconBg, IconData icon) {
    String displayId = order['id'].toString().startsWith('#') ? order['id'].toString() : '#${order['id']}';
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBg.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconBg),
        ),
        title: Text(displayId, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Khách: ${order['customerName']}\n${order['time']} - ${order['date']}'),
        trailing: Text(currencyFormatter.format(order['total']), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
        // MỞ TRANG CHI TIẾT HÓA ĐƠN
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChiTietHoaDonPage(order: order)),
          );
        },
      ),
    );
  }

  Widget _buildSubStat(String title, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

// --- COMPONENT HỖ TRỢ ---

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const ActionCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}