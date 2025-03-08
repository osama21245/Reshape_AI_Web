import 'package:equatable/equatable.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/domain/entities/user.dart';

enum UserStatus {
  initial,
  loading,
  loaded,
  error,
}

class UserState extends Equatable {
  final UserStatus status;
  final User? user;
  final List<TransformationModel> transformations;
  final String? error;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.transformations = const [],
    this.error,
  });

  const UserState.initial()
      : status = UserStatus.initial,
        user = null,
        transformations = const [],
        error = null;

  UserState copyWith({
    UserStatus? status,
    User? user,
    List<TransformationModel>? transformations,
    String? error,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      transformations: transformations ?? this.transformations,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, user, transformations, error];
}
