import '../entities/review_entity.dart';

/// Abstract contract for review operations.
abstract class ReviewRepository {
  /// Fetch reviews where the given user was reviewed (as reviewee).
  Future<List<ReviewEntity>> getReviewsByRevieweeId(String revieweeId);

  /// Add or update reply to a review.
  Future<void> addReply(String reviewId, String text);

  /// Toggle like on a review.
  Future<void> likeReview(String reviewId, String userId);

  /// Toggle flag on a review.
  Future<void> flagReview(String reviewId, String userId);
}
