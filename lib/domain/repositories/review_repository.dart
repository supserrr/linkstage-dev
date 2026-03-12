import '../entities/review_entity.dart';

/// Abstract contract for review operations.
abstract class ReviewRepository {
  /// Fetch reviews where the given user was reviewed (as reviewee).
  Future<List<ReviewEntity>> getReviewsByRevieweeId(String revieweeId);
}
