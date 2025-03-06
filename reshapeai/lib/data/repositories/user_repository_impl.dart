import 'package:reshapeai/data/datasources/user_data_source.dart';
import 'package:reshapeai/domain/entities/user.dart';
import 'package:reshapeai/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;

  UserRepositoryImpl({required this.dataSource});

  @override
  Future<User> getUserDetails() async {
    return await dataSource.getUserDetails();
  }

  @override
  Future<User> updateUserProfile({String? name, String? profileImage}) async {
    return await dataSource.updateUserProfile(
        name: name, profileImage: profileImage);
  }
}
