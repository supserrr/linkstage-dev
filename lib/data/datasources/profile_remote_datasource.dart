import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entity_extensions.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/profile_model.dart';

/// Remote data source for profiles in Firestore.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _profilesCollection = 'profiles';

  Stream<List<ProfileEntity>> getProfiles({
    ProfileCategory? category,
    String? location,
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(
      _profilesCollection,
    );

    if (category != null) {
      query = query.where('category', isEqualTo: category.categoryKey);
    }
    if (location != null && location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }
    query = query.limit(limit);

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((d) => ProfileModel.fromFirestore(d).toEntity())
          .toList(),
    );
  }

  Future<ProfileEntity?> getProfile(String username) async {
    final doc = await _firestore
        .collection(_profilesCollection)
        .doc(_normalizeUsername(username))
        .get();
    if (doc.exists && doc.data() != null) {
      return ProfileModel.fromFirestore(doc).toEntity();
    }
    return null;
  }

  Future<ProfileEntity?> getProfileByUserId(String userId) async {
    final snapshot = await _firestore
        .collection(_profilesCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return ProfileModel.fromFirestore(snapshot.docs.first).toEntity();
    }
    return null;
  }

  static String _normalizeUsername(String s) => s.toLowerCase();

  Future<void> upsertProfile(ProfileEntity profile) async {
    final username = profile.id.isNotEmpty ? profile.id : profile.username ?? '';
    if (username.isEmpty) {
      throw ArgumentError('Profile must have username as id');
    }
    final docId = _normalizeUsername(username);
    final model = ProfileModel(
      id: docId,
      userId: profile.userId,
      username: username,
      bio: profile.bio,
      category: profile.category,
      priceRange: profile.priceRange,
      location: profile.location,
      portfolioUrls: profile.portfolioUrls,
      portfolioVideoUrls: profile.portfolioVideoUrls,
      availability: profile.availability,
      services: profile.services,
      languages: profile.languages,
      professions: profile.professions,
      rating: profile.rating,
      reviewCount: profile.reviewCount,
      displayName: profile.displayName,
    );
    await _firestore
        .collection(_profilesCollection)
        .doc(docId)
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteProfile(String username) async {
    await _firestore
        .collection(_profilesCollection)
        .doc(_normalizeUsername(username))
        .delete();
  }

  Stream<ProfileEntity?> watchProfile(String username) {
    return _firestore
        .collection(_profilesCollection)
        .doc(_normalizeUsername(username))
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return ProfileModel.fromFirestore(doc).toEntity();
      }
      return null;
    });
  }
}
