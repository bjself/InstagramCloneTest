import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _currentUser;
  bool _loading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _currentUser = await _firestoreService.getUser(user.uid);
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email: email, password: password);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.register(
        email: email,
        password: password,
        name: name,
        username: username,
      );
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
