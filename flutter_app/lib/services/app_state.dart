import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// Holds the currently-signed-in user's data and their feed.
/// Screens access this via Provider/context.
class AppState extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  UserModel? currentUser;
  List<PostModel> feed = [];
  List<String> following = [];
  bool loading = true;

  StreamSubscription<UserModel>? _userSub;
  StreamSubscription<List<String>>? _followingSub;

  void init(User firebaseUser) {
    // Guard: don't start duplicate listeners.
    if (_userSub != null) return;
    _userSub = _firestore.userStream().listen((u) {
      currentUser = u;
      loading = false;
      notifyListeners();
    });
    _followingSub = _firestore.followingStream().listen((ids) async {
      following = ids;
      feed = await _firestore.fetchFeed(ids);
      // Attach user objects to each post.
      for (final post in feed) {
        post.user ??= await _firestore.fetchUser(post.creatorUid);
      }
      notifyListeners();
    });
  }

  Future<void> refreshFeed() async {
    feed = await _firestore.fetchFeed(following);
    for (final post in feed) {
      post.user ??= await _firestore.fetchUser(post.creatorUid);
    }
    notifyListeners();
  }

  void clear() {
    _userSub?.cancel();
    _followingSub?.cancel();
    currentUser = null;
    feed = [];
    following = [];
    loading = true;
    notifyListeners();
  }
}
