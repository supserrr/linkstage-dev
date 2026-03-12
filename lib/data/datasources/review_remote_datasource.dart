import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review_entity.dart';
import '../models/review_model.dart';

/// Remote data source for reviews in Firestore.
class ReviewRemoteDataSource {
  ReviewRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _reviewsCollection = 'reviews';

  /// Fetch reviews where the given user was reviewed (as reviewee).
  Future<List<ReviewEntity>> getReviewsByRevieweeId(String revieweeId) async {
    final snapshot = await _firestore
        .collection(_reviewsCollection)
        .where('revieweeId', isEqualTo: revieweeId)
        .get();
    return snapshot.docs
        .map((d) => ReviewModel.fromFirestore(d).toEntity())
        .toList();
  }

  /// Add or update reply to a review.
  Future<void> addReply(String reviewId, String text) async {
    await _firestore.collection(_reviewsCollection).doc(reviewId).update({
      'reply': text,
      'replyAt': FieldValue.serverTimestamp(),
    });
  }

  /// Toggle like: add userId to likedBy if not present, remove if present.
  Future<void> likeReview(String reviewId, String userId) async {
    final ref = _firestore.collection(_reviewsCollection).doc(reviewId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (doc.data() == null) return;
      final likedBy =
          List<String>.from((doc.data()!['likedBy'] as List<dynamic>?) ?? []);
      final hasLiked = likedBy.contains(userId);
      if (hasLiked) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }
      transaction.update(ref, {'likedBy': likedBy, 'likeCount': likedBy.length});
    });
  }

  /// Toggle flag: add userId to flaggedBy if not present, remove if present.
  Future<void> flagReview(String reviewId, String userId) async {
    final ref = _firestore.collection(_reviewsCollection).doc(reviewId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (doc.data() == null) return;
      final flaggedBy =
          List<String>.from((doc.data()!['flaggedBy'] as List<dynamic>?) ?? []);
      final hasFlagged = flaggedBy.contains(userId);
      if (hasFlagged) {
        flaggedBy.remove(userId);
      } else {
        flaggedBy.add(userId);
      }
      transaction.update(
        ref,
        {'flaggedBy': flaggedBy, 'flagCount': flaggedBy.length},
      );
    });
  }
}
