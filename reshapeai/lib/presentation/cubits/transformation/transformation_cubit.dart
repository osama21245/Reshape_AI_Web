import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reshapeai/data/datasources/transformation_data_source.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/presentation/cubits/transformation/transformation_state.dart';
import 'package:reshapeai/presentation/cubits/user/user_cubit.dart';

class TransformationCubit extends Cubit<TransformationState> {
  final TransformationDataSource transformationDataSource;
  final UserCubit userCubit;

  TransformationCubit({
    required this.transformationDataSource,
    required this.userCubit,
  }) : super(const TransformationState.initial());

  Future<void> getTransformations() async {
    try {
      emit(state.copyWith(status: TransformationStatus.loading));

      final transformations =
          await transformationDataSource.getTransformations();

      emit(state.copyWith(
        status: TransformationStatus.loaded,
        transformations: transformations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransformationStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<TransformationModel?> createTransformation({
    required File imageFile,
    required String roomType,
    required String style,
    String customization = '',
  }) async {
    try {
      emit(state.copyWith(
        status: TransformationStatus.creating,
        creationProgress: 0.1,
      ));

      // Check if user has enough credits
      // if (userCubit.state.user == null || userCubit.state.user!.credits < 1) {
      //   emit(state.copyWith(
      //     status: TransformationStatus.error,
      //     error:
      //         'Insufficient credits. Please purchase more credits to continue.',
      //   ));
      //   return null;
      // }

      // Update progress
      emit(state.copyWith(creationProgress: 0.3));

      // Create transformation
      final transformation =
          await transformationDataSource.createTransformation(
        imageFile: imageFile,
        roomType: roomType,
        style: style,
        customization: customization,
      );

      // Update progress
      emit(state.copyWith(creationProgress: 0.8));

      // Update user credits after successful transformation
      await userCubit.updateCreditsAfterTransformation();

      // Update transformations list
      final updatedTransformations = [
        transformation,
        ...state.transformations,
      ];

      // Set the latest transformation
      emit(state.copyWith(
        status: TransformationStatus.created,
        transformations: updatedTransformations,
        latestTransformation: transformation,
        creationProgress: 1.0,
      ));

      return transformation;
    } catch (e) {
      emit(state.copyWith(
        status: TransformationStatus.error,
        error: e.toString(),
      ));
      return null;
    }
  }

  void resetCreationState() {
    emit(state.copyWith(
      status: TransformationStatus.loaded,
      error: '',
      creationProgress: 0.0,
    ));
  }

  void clearLatestTransformation() {
    emit(state.copyWith(
      latestTransformation: null,
    ));
  }
}
