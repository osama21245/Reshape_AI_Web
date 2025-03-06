import 'package:equatable/equatable.dart';

class Transformation extends Equatable {
  final String id;
  final String userId;
  final String originalImageUrl;
  final String transformedImageUrl;
  final String style;
  final DateTime createdAt;

  const Transformation({
    required this.id,
    required this.userId,
    required this.originalImageUrl,
    required this.transformedImageUrl,
    required this.style,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        originalImageUrl,
        transformedImageUrl,
        style,
        createdAt,
      ];
}
