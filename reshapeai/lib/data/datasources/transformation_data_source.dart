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
        final transformations = <TransformationModel>[];
        if (response.data['transformations'] != null) {
          for (var item in response.data['transformations']) {
            transformations.add(TransformationModel.fromJson(item));
          }
        }
        return transformations;
      } else {
        throw Exception('Failed to get transformations');
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
      final userId = await secureStorage.read(key: 'user_id');

      if (token == null || userId == null) {
        throw Exception('Authentication token or user ID not found');
      }

      // First upload the image to get a URL
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      // Upload the image
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

      // Generate the transformation
      final response = await dio.post(
        '/api/generate-photo',
        data: {
          'imageUrl': imageUrl,
          'roomType': 'room', // Default room type
          'style': style,
          'customization': '', // Optional customization
          'userId': userId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return TransformationModel(
          id: response.data['id'].toString(),
          userId: userId,
          originalImageUrl: imageUrl,
          transformedImageUrl: response.data['url'],
          style: style,
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to create transformation');
      }
    } catch (e) {
      throw Exception('Error creating transformation: ${e.toString()}');
    }
  }
}
