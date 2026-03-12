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
}
