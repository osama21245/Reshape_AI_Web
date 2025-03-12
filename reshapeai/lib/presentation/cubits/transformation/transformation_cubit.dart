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

  Future<void> fetchTransformations() async {
    try {
      emit(state.copyWith(status: TransformationStatus.loading));

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
    required File imageFile,
    required String roomType,
    required String style,
    String customization = '',
  }) async {
    try {
      // Check if user has enough credits
      final currentCredits = userCubit.state.user?.credits ?? 0;
      if (currentCredits <= 0) {
        emit(state.copyWith(
          status: TransformationStatus.error,
          error:
              'Insufficient credits. Please purchase more credits to continue.',
          uploadSuccess: false,
        ));
        return;
      }

      emit(state.copyWith(
        status: TransformationStatus.loading,
        uploadSuccess: false,
      ));

      // Process the transformation
      final result = await transformationDataSource.createTransformation(
        imageFile: imageFile,
        roomType: roomType,
        style: style,
        customization: customization,
      );

      // Update the user's credits in the UserCubit
      await userCubit.updateCreditsAfterTransformation();

      emit(state.copyWith(
        status: TransformationStatus.success,
        uploadSuccess: true,
        transformations: [...state.transformations, result],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransformationStatus.error,
        error: e.toString(),
        uploadSuccess: false,
      ));
    }
  }
}
