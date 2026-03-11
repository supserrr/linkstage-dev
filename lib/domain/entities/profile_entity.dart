import 'package:equatable/equatable.dart';

/// Creative professional category.
enum ProfileCategory { dj, photographer, decorator, contentCreator }

/// Domain entity for creative professional profile.
class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    required this.userId,
    this.username,
    this.bio = '',
    this.category,
    this.priceRange = '',
    this.location = '',
    this.portfolioUrls = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.displayName,
  });

  /// Profile doc ID when keyed by username. id == username.
  final String id;
  final String userId;
  final String? username;
  final String bio;
  final ProfileCategory? category;
  final String priceRange;
  final String location;
  final List<String> portfolioUrls;
  final double rating;
  final int reviewCount;
  final String? displayName;

  String get categoryKey {
    switch (category) {
      case ProfileCategory.dj:
        return 'dj';
      case ProfileCategory.photographer:
        return 'photographer';
      case ProfileCategory.decorator:
        return 'decorator';
      case ProfileCategory.contentCreator:
        return 'content_creator';
      case null:
        return '';
    }
  }

  static ProfileCategory? categoryFromKey(String? key) {
    switch (key) {
      case 'dj':
        return ProfileCategory.dj;
      case 'photographer':
        return ProfileCategory.photographer;
      case 'decorator':
        return ProfileCategory.decorator;
      case 'content_creator':
        return ProfileCategory.contentCreator;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [id, userId, username, bio, category, priceRange, location];
}
