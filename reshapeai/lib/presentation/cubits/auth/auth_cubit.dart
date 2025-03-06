import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reshapeai/domain/entities/user.dart';
import 'package:reshapeai/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:reshapeai/domain/usecases/auth/get_token_usecase.dart';
import 'package:reshapeai/domain/usecases/auth/logout_usecase.dart';
import 'package:reshapeai/domain/usecases/auth/scan_qr_usecase.dart';
import 'package:reshapeai/presentation/cubits/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ScanQrUseCase _scanQrUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetTokenUseCase _getTokenUseCase;

  AuthCubit({
    required ScanQrUseCase scanQrUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetTokenUseCase getTokenUseCase,
  })  : _scanQrUseCase = scanQrUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getTokenUseCase = getTokenUseCase,
        super(const AuthState());

  // We're keeping the login and register methods for backward compatibility,
  // but they're not used in the QR code authentication flow
  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // For demo purposes, just check if email contains '@'
      if (!email.contains('@')) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Invalid email format',
        ));
        return;
      }

      // Simulate successful login
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: User(
          id: '1',
          name: 'Demo User',
          email: email,
          createdAt: DateTime.now(),
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // For demo purposes, just check if email contains '@'
      if (!email.contains('@')) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Invalid email format',
        ));
        return;
      }

      // Simulate successful registration
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: User(
          id: '1',
          name: name,
          email: email,
          createdAt: DateTime.now(),
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _logoutUseCase();
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
      final user = await _getCurrentUserUseCase();
      final token = await _getTokenUseCase();

      if (user != null && token != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: token,
        ));
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> scanQrCode(String qrToken) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await _scanQrUseCase(qrToken);
      final user = result['user'];

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: User(
          id: user['id'],
          name: user['name'],
          email: user['email'],
          profileImage: user['image'],
          createdAt: DateTime.now(), // API doesn't return createdAt
        ),
        token: await _getTokenUseCase(),
      ));
    } catch (e) {
      print('QR Authentication Error: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to authenticate: ${e.toString()}',
      ));
    }
  }
}
