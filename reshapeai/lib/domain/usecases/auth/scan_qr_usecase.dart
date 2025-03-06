import 'package:reshapeai/domain/repositories/auth_repository.dart';

class ScanQrUseCase {
  final AuthRepository repository;

  ScanQrUseCase({required this.repository});

  Future<Map<String, dynamic>> call(String qrToken) {
    return repository.loginWithQrCode(qrToken);
  }
}
