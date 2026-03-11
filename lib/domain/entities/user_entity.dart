import 'package:equatable/equatable.dart';

/// User role in the platform.
enum UserRole { eventPlanner, creativeProfessional }

/// Domain entity representing a user.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.photoUrl,
    this.role,
    this.lastUsernameChangeAt,
  });

  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? photoUrl;
  final UserRole? role;
  final DateTime? lastUsernameChangeAt;

  String get roleKey {
    switch (role) {
      case UserRole.eventPlanner:
        return 'event_planner';
      case UserRole.creativeProfessional:
        return 'creative_professional';
      case null:
        return '';
    }
  }

  static UserRole? roleFromKey(String? key) {
    switch (key) {
      case 'event_planner':
        return UserRole.eventPlanner;
      case 'creative_professional':
        return UserRole.creativeProfessional;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [id, email, username, displayName, photoUrl, role, lastUsernameChangeAt];
}
