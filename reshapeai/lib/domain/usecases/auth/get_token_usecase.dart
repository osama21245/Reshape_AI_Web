import 'package:reshapeai/domain/repositories/auth_repository.dart';

class GetTokenUseCase {
  final AuthRepository repository;

  GetTokenUseCase({required this.repository});

  Future<String?> call() {
    return repository.getToken();
  }
}
