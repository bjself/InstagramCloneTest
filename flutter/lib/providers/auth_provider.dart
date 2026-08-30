import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  User? _firebaseUser;
  UserModel? _currentUser;
  StreamSubscription<UserModel>? _userSub;
  bool _loading = true;

  AuthProvider(this._authService, this._firestoreService) {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  bool get loading => _loading;
  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _firebaseUser != null;

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    _userSub?.cancel();
    if (user != null) {
      _userSub = _firestoreService
          .userStream(user.uid)
          .listen((u) {
        _currentUser = u;
        notifyListeners();
      });
    } else {
      _currentUser = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _authService.signIn(email, password);
      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    try {
      await _authService.register(
        email: email,
        password: password,
        name: name,
        username: username,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}
