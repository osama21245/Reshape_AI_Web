import 'package:equatable/equatable.dart';
import 'package:reshapeai/domain/entities/transformation.dart';

enum TransformationStatus {
  initial,
  loading,
  loaded,
  error,
}

enum TransformationUploadStatus {
  initial,
  loading,
  success,
  error,
}

class TransformationState extends Equatable {
  final TransformationStatus status;
  final List<Transformation> transformations;
  final String? error;
  final TransformationUploadStatus uploadStatus;
  final String? uploadError;

  const TransformationState({
    this.status = TransformationStatus.initial,
    this.transformations = const [],
    this.error,
    this.uploadStatus = TransformationUploadStatus.initial,
    this.uploadError,
  });

  const TransformationState.initial()
      : status = TransformationStatus.initial,
        transformations = const [],
        error = null,
        uploadStatus = TransformationUploadStatus.initial,
        uploadError = null;

  TransformationState copyWith({
    TransformationStatus? status,
    List<Transformation>? transformations,
    String? error,
    TransformationUploadStatus? uploadStatus,
    String? uploadError,
  }) {
    return TransformationState(
      status: status ?? this.status,
      transformations: transformations ?? this.transformations,
      error: error ?? this.error,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadError: uploadError ?? this.uploadError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transformations,
        error,
        uploadStatus,
        uploadError,
      ];
}
