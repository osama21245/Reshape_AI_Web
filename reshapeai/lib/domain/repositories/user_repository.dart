import 'package:reshapeai/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getUserDetails();
  Future<User> updateUserProfile({String? name, String? profileImage});
}
