import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entity_extensions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Remote data source for user documents in Firestore.
class UserRemoteDataSource {
  UserRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _profilesCollection = 'profiles';

  Future<UserEntity?> getUser(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc).toEntity();
    }
    return null;
  }

  Future<void> upsertUser(UserEntity user) async {
    final model = UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      role: user.role,
      lastUsernameChangeAt: user.lastUsernameChangeAt != null
          ? Timestamp.fromDate(user.lastUsernameChangeAt!)
          : null,
    );
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  Future<bool> checkUsernameAvailable(String username, {String? excludeUserId}) async {
    final doc = await _firestore
        .collection(_profilesCollection)
        .doc(username.toLowerCase())
        .get();
    if (!doc.exists) return true;
    if (excludeUserId != null) {
      final data = doc.data();
      final docUserId = data?['userId'] as String?;
      return docUserId == excludeUserId;
    }
    return false;
  }

  Future<void> updateUsername(
    String userId,
    String newUsername,
    DateTime lastUsernameChangeAt,
  ) async {
    await _firestore.collection(_usersCollection).doc(userId).update({
      'username': newUsername.toLowerCase(),
      'lastUsernameChangeAt': Timestamp.fromDate(lastUsernameChangeAt),
    });
  }

  Future<void> updateRole(String userId, UserRole role) async {
    await _firestore.collection(_usersCollection).doc(userId).update({
      'role': role.roleKey,
    });
  }

  Stream<UserEntity?> watchUser(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc).toEntity();
      }
      return null;
    });
  }
}
