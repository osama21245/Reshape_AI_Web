import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, profileImage, createdAt];
}
