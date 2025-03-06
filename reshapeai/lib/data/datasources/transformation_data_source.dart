import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:reshapeai/data/models/transformation_model.dart';

abstract class TransformationDataSource {
  Future<List<TransformationModel>> getTransformations();
  Future<TransformationModel> createTransformation(File image, String style);
}

class TransformationDataSourceImpl implements TransformationDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  TransformationDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<List<TransformationModel>> getTransformations() async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Get user email from profile
      final userResponse = await dio.get(
        '/api/mobile/user-profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to get user profile');
      }

      final userEmail = userResponse.data['user']['email'];

      // Get transformations using email
      final response = await dio.get(
        '/api/transformations',
        queryParameters: {'email': userEmail},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> transformationsData = response.data;
        return transformationsData
            .map((data) => TransformationModel.fromJson({
                  'id': data['id'],
                  'userId': userEmail, // Using email as userId
                  'originalImageUrl': data['originalImageUrl'],
                  'transformedImageUrl': data['aiGeneratedImageUrl'],
                  'style': data['style'],
                  'createdAt': data['createdAt'],
                }))
            .toList();
      } else {
        throw Exception('Failed to load transformations');
      }
    } catch (e) {
      throw Exception('Error fetching transformations: ${e.toString()}');
    }
  }

  @override
  Future<TransformationModel> createTransformation(
      File image, String style) async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Get user email from profile
      final userResponse = await dio.get(
        '/api/mobile/user-profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to get user profile');
      }

      final userEmail = userResponse.data['user']['email'];

      // First upload the image to get a URL
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      // Assuming there's an upload endpoint
      final uploadResponse = await dio.post(
        '/api/upload-image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception('Failed to upload image');
      }

      final imageUrl = uploadResponse.data['url'];

      // Now generate the transformation
      final response = await dio.post(
        '/api/generate-photo',
        data: {
          'imageUrl': imageUrl,
          'roomType': 'room', // Default room type
          'style': style,
          'customization': '', // Optional customization
          'userEmail': userEmail,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return TransformationModel.fromJson({
          'id': response.data['id'],
          'userId': userEmail,
          'originalImageUrl': imageUrl,
          'transformedImageUrl': response.data['url'],
          'style': style,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        throw Exception('Failed to create transformation');
      }
    } catch (e) {
      throw Exception('Error creating transformation: ${e.toString()}');
    }
  }
}
