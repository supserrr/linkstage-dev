import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review_entity.dart';

/// Firestore model for review document.
class ReviewModel {
  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.comment = '',
    this.createdAt,
  });

  factory ReviewModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'] as Timestamp?;
    return ReviewModel(
      id: doc.id,
      bookingId: data['bookingId'] as String? ?? '',
      reviewerId: data['reviewerId'] as String? ?? '',
      revieweeId: data['revieweeId'] as String? ?? '',
      rating: data['rating'] as int? ?? 0,
      comment: data['comment'] as String? ?? '',
      createdAt: ts?.toDate(),
    );
  }

  final String id;
  final String bookingId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      bookingId: bookingId,
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }
}
