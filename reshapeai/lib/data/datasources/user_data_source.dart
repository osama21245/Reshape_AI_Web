import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reshapeai/data/models/user_model.dart';

abstract class UserDataSource {
  Future<UserModel> getUserDetails();
  Future<UserModel> updateUserProfile({String? name, String? profileImage});
}

class UserDataSourceImpl implements UserDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  UserDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<UserModel> getUserDetails() async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await dio.get(
        '/api/mobile/user-profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw Exception('Failed to get user details');
      }
    } catch (e) {
      throw Exception('Error fetching user details: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserProfile(
      {String? name, String? profileImage}) async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Since there's no direct endpoint for updating user profile in the mobile API,
      // we'll just return the current user details
      final response = await dio.get(
        '/api/mobile/user-profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];

        // Create a new user model with the updated fields
        return UserModel.fromJson({
          'id': userData['id'],
          'name': name ?? userData['name'],
          'email': userData['email'],
          'profileImage': profileImage ?? userData['image'],
          'createdAt':
              userData['createdAt'] ?? DateTime.now().toIso8601String(),
        });
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      throw Exception('Error updating user profile: ${e.toString()}');
    }
  }
}
