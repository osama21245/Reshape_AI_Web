import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reshapeai/data/datasources/auth_data_source.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/data/models/user_model.dart';
import 'package:reshapeai/presentation/cubits/auth/auth_state.dart';

import '../../../core/erorr/custom_errors/token_expired_exception.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthDataSource authDataSource;

  AuthCubit({
    required this.authDataSource,
  }) : super(const AuthState());

  Future<void> scanQrCode(String qrToken, String expiresAt) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      print('AuthCubit: Scanning QR code with token: $qrToken');

      // Use the data source to authenticate with QR code
      final result = await authDataSource.loginWithQrCode(qrToken, expiresAt);

      // Extract user and transformations from the result
      final user = result['user'] as UserModel;
      final token = result['token'] as String;
      final transformations =
          result['transformations'] as List<TransformationModel>;

      print('AuthCubit: User: $user');
      print('AuthCubit: Token: $token');
      print('AuthCubit: Transformations: $transformations');

      // Update the state with the authenticated user
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
        transformations: transformations,
      ));

      print('AuthCubit: Authentication successful');
    } catch (e) {
      print('AuthCubit: Authentication error: $e');

      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to authenticate: ${e.toString()}',
      ));
    }
  }

  // Future<void> refreshToken() async {
  //   try {
  //     // Don't change the state to loading to avoid UI flicker
  //     final deviceId =
  //         await authDataSource.secureStorage.read(key: 'device_id');

  //     if (deviceId != null) {
  //       print('AuthCubit: Refreshing token for device: $deviceId');

  //       final result = await authDataSource.refreshToken(deviceId);
  //       final newToken = result['token'] as String;

  //       // Update the token in the state
  //       emit(state.copyWith(token: newToken));

  //       print('AuthCubit: Token refreshed successfully');
  //     } else {
  //       print('AuthCubit: No device ID found, cannot refresh token');
  //     }
  //   } catch (e) {
  //     print('AuthCubit: Token refresh error: $e');
  //     // Don't update the state on error to avoid disrupting the user experience
  //   }
  // }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await authDataSource.logout();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await authDataSource.getCurrentUser();

      if (result != null) {
        final user = result['user'] as UserModel;
        final token = await authDataSource.getToken();
        final transformations =
            result['transformations'] as List<TransformationModel>;

        if (token != null) {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            token: token,
            transformations: transformations,
          ));

          // Schedule a token refresh if needed
          //   refreshToken();
        } else {
          emit(const AuthState(status: AuthStatus.unauthenticated));
        }
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      if (e is TokenExpiredException) {}
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
