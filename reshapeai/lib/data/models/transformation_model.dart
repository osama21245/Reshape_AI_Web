import 'package:reshapeai/domain/entities/transformation.dart';

class TransformationModel extends Transformation {
  const TransformationModel({
    required String id,
    required String userId,
    required String originalImageUrl,
    required String transformedImageUrl,
    required String style,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          originalImageUrl: originalImageUrl,
          transformedImageUrl: transformedImageUrl,
          style: style,
          createdAt: createdAt,
        );

  factory TransformationModel.fromJson(Map<String, dynamic> json) {
    return TransformationModel(
      id: json['id'].toString(),
      userId: json['userId'],
      originalImageUrl: json['originalImageUrl'],
      transformedImageUrl: json['transformedImageUrl'],
      style: json['style'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'originalImageUrl': originalImageUrl,
      'transformedImageUrl': transformedImageUrl,
      'style': style,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
