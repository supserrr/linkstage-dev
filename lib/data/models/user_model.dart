import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entity_extensions.dart';
import '../../domain/entities/user_entity.dart';

/// Firestore model for user document.
class UserModel {
  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.photoUrl,
    this.role,
    this.createdAt,
    this.lastUsernameChangeAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final ts = data['lastUsernameChangeAt'] as Timestamp?;
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: UserEntity.roleFromKey(data['role'] as String?),
      createdAt: data['createdAt'] as Timestamp?,
      lastUsernameChangeAt: ts,
    );
  }

  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? photoUrl;
  final UserRole? role;
  final Timestamp? createdAt;
  final Timestamp? lastUsernameChangeAt;

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role?.roleKey,
      'lastUsernameChangeAt': lastUsernameChangeAt,
      if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      displayName: displayName,
      photoUrl: photoUrl,
      role: role,
      lastUsernameChangeAt: lastUsernameChangeAt?.toDate(),
    );
  }
}
