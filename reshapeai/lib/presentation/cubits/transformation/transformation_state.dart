import 'package:equatable/equatable.dart';
import 'package:reshapeai/data/models/transformation_model.dart';

enum TransformationStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  error,
}

class TransformationState extends Equatable {
  final TransformationStatus status;
  final List<TransformationModel> transformations;
  final TransformationModel? latestTransformation;
  final String error;
  final double creationProgress;

  const TransformationState({
    required this.status,
    required this.transformations,
    this.latestTransformation,
    required this.error,
    this.creationProgress = 0.0,
  });

  const TransformationState.initial()
      : status = TransformationStatus.initial,
        transformations = const [],
        latestTransformation = null,
        error = '',
        creationProgress = 0.0;

  TransformationState copyWith({
    TransformationStatus? status,
    List<TransformationModel>? transformations,
    TransformationModel? latestTransformation,
    String? error,
    double? creationProgress,
  }) {
    return TransformationState(
      status: status ?? this.status,
      transformations: transformations ?? this.transformations,
      latestTransformation: latestTransformation ?? this.latestTransformation,
      error: error ?? this.error,
      creationProgress: creationProgress ?? this.creationProgress,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transformations,
        latestTransformation,
        error,
        creationProgress,
      ];
}
