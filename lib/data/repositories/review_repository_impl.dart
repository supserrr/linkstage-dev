import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

/// Implementation of [ReviewRepository] using Firestore.
class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._remote);

  final ReviewRemoteDataSource _remote;

  @override
  Future<List<ReviewEntity>> getReviewsByRevieweeId(String revieweeId) =>
      _remote.getReviewsByRevieweeId(revieweeId);
}
