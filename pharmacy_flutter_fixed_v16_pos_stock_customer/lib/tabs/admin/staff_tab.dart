import 'package:flutter/material.dart';

import '../../pages/admin/nhan_vien/add_nhanvien.dart';
import '../../pages/admin/nhan_vien/chi_tiet_nhan_vien_page.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../data/staff_data.dart';

class StaffTab extends StatefulWidget {
  const StaffTab({Key? key}) : super(key: key);

  @override
  State<StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends State<StaffTab> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStaffs();
  }

  Future<void> _loadStaffs() async {
    try {
      final session = await _authService.currentSession();
      final branchId = session == null || session.role == 'CEO' ? null : session.branchId;
      final data = await _apiService.fetchStaffs(branchId: branchId);
      globalStaffs
        ..clear()
        ..addAll(data.map((e) => e.map((k, v) => MapEntry(k, v?.toString() ?? ''))));
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus(Map<String, String> staff) async {
    try {
      final session = await _authService.currentSession();
      final serverId = int.tryParse(staff['serverId'] ?? '') ?? 0;
      final isActive = staff['status'] == 'Hoạt động';
      await _apiService.updateStaff(serverId, {
        'fullName': staff['name'],
        'username': staff['username'] ?? 'user$serverId',
        'password': '',
        'role': staff['roleCode'] == 'MANAGER' ? 'MANAGER' : 'STAFF',
        'phone': staff['phone'],
        'active': !isActive,
        'branchId': session?.role == 'CEO' ? (int.tryParse(staff['branchId'] ?? '') ?? 1) : (session?.branchId ?? 1),
      });
      await _loadStaffs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật trạng thái của ${staff['name']}'), backgroundColor: Colors.blue),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _confirmDelete(Map<String, String> staff) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa nhân sự "${staff['name']}" khỏi hệ thống không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              try {
                final serverId = int.tryParse(staff['serverId'] ?? '') ?? 0;
                await _apiService.deleteStaff(serverId);
                await _loadStaffs();
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa nhân sự thành công!'), backgroundColor: Colors.green));
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xóa: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('XÓA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaffs = globalStaffs.where((staff) {
      final query = _searchQuery.toLowerCase();
      final name = (staff['name'] ?? '').toLowerCase();
      final phone = (staff['phone'] ?? '').toLowerCase();
      final id = (staff['id'] ?? '').toLowerCase();
      return name.contains(query) || phone.contains(query) || id.contains(query);
    }).toList();

    final activeCount = globalStaffs.where((s) => s['status'] == 'Hoạt động').length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quản lý Nhân sự', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.blueAccent),
            tooltip: 'Thêm nhân sự',
            onPressed: () async {
              final result = await showDialog<Map<String, String>>(context: context, builder: (context) => const AddStaffDialog());
              if (result != null) {
                try {
                  final session = await _authService.currentSession();
                  final role = session?.role == 'CEO' ? 'MANAGER' : 'STAFF';
                  final username = (result['id'] ?? 'nv').toLowerCase();
                  await _apiService.createStaff({
                    'fullName': result['name'],
                    'username': username,
                    'password': '123456',
                    'role': role,
                    'phone': result['phone'],
                    'active': result['status'] == 'Hoạt động',
                    'branchId': session?.branchId ?? 1,
                  });
                  await _loadStaffs();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã thêm nhân sự. Username: $username | Mật khẩu: 123456'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi thêm nhân sự: $e'), backgroundColor: Colors.red));
                }
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Tìm theo tên, mã NV, SĐT...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng: ${globalStaffs.length} nhân sự', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('$activeCount đang hoạt động', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: filteredStaffs.isEmpty
                      ? const Center(child: Text('Không tìm thấy nhân sự nào.', style: TextStyle(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: _loadStaffs,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredStaffs.length,
                            itemBuilder: (context, index) {
                              final staff = filteredStaffs[index];
                              final isActive = staff['status'] == 'Hoạt động';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChiTietNhanVienPage(staff: staff))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: isActive ? Colors.blue.shade50 : Colors.grey.shade200,
                                          child: Icon(Icons.person, size: 30, color: isActive ? Colors.blueAccent : Colors.grey),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(staff['name'] ?? 'Chưa cập nhật', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                              const SizedBox(height: 4),
                                              Text('${staff['role'] ?? 'Nhân viên'} • ${staff['id']}', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13, fontWeight: FontWeight.w500)),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.phone_android, size: 14, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(staff['phone'] ?? 'N/A', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == 'toggle') _toggleStatus(staff);
                                                if (value == 'delete') _confirmDelete(staff);
                                              },
                                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                                              itemBuilder: (context) => const [
                                                PopupMenuItem(value: 'toggle', child: Text('Đổi trạng thái')),
                                                PopupMenuItem(value: 'delete', child: Text('Xóa')),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              child: Text(
                                                staff['status'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: isActive ? Colors.green : Colors.orange,
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
