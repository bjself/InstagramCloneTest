import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Auth operations used throughout the app.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign in with email + password.
  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  /// Create a new account, then write the user document to Firestore.
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    // Check username uniqueness first.
    final snap = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (snap.docs.isNotEmpty) {
      throw Exception('Username already taken');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'username': username,
      'image': 'default',
      'followingCount': 0,
      'followersCount': 0,
      'description': '',
      'banned': false,
    });
  }

  Future<void> signOut() => _auth.signOut();
}
