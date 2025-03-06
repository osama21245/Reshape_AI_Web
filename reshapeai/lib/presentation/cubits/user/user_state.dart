import 'package:equatable/equatable.dart';
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
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.errorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
