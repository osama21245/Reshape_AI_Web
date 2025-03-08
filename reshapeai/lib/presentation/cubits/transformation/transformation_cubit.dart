import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reshapeai/data/datasources/transformation_data_source.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/presentation/cubits/transformation/transformation_state.dart';

class TransformationCubit extends Cubit<TransformationState> {
  final TransformationDataSource transformationDataSource;

  TransformationCubit({
    required this.transformationDataSource,
  }) : super(const TransformationState());

  Future<void> fetchTransformations() async {
    emit(state.copyWith(status: TransformationStatus.loading));

    try {
      final transformations =
          await transformationDataSource.getTransformations();

      emit(state.copyWith(
        status: TransformationStatus.success,
        transformations: transformations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransformationStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> uploadTransformation({
    required File originalImage,
    required String style,
  }) async {
    emit(state.copyWith(uploadStatus: TransformationUploadStatus.loading));

    try {
      final newTransformation =
          await transformationDataSource.createTransformation(
        originalImage,
        style,
      );

      // Add the new transformation to the list
      final updatedTransformations = [
        newTransformation,
        ...state.transformations,
      ];

      emit(state.copyWith(
        uploadStatus: TransformationUploadStatus.success,
        transformations: updatedTransformations,
      ));
    } catch (e) {
      emit(state.copyWith(
        uploadStatus: TransformationUploadStatus.error,
        uploadError: e.toString(),
      ));
    }
  }
}
