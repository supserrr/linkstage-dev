import 'package:equatable/equatable.dart';

/// Domain entity for a review.
class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.comment = '',
    this.createdAt,
  });

  final String id;
  final String bookingId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, bookingId, reviewerId, revieweeId, rating, comment];
}
