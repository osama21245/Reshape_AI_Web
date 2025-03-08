import 'package:equatable/equatable.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? errorMessage;
  final List<TransformationModel> transformations;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
    this.transformations = const [],
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? errorMessage,
    List<TransformationModel>? transformations,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
      transformations: transformations ?? this.transformations,
    );
  }

  @override
  List<Object?> get props =>
      [status, user, token, errorMessage, transformations];
}
