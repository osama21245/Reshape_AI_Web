import 'package:equatable/equatable.dart';
import 'package:reshapeai/domain/entities/transformation.dart';

enum TransformationStatus {
  initial,
  loading,
  success,
  error,
}

class TransformationState extends Equatable {
  final TransformationStatus status;
  final List<Transformation> transformations;
  final String? error;
  final bool uploadSuccess;

  const TransformationState({
    this.status = TransformationStatus.initial,
    this.transformations = const [],
    this.error,
    this.uploadSuccess = false,
  });

  const TransformationState.initial()
      : status = TransformationStatus.initial,
        transformations = const [],
        error = null,
        uploadSuccess = false;

  TransformationState copyWith({
    TransformationStatus? status,
    List<Transformation>? transformations,
    String? error,
    bool? uploadSuccess,
  }) {
    return TransformationState(
      status: status ?? this.status,
      transformations: transformations ?? this.transformations,
      error: error,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
    );
  }

  @override
  List<Object?> get props => [status, transformations, error, uploadSuccess];
}
