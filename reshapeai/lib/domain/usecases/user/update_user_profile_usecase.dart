import 'package:reshapeai/domain/entities/user.dart';
import 'package:reshapeai/domain/repositories/user_repository.dart';

class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase({required this.repository});

  Future<User> call({String? name, String? profileImage}) {
    return repository.updateUserProfile(
      name: name,
      profileImage: profileImage,
    );
  }
}
