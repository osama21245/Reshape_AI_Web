import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final int credits;
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.createdAt,
    required this.credits,
  });

  @override
  List<Object?> get props => [id, name, email, profileImage, createdAt, credits];
}
