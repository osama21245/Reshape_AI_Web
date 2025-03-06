import 'package:reshapeai/domain/entities/user.dart';
import 'package:reshapeai/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<User?> call() {
    return repository.getCurrentUser();
  }
}
