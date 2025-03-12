import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/data/models/user_model.dart';

import '../../core/erorr/custom_errors/token_expired_exception.dart';

abstract class UserDataSource {
  Future<Map<String, dynamic>?> getUserDetails();
  Future<Map<String, dynamic>> updateUserProfile(
      {String? name, String? profileImage});
  Future<Map<String, dynamic>> refreshToken();
}

class UserDataSourceImpl implements UserDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  UserDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      final token = await secureStorage.read(key: 'auth_token');

      if (token == null) {
        return null;
      }

      // Get the stored user ID
      final userId = await secureStorage.read(key: 'user_id');

      if (userId == null) {
        return null;
      }

      print('AuthDataSource: User ID: $userId');
      print('AuthDataSource: Token: $token');

      // Get user data
      final response = await dio.post(
        '/api/mobile/get-user-data',
        data: {'userId': userId, 'token': token},
      );

      print('AuthDataSource: Response: ${response.data}');

      if (response.statusCode == 603) {
        throw TokenExpiredException();
      }

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
      }

      return null;
    } catch (e) {
      print('AuthDataSource: Error in getCurrentUser: $e');
      return null;
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

  @override
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final deviceId = await secureStorage.read(key: 'device_id');
      final userId = await secureStorage.read(key: 'user_id');
      final response = await dio.post(
        '/api/auth/refresh-token',
        data: {'deviceId': deviceId, "userId": userId},
      );

      if (response.statusCode == 200) {
        // Save the new token
        final newToken = response.data['token'];
        final expiresAt = response.data['expiresAt'];
        await secureStorage.write(key: 'auth_token', value: newToken);
        await secureStorage.write(key: 'expires_at', value: expiresAt);
        print("=======================Refresh Token Sucess");
        return response.data;
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      throw Exception('Token refresh failed: $e');
    }
  }
}
