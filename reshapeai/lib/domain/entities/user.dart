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

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    DateTime? createdAt,
    int? credits,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      credits: credits ?? this.credits,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, profileImage, createdAt, credits];
}
