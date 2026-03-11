import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';

/// Remote data source for authentication (Firebase Auth).
class AuthRemoteDataSource {
  AuthRemoteDataSource({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<UserEntity?> get authStateChanges =>
      _auth.authStateChanges().map(_userFromFirebase);

  UserEntity? get currentUser => _userFromFirebase(_auth.currentUser);

  Future<UserEntity> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = _userFromFirebase(cred.user);
    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'Sign in failed');
    }
    return user;
  }

  Future<UserEntity> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'Registration failed',
      );
    }
    await user.updateDisplayName(displayName);
    return _userFromFirebase(user)!;
  }

  Future<UserEntity> signInWithGoogle() async {
    GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } catch (_) {
      throw FirebaseAuthException(
        code: 'cancelled',
        message: 'Sign in cancelled',
      );
    }
    final googleAuth = googleUser.authentication;
    final cred = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(cred);
    final user = _userFromFirebase(result.user);
    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'Sign in failed');
    }
    return user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  UserEntity? _userFromFirebase(User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      role: null,
    );
  }
}
