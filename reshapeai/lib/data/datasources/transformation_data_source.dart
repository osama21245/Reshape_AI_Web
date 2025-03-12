import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:reshapeai/data/models/transformation_model.dart';

abstract class TransformationDataSource {
  Future<List<TransformationModel>> getTransformations();
  Future<TransformationModel> createTransformation({
    required File imageFile,
    required String roomType,
    required String style,
    String customization,
  });
}

class TransformationDataSourceImpl implements TransformationDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        final List<dynamic> transformationsJson =
            response.data['transformations'];
        return transformationsJson
            .map((json) => TransformationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load transformations');
      }
    } catch (e) {
      throw Exception('Error fetching transformations: $e');
    }
  }

  @override
  Future<TransformationModel> createTransformation({
    required File imageFile,
    required String roomType,
    required String style,
    String customization = '',
  }) async {
    try {
      print('Creating transformation...');
      // 1. Get authentication token and user ID
      final token = await secureStorage.read(key: 'auth_token');
      final userId = await secureStorage.read(key: 'user_id');

      if (token == null || userId == null) {
        throw Exception('Authentication token or user ID not found');
      }
      print('Token: $token');
      print('User ID: $userId');

      // 2. Verify user has enough credits before proceeding
      final verifyResponse = await dio.post(
        '/api/mobile/verify-credits',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {
          'userId': userId,
        },
      );
      print('Verify response: ${verifyResponse.data}');

      if (verifyResponse.statusCode != 200) {
        throw Exception('Failed to verify user credits');
      }

      final hasEnoughCredits = verifyResponse.data['success'] as bool;
      if (!hasEnoughCredits) {
        throw Exception(
            'Insufficient credits. Please purchase more credits to continue.');
      }

      // 3. Upload image to Firebase Storage using the same path structure as the website
      final String fileName =
          'original_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Use the same storage path structure as the website
      final Reference storageRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('uploads')
          .child(fileName);

      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String imageUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded to Firebase: $imageUrl');

      // 4. Send request to API to generate transformation
      final response = await dio.post(
        '/api/mobile/generate-photo',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {
          'imageUrl': imageUrl,
          'roomType': roomType,
          'style': style,
          'customization': customization,
          'userId': userId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 5. Update user credits in the database
        final updateCreditsResponse = await dio.post(
          '/api/mobile/update-credits',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
          data: {
            'userId': userId,
          },
        );

        if (updateCreditsResponse.statusCode != 200 ||
            !(updateCreditsResponse.data['success'] as bool)) {
          print(
              'Warning: Failed to update credits, but transformation was successful');
        }

        // 6. Create transformation model from response
        return TransformationModel(
          id: response.data['id'].toString(),
          userId: userId,
          originalImageUrl: imageUrl,
          transformedImageUrl: response.data['url'],
          style: style,
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception(
            'Failed to create transformation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating transformation: $e');
      throw Exception('Error creating transformation: $e');
    }
  }
}
