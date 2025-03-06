import 'package:reshapeai/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> loginWithQrCode(String qrToken);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<String?> getToken();
}
