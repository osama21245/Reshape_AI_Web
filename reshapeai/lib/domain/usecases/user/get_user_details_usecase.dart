import 'package:reshapeai/domain/entities/user.dart';
import 'package:reshapeai/domain/repositories/user_repository.dart';

class GetUserDetailsUseCase {
  final UserRepository repository;

  GetUserDetailsUseCase({required this.repository});

  Future<User> call() {
    return repository.getUserDetails();
  }
}
