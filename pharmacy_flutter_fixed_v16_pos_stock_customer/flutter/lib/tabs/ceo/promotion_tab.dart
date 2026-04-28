import 'package:flutter/material.dart';
import '../../pages/ceo/khuyen_mai/tao_khuyen_mai_page.dart';
import '../../services/auth_service.dart';

class CeoPromotionTab extends StatefulWidget {
  const CeoPromotionTab({Key? key}) : super(key: key);

  @override
  State<CeoPromotionTab> createState() => _CeoPromotionTabState();
}

class _CeoPromotionTabState extends State<CeoPromotionTab> {
  bool _kmTet = true;
  bool _kmHe = false;
  String _branchName = 'cửa hàng';

  @override
  void initState() {
    super.initState();
    AuthService().currentSession().then((session) {
      if (mounted) setState(() => _branchName = session?.branchName ?? 'cửa hàng');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Khuyến mãi tại $_branchName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaoKhuyenMaiPage()),
              );
            },
            icon: const Icon(Icons.add_box, color: Colors.white),
            label: const Text('Tạo khuyến mãi mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.local_offer, color: Colors.redAccent, size: 30),
            title: const Text('Giảm 10% dịp Lễ 30/4', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Phạm vi: $_branchName'),
            trailing: Switch(value: _kmTet, onChanged: (val) => setState(() => _kmTet = val), activeColor: Colors.blueAccent),
          ),
        ),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.local_offer, color: Colors.grey, size: 30),
            title: const Text('Flash Sale khách quen', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Phạm vi: $_branchName'),
            trailing: Switch(value: _kmHe, onChanged: (val) => setState(() => _kmHe = val), activeColor: Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}
