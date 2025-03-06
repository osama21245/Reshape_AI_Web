import 'dart:io';
import 'package:reshapeai/domain/entities/transformation.dart';

abstract class TransformationRepository {
  Future<List<Transformation>> getTransformations();
  Future<Transformation> createTransformation(
    File image,
    String style,
  );
}
