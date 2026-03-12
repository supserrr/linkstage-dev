import '../../../domain/entities/review_entity.dart';

/// State for profile reviews screen.
class ProfileReviewsState {
  const ProfileReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ReviewEntity> reviews;
  final bool isLoading;
  final String? error;

  ProfileReviewsState copyWith({
    List<ReviewEntity>? reviews,
    bool? isLoading,
    String? error,
  }) =>
      ProfileReviewsState(
        reviews: reviews ?? this.reviews,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}
