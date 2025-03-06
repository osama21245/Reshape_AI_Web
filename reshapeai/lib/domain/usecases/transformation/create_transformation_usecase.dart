import 'dart:io';
import 'package:reshapeai/domain/entities/transformation.dart';
import 'package:reshapeai/domain/repositories/transformation_repository.dart';

class CreateTransformationUseCase {
  final TransformationRepository repository;

  CreateTransformationUseCase({required this.repository});

  Future<Transformation> call(File image, String style) {
    return repository.createTransformation(image, style);
  }
}
