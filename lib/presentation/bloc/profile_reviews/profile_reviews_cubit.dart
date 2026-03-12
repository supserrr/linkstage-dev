import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/review_repository.dart';
import 'profile_reviews_state.dart';

/// Cubit for profile reviews screen.
class ProfileReviewsCubit extends Cubit<ProfileReviewsState> {
  ProfileReviewsCubit(this._reviewRepository, this._userId)
      : super(const ProfileReviewsState()) {
    load();
  }

  final ReviewRepository _reviewRepository;
  final String _userId;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final reviews =
          await _reviewRepository.getReviewsByRevieweeId(_userId);
      emit(state.copyWith(reviews: reviews, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  Future<void> addReply(String reviewId, String text) async {
    try {
      await _reviewRepository.addReply(reviewId, text);
      await load();
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  Future<void> likeReview(String reviewId) async {
    try {
      await _reviewRepository.likeReview(reviewId, _userId);
      await load();
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  Future<void> flagReview(String reviewId) async {
    try {
      await _reviewRepository.flagReview(reviewId, _userId);
      await load();
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
