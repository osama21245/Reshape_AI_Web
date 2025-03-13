import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:reshapeai/data/datasources/user_data_source.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/data/models/user_model.dart';
import 'package:reshapeai/presentation/cubits/user/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserDataSource userDataSource;

  UserCubit({
    required this.userDataSource,
  }) : super(const UserState.initial());

  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> getUserDetails() async {
    checkTokenExpirationWrapper(() async {
      try {
        final result = await userDataSource.getUserDetails();

        if (result == null) {
          throw Exception('User details not found');
        }

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
    });
  }

  Future<void> updateUserProfile({String? name, String? profileImage}) async {
    checkTokenExpirationWrapper(() async {
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
    });
  }

  Future<void> updateCreditsAfterTransformation() async {
    if (state.user == null) return;

    try {
      // Optimistically update the credits locally first
      final updatedUser = state.user!.copyWith(
        credits: state.user!.credits - 1,
      );

      emit(state.copyWith(
        user: updatedUser,
      ));

      // Then fetch the latest user data to ensure we have the correct credit count
      await getUserDetails();
    } catch (e) {
      // If there's an error, refresh user data to get the correct credit count
      await getUserDetails();
    }
  }

  void logOut() {
    userDataSource.logOut();
  }

  Future<void> checkTokenExpirationWrapper(
      Future<void> Function() function) async {
    try {
      emit(state.copyWith(status: UserStatus.loading));
      final expiresAt = await secureStorage.read(key: 'expires_at');
      if (expiresAt == null) {
        throw Exception('No expiration date found');
      }
      final expiresAtDate = DateTime.parse(expiresAt);
      final now = DateTime.now();
      if (expiresAtDate.isBefore(now)) {
        await userDataSource.refreshToken();
      }
      await function();
    } catch (e) {
      emit(state.copyWith(
        status: UserStatus.error,
        error: e.toString(),
      ));
    }
  }
}
