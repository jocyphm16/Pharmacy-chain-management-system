import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class CeoAdminsTab extends StatefulWidget {
  const CeoAdminsTab({Key? key}) : super(key: key);

  @override
  State<CeoAdminsTab> createState() => _CeoAdminsTabState();
}

class _CeoAdminsTabState extends State<CeoAdminsTab> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  bool _loading = true;
  String _error = '';
  String _branchName = 'Cửa hàng';
  List<Map<String, dynamic>> _staffs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final session = await _authService.currentSession();
      final data = await _apiService.fetchStaffs();
      if (!mounted) return;
      setState(() {
        _branchName = session?.branchName ?? 'Cửa hàng';
        _staffs = data.where((e) => e['roleCode'] == 'STAFF').toList();
        _loading = false;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error)));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Nhân sự cửa hàng - $_branchName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.people)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Tổng dược sĩ đang quản lý: ${_staffs.length}', style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_staffs.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chưa có dược sĩ nào trong cửa hàng này.'),
              ),
            )
          else
            ..._staffs.map(_buildStaffCard),
        ],
      ),
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> staff) {
    final isActive = staff['active'] == true;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isActive ? Colors.green[100] : Colors.red[100],
          child: Icon(Icons.local_hospital, color: isActive ? Colors.green : Colors.red),
        ),
        title: Text(staff['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Dược sĩ bán hàng\n${staff['phone'] ?? ''}'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isActive ? 'Hoạt động' : 'Đã khóa',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.green[800] : Colors.red[800]),
          ),
        ),
      ),
    );
  }
}
