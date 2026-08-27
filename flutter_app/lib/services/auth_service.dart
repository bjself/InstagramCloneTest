import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------- Sign In ----------
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ---------- Register ----------
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    // Check username uniqueness
    final snap = await _firestore
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

    final uid = credential.user!.uid;

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'username': username,
      'image': 'default',
      'followingCount': 0,
      'followersCount': 0,
      'description': '',
    });
  }

  // ---------- Sign Out ----------
  Future<void> signOut() => _auth.signOut();
}
