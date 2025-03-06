import 'package:reshapeai/domain/entities/transformation.dart';
import 'package:reshapeai/domain/repositories/transformation_repository.dart';

class GetTransformationsUseCase {
  final TransformationRepository repository;

  GetTransformationsUseCase({required this.repository});

  Future<List<Transformation>> call() {
    return repository.getTransformations();
  }
}
