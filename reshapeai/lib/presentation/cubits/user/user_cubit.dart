import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reshapeai/domain/usecases/user/get_user_details_usecase.dart';
import 'package:reshapeai/domain/usecases/user/update_user_profile_usecase.dart';
import 'package:reshapeai/presentation/cubits/user/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetUserDetailsUseCase _getUserDetailsUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  UserCubit({
    required GetUserDetailsUseCase getUserDetailsUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  })  : _getUserDetailsUseCase = getUserDetailsUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        super(const UserState());

  Future<void> getUserDetails() async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final user = await _getUserDetailsUseCase();
      emit(state.copyWith(
        status: UserStatus.loaded,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? profileImage,
  }) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      // Ensure we have a current user
      if (state.user == null) {
        throw Exception('No user found');
      }

      final updatedUser = await _updateUserProfileUseCase(
        name: name,
        profileImage: profileImage,
      );

      emit(state.copyWith(
        status: UserStatus.loaded,
        user: updatedUser,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
