import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/entities/user_entity.dart';

/// State for planner profile edit.
class PlannerProfileState {
  const PlannerProfileState({
    this.user,
    this.events = const [],
    this.recentCreatives = const [],
    this.isLoading = false,
    this.error,
  });

  final UserEntity? user;
  final List<EventEntity> events;
  final List<ProfileEntity> recentCreatives;
  final bool isLoading;
  final String? error;

  PlannerProfileState copyWith({
    UserEntity? user,
    List<EventEntity>? events,
    List<ProfileEntity>? recentCreatives,
    bool? isLoading,
    String? error,
  }) {
    return PlannerProfileState(
      user: user ?? this.user,
      events: events ?? this.events,
      recentCreatives: recentCreatives ?? this.recentCreatives,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
