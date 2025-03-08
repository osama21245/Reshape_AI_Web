import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reshapeai/data/models/user_model.dart';

abstract class AuthDataSource {
  Future<Map<String, dynamic>> loginWithQrCode(String qrToken);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

class AuthDataSourceImpl implements AuthDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<Map<String, dynamic>> loginWithQrCode(String qrToken) async {
    try {
      // Step 1: Authenticate with QR token
      final authResponse = await dio.post(
        '/api/mobile/authenticate',
        data: {'token': qrToken},
      );

      if (authResponse.statusCode != 200) {
        throw Exception('Authentication failed: ${authResponse.statusCode}');
      }

      // Save the token
      final token = authResponse.data['token'];
      await saveToken(token);

      // Get and save the user ID
      final userId = authResponse.data['userId'];
      await secureStorage.write(key: 'user_id', value: userId.toString());

      // Step 2: Get user data using the user ID
      final userResponse = await dio.post(
        '/api/mobile/get-user-data',
        data: {'userId': userId, 'token': token},
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to get user data: ${userResponse.statusCode}');
      }

      print('AuthDataSource: User data retrieved ${userResponse.data}');

      // Return combined data
      return {'token': token, 'user': userResponse.data['user']};
    } catch (e) {
      print('AuthDataSource: Error in loginWithQrCode: $e');
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // No need to call an API endpoint for logout as per the API structure
      await deleteToken();
    } catch (e) {
      throw Exception('Logout error: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // Get the stored token
      final token = await getToken();

      if (token == null) {
        return null;
      }

      // Get the stored user ID
      final userId = await secureStorage.read(key: 'user_id');

      if (userId == null) {
        return null;
      }

      // Try GET method first with query parameters and Authorization header
      try {
        final response = await dio.get(
          '/api/mobile/get-user-data',
          queryParameters: {'userId': 2},
          options: Options(
            headers: {
              'Authorization':
                  'Bearer 268dd25e1370a0a814bfe6910914b0b0e898b18945690ad32c1430aca9e978ad'
            },
          ),
        );

        if (response.statusCode == 200) {
          final userData = response.data['user'];

          // Create and return user model
          return UserModel(
            id: userData['id'].toString(),
            name: userData['name'],
            email: userData['email'],
            profileImage: userData['image'],
            createdAt: DateTime.now(),
          );
        }
      } catch (e) {
        print('Error with GET method: $e');
        // Fall back to POST method
      }

      // Fall back to POST method with token in request body
      final response = await dio.post(
        '/api/mobile/get-user-data',
        data: {'userId': userId, 'token': token},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get user data');
      }

      final userData = response.data['user'];

      // Create and return user model
      return UserModel(
        id: userData['id'].toString(),
        name: userData['name'],
        email: userData['email'],
        profileImage: userData['image'],
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'auth_token');
  }
}
