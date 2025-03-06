import 'package:reshapeai/data/datasources/auth_data_source.dart';
import 'package:reshapeai/domain/entities/user.dart';
import 'package:reshapeai/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<Map<String, dynamic>> loginWithQrCode(String qrToken) async {
    return await dataSource.loginWithQrCode(qrToken);
  }

  @override
  Future<void> logout() async {
    await dataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await dataSource.getCurrentUser();
  }

  @override
  Future<String?> getToken() async {
    return await dataSource.getToken();
  }
}
