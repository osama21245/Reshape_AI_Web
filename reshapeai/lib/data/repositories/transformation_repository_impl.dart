import 'dart:io';
import 'package:reshapeai/data/datasources/transformation_data_source.dart';
import 'package:reshapeai/domain/entities/transformation.dart';
import 'package:reshapeai/domain/repositories/transformation_repository.dart';

class TransformationRepositoryImpl implements TransformationRepository {
  final TransformationDataSource dataSource;

  TransformationRepositoryImpl({required this.dataSource});

  @override
  Future<List<Transformation>> getTransformations() async {
    return await dataSource.getTransformations();
  }

  @override
  Future<Transformation> createTransformation(
    File image,
    String style,
  ) async {
    return await dataSource.createTransformation(image, style);
  }
}
