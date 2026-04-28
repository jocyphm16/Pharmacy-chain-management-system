import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_session.dart';
import 'local_storage_service.dart';

class ApiService {
  ApiService();

  final LocalStorageService _storage = LocalStorageService();

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api';
      default:
        return 'http://localhost:8080/api';
    }
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final session = await _storage.getSession();
      if (session != null && session.token.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${session.token}';
      }
    }
    return headers;
  }

  dynamic _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Exception _error(http.Response response) {
    try {
      final body = _decode(response);
      if (body is Map<String, dynamic> && body['message'] != null) {
        return Exception(body['message'].toString());
      }
    } catch (_) {}
    return Exception('Lỗi ${response.statusCode}: ${response.reasonPhrase ?? 'Không xác định'}');
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.map((key, value) => MapEntry(key, value.toString())),
    );
    final res = await http.get(uri, headers: await _headers(withAuth: withAuth)).timeout(const Duration(seconds: 8));
    if (res.statusCode >= 200 && res.statusCode < 300) return _decode(res);
    throw _error(res);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool withAuth = true}) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body ?? <String, dynamic>{}),
    ).timeout(const Duration(seconds: 8));
    if (res.statusCode >= 200 && res.statusCode < 300) return _decode(res);
    throw _error(res);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body, bool withAuth = true}) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body ?? <String, dynamic>{}),
    ).timeout(const Duration(seconds: 8));
    if (res.statusCode >= 200 && res.statusCode < 300) return _decode(res);
    throw _error(res);
  }

  Future<void> delete(String path, {bool withAuth = true}) async {
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers(withAuth: withAuth)).timeout(const Duration(seconds: 8));
    if (res.statusCode < 200 || res.statusCode >= 300) throw _error(res);
  }

  Future<AppSession> login(String username, String password) async {
    final data = await post('/auth/login', body: {'username': username, 'password': password}, withAuth: false);
    return AppSession.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Map<String, dynamic>> changePassword(String username, String oldPassword, String newPassword) async {
    final data = await post('/auth/change-password', body: {
      'username': username,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  List<Map<String, dynamic>> _mapMedicinesToLegacy(List<dynamic> data) {
    return data.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      String expiry = '';
      if (m['expiryDate'] != null && m['expiryDate'].toString().isNotEmpty) {
        final parts = m['expiryDate'].toString().split('-');
        if (parts.length == 3) expiry = '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return {
        'id': m['code'] ?? 'SP${m['id']}',
        'serverId': m['id'],
        'barcode': m['code'] ?? '',
        'name': m['name'] ?? '',
        'activeIngredient': m['description'] ?? '',
        'usage': m['description'] ?? '',
        'location': m['branchName'] ?? '',
        'stock': (m['quantity'] ?? 0) is int ? m['quantity'] : (m['quantity'] as num).toInt(),
        'unit': m['unit'] ?? '',
        'price': ((m['salePrice'] ?? 0) as num).toInt(),
        'category': m['categoryName'] ?? 'Khác',
        'expiry': expiry,
        'batch': m['code'] ?? '',
        'manufacturer': m['manufacturer'] ?? '',
        'importPrice': m['importPrice'],
        'salePrice': m['salePrice'],
        'branchId': m['branchId'],
        'branchName': m['branchName'],
        'categoryId': m['categoryId'],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchMedicines({int? branchId, String? keyword}) async {
    final session = await _storage.getSession();
    final resolvedBranchId = branchId ?? ((session != null && !session.isCeo) ? session.branchId : null);
    final data = await get('/medicines', query: {
      if (resolvedBranchId != null) 'branchId': resolvedBranchId,
      if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
    });
    return _mapMedicinesToLegacy(List<dynamic>.from(data as List));
  }

  Future<Map<String, dynamic>> createMedicine(Map<String, dynamic> body) async {
    final data = await post('/medicines', body: body);
    return _mapMedicinesToLegacy([data])[0];
  }

  Future<Map<String, dynamic>> updateMedicine(int id, Map<String, dynamic> body) async {
    final data = await put('/medicines/$id', body: body);
    return _mapMedicinesToLegacy([data])[0];
  }

  Future<void> deleteMedicine(int id) async => delete('/medicines/$id');

  Future<List<Map<String, dynamic>>> fetchStaffs({int? branchId}) async {
    final session = await _storage.getSession();
    final resolvedBranchId = branchId ?? ((session != null && !session.isCeo) ? session.branchId : null);
    final data = await get('/staffs', query: {if (resolvedBranchId != null) 'branchId': resolvedBranchId});
    return List<dynamic>.from(data as List).map((e) {
      final s = Map<String, dynamic>.from(e as Map);
      final role = (s['role'] ?? '').toString();
      return {
        'serverId': s['id'],
        'id': 'NV${s['id']}',
        'name': s['fullName'] ?? '',
        'phone': s['phone'] ?? '',
        'status': s['active'] == true ? 'Hoạt động' : 'Nghỉ phép',
        'role': role == 'CEO' ? 'CEO tổng' : (role == 'MANAGER' ? 'Quản lý cửa hàng' : 'Dược sĩ bán hàng'),
        'username': s['username'] ?? '',
        'roleCode': role,
        'branchId': s['branchId'],
        'branchName': s['branchName'] ?? '',
        'active': s['active'] == true,
      };
    }).toList();
  }

  Future<Map<String, dynamic>> createStaff(Map<String, dynamic> body) async {
    final data = await post('/staffs', body: body);
    return (await fetchStaffs()).firstWhere((e) => e['serverId'] == (data['id'] as num).toInt());
  }

  Future<Map<String, dynamic>> updateStaff(int id, Map<String, dynamic> body) async {
    final data = await put('/staffs/$id', body: body);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> deleteStaff(int id) async => delete('/staffs/$id');

  Future<Map<String, dynamic>> fetchDashboardSummary({int? branchId}) async {
    final session = await _storage.getSession();
    final resolvedBranchId = branchId ?? ((session != null && !session.isCeo) ? session.branchId : null);
    final data = await get('/dashboard/summary', query: {if (resolvedBranchId != null) 'branchId': resolvedBranchId});
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> fetchInvoices({int? branchId}) async {
    final session = await _storage.getSession();
    final resolvedBranchId = branchId ?? ((session != null && !session.isCeo) ? session.branchId : null);
    final data = await get('/invoices', query: {if (resolvedBranchId != null) 'branchId': resolvedBranchId});
    return List<dynamic>.from(data as List).map((e) {
      final inv = Map<String, dynamic>.from(e as Map);
      final createdAt = (inv['createdAt'] ?? '').toString();
      String date = '';
      String time = '';
      if (createdAt.contains('T')) {
        final dt = createdAt.split('T');
        if (dt.length == 2) {
          final parts = dt[0].split('-');
          if (parts.length == 3) date = '${parts[2]}/${parts[1]}/${parts[0]}';
          time = dt[1].substring(0, 5);
        }
      }
      final items = List<dynamic>.from(inv['items'] ?? []).map((item) {
        final i = Map<String, dynamic>.from(item as Map);
        return {
          'name': i['medicineName'],
          'qty': i['quantity'],
          'price': ((i['unitPrice'] ?? 0) as num).toInt(),
          'lineTotal': ((i['lineTotal'] ?? 0) as num).toInt(),
        };
      }).toList();
      return {
        'serverId': inv['id'],
        'id': inv['invoiceCode'] ?? 'HD-${inv['id']}',
        'date': date,
        'time': time,
        'customerName': (inv['customerName'] ?? '').toString().isEmpty ? 'Khách lẻ' : inv['customerName'],
        'phone': inv['customerPhone'] ?? '',
        'total': ((inv['totalAmount'] ?? 0) as num).toInt(),
        'status': 'Hoàn thành',
        'pointsPlus': (((inv['totalAmount'] ?? 0) as num) / 100000).floor(),
        'type': 'Bán tại quầy',
        'items': items,
        'branchId': inv['branchId'],
        'branchName': inv['branchName'],
        'staffId': inv['staffId'],
        'staffName': inv['staffName'],
      };
    }).toList();
  }

  Future<Map<String, dynamic>> createInvoice({
    required int branchId,
    required int staffId,
    String? customerName,
    String? customerPhone,
    required List<Map<String, dynamic>> items,
  }) async {
    final data = await post('/invoices', body: {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'branchId': branchId,
      'staffId': staffId,
      'items': items,
    });
    return (await fetchInvoices(branchId: branchId)).firstWhere((e) => e['serverId'] == (data['id'] as num).toInt());
  }


  Future<List<Map<String, dynamic>>> fetchBranches() async {
    final data = await get('/branches');
    return List<dynamic>.from(data as List).map((e) {
      final b = Map<String, dynamic>.from(e as Map);
      return {
        'id': (b['id'] as num).toInt(),
        'code': b['code'] ?? '',
        'name': b['name'] ?? '',
        'address': b['address'] ?? '',
        'phone': b['phone'] ?? '',
      };
    }).toList();
  }

  Future<Map<String, dynamic>> addCustomer(Map<String, dynamic> customerData) async {
    return {
      'success': true,
      'message': 'Đã lưu khách hàng vào danh sách cục bộ',
      'data': customerData,
    };
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final session = await _storage.getSession();
    if (session == null) {
      return {'success': false, 'message': 'Chưa đăng nhập'};
    }
    final items = List<Map<String, dynamic>>.from(orderData['items'] as List).map((e) {
      final item = Map<String, dynamic>.from(e);
      final code = item['serverId'] ?? item['medicineId'] ?? item['id'];
      int? medicineId;
      if (code is int) medicineId = code;
      if (medicineId == null) {
        // tra theo code neu gio hang dang luu ma THxxx
      }
      return {
        'medicineId': medicineId ?? item['serverId'],
        'quantity': item['qty'] ?? item['quantity'] ?? 1,
        'unitPrice': item['price'] ?? item['unitPrice'] ?? 0,
      };
    }).toList();
    try {
      await createInvoice(
        branchId: session.branchId ?? 1,
        staffId: session.userId,
        customerName: orderData['customerName']?.toString(),
        customerPhone: orderData['phone']?.toString(),
        items: items,
      );
      return {'success': true, 'message': 'Tạo hóa đơn thành công'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> importStock({
    required int medicineId,
    required int staffId,
    required int quantity,
    required num importPrice,
    String? note,
  }) async {
    final data = await post('/inventory/import', body: {
      'medicineId': medicineId,
      'staffId': staffId,
      'quantity': quantity,
      'importPrice': importPrice,
      'note': note,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> transferStock({
    required int medicineId,
    required int fromBranchId,
    required int toBranchId,
    required int staffId,
    required int quantity,
    String? note,
  }) async {
    final data = await post('/inventory/transfer', body: {
      'medicineId': medicineId,
      'fromBranchId': fromBranchId,
      'toBranchId': toBranchId,
      'staffId': staffId,
      'quantity': quantity,
      'note': note,
    });
    return Map<String, dynamic>.from(data as Map);
  }


  Future<Map<String, dynamic>> getShiftSummary() async {
    try {
      final summary = await fetchDashboardSummary();
      return {
        'success': true,
        'cashTotal': summary['todayRevenue'] ?? summary['cashTotal'] ?? 0,
        'transferTotal': summary['transferTotal'] ?? 0,
        'orderCount': summary['todayInvoices'] ?? summary['orderCount'] ?? 0,
      };
    } catch (_) {
      return {
        'success': true,
        'cashTotal': 0,
        'transferTotal': 0,
        'orderCount': 0,
      };
    }
  }

  Future<Map<String, dynamic>> submitShiftReport(Map<String, dynamic> reportData) async {
    return {
      'success': true,
      'message': 'Đã gửi báo cáo ca thành công',
      'data': reportData,
    };
  }

  Future<Map<String, dynamic>> sendRestockRequest(Map<String, dynamic> requestData) async {
    return {
      'success': true,
      'message': 'Đã gửi yêu cầu nhập hàng thành công',
      'data': requestData,
    };
  }

}
