import 'package:bizreview/features/auth/models/user_role.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? profileImage;
  final UserRole role;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImage,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid, UserRole role) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? map['displayName'] ?? map['username'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      role: role,
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? profileImage,
    UserRole? role,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, profileImage, role];
}
