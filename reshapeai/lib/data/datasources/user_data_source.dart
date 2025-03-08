import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/data/models/user_model.dart';

abstract class UserDataSource {
  Future<Map<String, dynamic>> getUserDetails();
  Future<Map<String, dynamic>> updateUserProfile(
      {String? name, String? profileImage});
}

class UserDataSourceImpl implements UserDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  UserDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      final userId = await secureStorage.read(key: 'user_id');

      if (token == null || userId == null) {
        throw Exception('Authentication token or user ID not found');
      }

      final response = await dio.get(
        '/api/mobile/get-user-data',
        queryParameters: {'userId': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];

        // Parse transformations
        final transformations = <TransformationModel>[];
        if (response.data['transformations'] != null) {
          for (var item in response.data['transformations']) {
            transformations.add(TransformationModel.fromJson(item));
          }
        }

        // Create user model
        final user = UserModel(
          id: userData['id'].toString(),
          name: userData['name'],
          email: userData['email'],
          profileImage: userData['image'],
          credits: userData['credits'],
          createdAt: DateTime.now(),
        );

        // Return both user and transformations
        return {
          'user': user,
          'transformations': transformations,
        };
      } else {
        throw Exception('Failed to get user details');
      }
    } catch (e) {
      throw Exception('Error fetching user details: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile(
      {String? name, String? profileImage}) async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      final userId = await secureStorage.read(key: 'user_id');

      if (token == null || userId == null) {
        throw Exception('Authentication token or user ID not found');
      }

      // For now, we'll just fetch the user data again since the API doesn't support profile updates yet
      final response = await dio.get(
        '/api/mobile/get-user-data',
        queryParameters: {'userId': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];

        // Parse transformations
        final transformations = <TransformationModel>[];
        if (response.data['transformations'] != null) {
          for (var item in response.data['transformations']) {
            transformations.add(TransformationModel.fromJson(item));
          }
        }

        // Create user model with updated fields
        final user = UserModel(
          id: userData['id'].toString(),
          name: name ?? userData['name'],
          email: userData['email'],
          profileImage: profileImage ?? userData['image'],
          credits: userData['credits'],
          createdAt: DateTime.now(),
        );

        // Return both user and transformations
        return {
          'user': user,
          'transformations': transformations,
        };
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      throw Exception('Error updating user profile: ${e.toString()}');
    }
  }
}
