import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/data/models/user_model.dart';

import '../../core/erorr/custom_errors/token_expired_exception.dart';

abstract class AuthDataSource {
  Future<Map<String, dynamic>> loginWithQrCode(
      String qrToken, String expiresAt);
  Future<void> logout();
  Future<Map<String, dynamic>?> getCurrentUser();
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<Map<String, dynamic>> registerDevice(String token);
  Future<Map<String, dynamic>> refreshToken(String deviceId);
}

class AuthDataSourceImpl implements AuthDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  AuthDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<Map<String, dynamic>> loginWithQrCode(
      String qrToken, String expiresAt) async {
    try {
      print(
          'AuthDataSource: Attempting to authenticate with QR token: $qrToken');

      // Step 1: Authenticate with QR token
      final authResponse = await dio.post(
        '/api/mobile/authenticate',
        data: {'token': qrToken},
      );

      if (authResponse.statusCode == 603) {
        throw TokenExpiredException();
      }

      if (authResponse.statusCode != 200) {
        throw Exception('Authentication failed: ${authResponse.statusCode}');
      }

      await secureStorage.write(key: 'expires_at', value: expiresAt);
      // Save the token
      final token = authResponse.data['token'];
      await saveToken(token);
      // Get and save the user ID
      final userId = authResponse.data['userId'];
      await secureStorage.write(key: 'user_id', value: userId.toString());

      print('AuthDataSource: Token: $token');
      print('AuthDataSource: User ID: $userId');
      print('AuthDataSource: Expires At: $expiresAt');
      // Step 2: Register the device
      final deviceResponse = await registerDevice(token);

      print('AuthDataSource: Device Response: $deviceResponse');

      // Save the device ID for future token refreshes
      if (deviceResponse['deviceLogin'] != null &&
          deviceResponse['deviceLogin']['id'] != null) {
        await secureStorage.write(
            key: 'device_id',
            value: deviceResponse['deviceLogin']['id'].toString());
      }

      // Step 3: Get user data using the user ID
      final userResponse = await dio.post(
        '/api/mobile/get-user-data',
        data: {'userId': userId, 'token': token},
      );

      if (userResponse.statusCode == 603) {
        throw TokenExpiredException();
      }

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to get user data: ${userResponse.statusCode}');
      }

      final userData = userResponse.data['user'];

      // Parse transformations
      final transformations = <TransformationModel>[];
      if (userResponse.data['transformations'] != null) {
        for (var item in userResponse.data['transformations']) {
          transformations.add(TransformationModel.fromJson(item));
        }
      }

      print('AuthDataSource: Transformations: $transformations');
      print('AuthDataSource: User Data: $userData');

      // Create user model
      final user = UserModel(
        id: userData['id'].toString(),
        name: userData['name'],
        email: userData['email'],
        profileImage: userData['image'],
        credits: userData['credits'],
        createdAt: DateTime.now(),
      );

      // Return combined data
      return {
        'token': token,
        'user': user,
        'transformations': transformations,
      };
    } catch (e) {
      print('AuthDataSource: Error in loginWithQrCode: $e');
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> registerDevice(String token) async {
    try {
      // Get device information
      String deviceName = 'Unknown Device';
      String deviceLocation = 'Mobile App';

      final androidInfo = await deviceInfo.androidInfo;
      deviceName = '${androidInfo.brand} ${androidInfo.model}';

      // Register the device
      final response = await dio.post(
        '/api/auth/device-login',
        data: {
          'token': token,
          'deviceName': deviceName,
          'deviceLocation': deviceLocation
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 603) {
        throw TokenExpiredException();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Device registered successfully: ${response.data}');
        return response.data;
      } else {
        throw Exception('Failed to register device: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering device: $e');
      throw Exception('Device registration failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String deviceId) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('No token available for refresh');
      }

      final response = await dio.post(
        '/api/auth/refresh-token',
        data: {'deviceId': deviceId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        // Save the new token
        final newToken = response.data['token'];
        await saveToken(newToken);

        return response.data;
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      throw Exception('Token refresh failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await secureStorage.delete(key: 'auth_token');
      await secureStorage.delete(key: 'user_id');
      await secureStorage.delete(key: 'device_id');
    } catch (e) {
      throw Exception('Logout error: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();

      if (token == null) {
        return null;
      }

      // Get the stored user ID
      final userId = await secureStorage.read(key: 'user_id');

      if (userId == null) {
        return null;
      }

      // Check if token needs refresh
      final deviceId = await secureStorage.read(key: 'device_id');
      if (deviceId != null) {
        try {
          // Try to refresh the token
          await refreshToken(deviceId);
        } catch (e) {
          print('Token refresh failed, continuing with existing token: $e');
        }
      }

      // Get user data
      final response = await dio.get(
        '/api/mobile/get-user-data',
        queryParameters: {'userId': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

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
