import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reshapeai/data/datasources/user_data_source.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/data/models/user_model.dart';
import 'package:reshapeai/presentation/cubits/user/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserDataSource userDataSource;

  UserCubit({
    required this.userDataSource,
  }) : super(const UserState.initial());

  Future<void> getUserDetails() async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final result = await userDataSource.getUserDetails();

      final user = result['user'] as UserModel;
      final transformations =
          result['transformations'] as List<TransformationModel>;

      emit(state.copyWith(
        status: UserStatus.loaded,
        user: user,
        transformations: transformations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> updateUserProfile({String? name, String? profileImage}) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final result = await userDataSource.updateUserProfile(
        name: name,
        profileImage: profileImage,
      );

      final user = result['user'] as UserModel;
      final transformations =
          result['transformations'] as List<TransformationModel>;

      emit(state.copyWith(
        status: UserStatus.loaded,
        user: user,
        transformations: transformations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.error,
        error: e.toString(),
      ));
    }
  }
}
