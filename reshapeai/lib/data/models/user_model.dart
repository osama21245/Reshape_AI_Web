import 'package:reshapeai/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String email,
    String? profileImage,
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          email: email,
          profileImage: profileImage,
          createdAt: createdAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'] ??
          'https://ui-avatars.com/api/?name=${json['name']}',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
