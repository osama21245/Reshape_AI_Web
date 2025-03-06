import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reshapeai/domain/usecases/transformation/create_transformation_usecase.dart';
import 'package:reshapeai/domain/usecases/transformation/get_transformations_usecase.dart';
import 'package:reshapeai/presentation/cubits/transformation/transformation_state.dart';

class TransformationCubit extends Cubit<TransformationState> {
  final GetTransformationsUseCase _getTransformationsUseCase;
  final CreateTransformationUseCase _createTransformationUseCase;

  TransformationCubit({
    required GetTransformationsUseCase getTransformationsUseCase,
    required CreateTransformationUseCase createTransformationUseCase,
  })  : _getTransformationsUseCase = getTransformationsUseCase,
        _createTransformationUseCase = createTransformationUseCase,
        super(const TransformationState.initial());

  Future<void> fetchTransformations() async {
    emit(state.copyWith(status: TransformationStatus.loading));

    try {
      final transformations = await _getTransformationsUseCase();
      emit(state.copyWith(
        status: TransformationStatus.loaded,
        transformations: transformations,
      ));
    } catch (e) {
      print('Fetch Transformations Error: $e');
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
      final newTransformation = await _createTransformationUseCase(
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
      print('Upload Transformation Error: $e');
      emit(state.copyWith(
        uploadStatus: TransformationUploadStatus.error,
        uploadError: e.toString(),
      ));
    }
  }
}
