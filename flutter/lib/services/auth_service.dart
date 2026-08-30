import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign in with email + password.
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Register new user and create their Firestore profile document.
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
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      throw Exception('Username already taken');
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'username': username,
      'image': 'default',
      'followingCount': 0,
      'followersCount': 0,
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
