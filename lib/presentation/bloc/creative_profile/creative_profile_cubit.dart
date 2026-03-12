import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/profile_entity.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/repositories/review_repository.dart';
import 'creative_profile_state.dart';

/// Cubit for creative profile edit flow.
class CreativeProfileCubit extends Cubit<CreativeProfileState> {
  CreativeProfileCubit(
    this._profileRepository,
    this._reviewRepository,
    this._bookingRepository,
    String userId,
  ) : _userId = userId,
       super(const CreativeProfileState()) {
    load(userId);
  }

  final ProfileRepository _profileRepository;
  final String _userId;
  final ReviewRepository _reviewRepository;
  final BookingRepository _bookingRepository;

  Future<void> load(String userId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final profile = await _profileRepository.getProfileByUserId(userId);
      final reviews = await _reviewRepository.getReviewsByRevieweeId(userId);
      final bookings =
          await _bookingRepository.getCompletedBookingsByCreativeId(userId);
      emit(state.copyWith(
        profile: profile,
        reviews: reviews,
        totalGigs: bookings.length,
        followersCount: 0,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  void setBio(String value) {
    final p = state.profile;
    if (p != null) {
      emit(state.copyWith(
        profile: ProfileEntity(
          id: p.id,
          userId: p.userId,
          username: p.username,
          bio: value,
          category: p.category,
          priceRange: p.priceRange,
          location: p.location,
          portfolioUrls: p.portfolioUrls,
          portfolioVideoUrls: p.portfolioVideoUrls,
          availability: p.availability,
          services: p.services,
          languages: p.languages,
          professions: p.professions,
          rating: p.rating,
          reviewCount: p.reviewCount,
          displayName: p.displayName,
        ),
      ));
    }
  }

  void setPriceRange(String value) {
    final p = state.profile;
    if (p != null) {
      emit(state.copyWith(
        profile: ProfileEntity(
          id: p.id,
          userId: p.userId,
          username: p.username,
          bio: p.bio,
          category: p.category,
          priceRange: value,
          location: p.location,
          portfolioUrls: p.portfolioUrls,
          portfolioVideoUrls: p.portfolioVideoUrls,
          availability: p.availability,
          services: p.services,
          languages: p.languages,
          professions: p.professions,
          rating: p.rating,
          reviewCount: p.reviewCount,
          displayName: p.displayName,
        ),
      ));
    }
  }

  void setProfessions(List<String> value) {
    final p = state.profile;
    if (p != null) {
      emit(state.copyWith(
        profile: ProfileEntity(
          id: p.id,
          userId: p.userId,
          username: p.username,
          bio: p.bio,
          category: p.category,
          professions: value,
          priceRange: p.priceRange,
          location: p.location,
          portfolioUrls: p.portfolioUrls,
          portfolioVideoUrls: p.portfolioVideoUrls,
          availability: p.availability,
          services: p.services,
          languages: p.languages,
          rating: p.rating,
          reviewCount: p.reviewCount,
          displayName: p.displayName,
        ),
      ));
    }
  }

  void setLocation(String value) {
    final p = state.profile;
    if (p != null) {
      emit(state.copyWith(
        profile: ProfileEntity(
          id: p.id,
          userId: p.userId,
          username: p.username,
          bio: p.bio,
          category: p.category,
          priceRange: p.priceRange,
          location: value,
          portfolioUrls: p.portfolioUrls,
          portfolioVideoUrls: p.portfolioVideoUrls,
          availability: p.availability,
          services: p.services,
          languages: p.languages,
          professions: p.professions,
          rating: p.rating,
          reviewCount: p.reviewCount,
          displayName: p.displayName,
        ),
      ));
    }
  }

  void setAvailability(ProfileAvailability? value) {
    final p = state.profile;
    if (p != null) {
      emit(state.copyWith(
        profile: ProfileEntity(
          id: p.id,
          userId: p.userId,
          username: p.username,
          bio: p.bio,
          category: p.category,
          priceRange: p.priceRange,
          location: p.location,
          portfolioUrls: p.portfolioUrls,
          portfolioVideoUrls: p.portfolioVideoUrls,
          availability: value,
          services: p.services,
          languages: p.languages,
          professions: p.professions,
          rating: p.rating,
          reviewCount: p.reviewCount,
          displayName: p.displayName,
        ),
      ));
    }
  }

  void setPortfolioUrls(List<String> value) {
    final p = state.profile;
    if (p != null) {
      emit(state.copyWith(
        profile: ProfileEntity(
          id: p.id,
          userId: p.userId,
          username: p.username,
          bio: p.bio,
          category: p.category,
          priceRange: p.priceRange,
          location: p.location,
          portfolioUrls: value,
          portfolioVideoUrls: p.portfolioVideoUrls,
          availability: p.availability,
          services: p.services,
          languages: p.languages,
          professions: p.professions,
          rating: p.rating,
          reviewCount: p.reviewCount,
          displayName: p.displayName,
        ),
      ));
    }
  }

  void setPortfolioVideoUrls(List<String> value) {
    final p = state.profile;
    if (p != null) {
      emit(state.copyWith(
        profile: ProfileEntity(
          id: p.id,
          userId: p.userId,
          username: p.username,
          bio: p.bio,
          category: p.category,
          priceRange: p.priceRange,
          location: p.location,
          portfolioUrls: p.portfolioUrls,
          portfolioVideoUrls: value,
          availability: p.availability,
          services: p.services,
          languages: p.languages,
          professions: p.professions,
          rating: p.rating,
          reviewCount: p.reviewCount,
          displayName: p.displayName,
        ),
      ));
    }
  }

  void setServices(List<String> value) {
    final p = state.profile;
    if (p != null) {
      emit(state.copyWith(
        profile: ProfileEntity(
          id: p.id,
          userId: p.userId,
          username: p.username,
          bio: p.bio,
          category: p.category,
          priceRange: p.priceRange,
          location: p.location,
          portfolioUrls: p.portfolioUrls,
          portfolioVideoUrls: p.portfolioVideoUrls,
          availability: p.availability,
          services: value,
          languages: p.languages,
          professions: p.professions,
          rating: p.rating,
          reviewCount: p.reviewCount,
          displayName: p.displayName,
        ),
      ));
    }
  }

  void setLanguages(List<String> value) {
    final p = state.profile;
    if (p != null) {
      emit(state.copyWith(
        profile: ProfileEntity(
          id: p.id,
          userId: p.userId,
          username: p.username,
          bio: p.bio,
          category: p.category,
          priceRange: p.priceRange,
          location: p.location,
          portfolioUrls: p.portfolioUrls,
          portfolioVideoUrls: p.portfolioVideoUrls,
          availability: p.availability,
          services: p.services,
          languages: value,
          professions: p.professions,
          rating: p.rating,
          reviewCount: p.reviewCount,
          displayName: p.displayName,
        ),
      ));
    }
  }

  /// Reload profile and related data (e.g. after returning from edit).
  Future<void> refresh() => load(_userId);

  Future<void> save() async {
    final p = state.profile;
    if (p == null) return;
    emit(state.copyWith(isSaving: true, error: null));
    try {
      await _profileRepository.upsertProfile(p);
      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
