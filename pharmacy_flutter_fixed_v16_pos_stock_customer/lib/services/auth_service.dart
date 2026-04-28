import '../models/app_session.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class AuthService {
  final LocalStorageService _storageService = LocalStorageService();
  final ApiService _apiService = ApiService();

  Future<UserModel?> login(String username, String password) async {
    try {
      final AppSession session = await _apiService.login(username, password);
      await _storageService.saveSession(session);
      return UserModel(
        username: session.username,
        role: session.flutterRole,
        fullName: session.fullName,
      );
    } catch (_) {
      return null;
    }
  }

  Future<AppSession?> currentSession() => _storageService.getSession();

  Future<void> logout() async {
    await _storageService.clearSession();
  }
}
