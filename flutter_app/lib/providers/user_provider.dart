import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  // Cache of loaded profiles: uid → UserModel
  final Map<String, UserModel> _cache = {};
  List<String> _followingUids = [];

  List<String> get followingUids => _followingUids;

  UserModel? cached(String uid) => _cache[uid];

  Future<UserModel?> loadUser(String uid) async {
    if (_cache.containsKey(uid)) return _cache[uid];
    final user = await _service.getUser(uid);
    if (user != null) {
      _cache[uid] = user;
      notifyListeners();
    }
    return user;
  }

  void listenFollowing() {
    _service.followingUids().listen((uids) {
      _followingUids = uids;
      notifyListeners();
    });
  }

  bool isFollowing(String uid) => _followingUids.contains(uid);

  Future<void> follow(String targetUid) async {
    await _service.followUser(targetUid);
  }

  Future<void> unfollow(String targetUid) async {
    await _service.unfollowUser(targetUid);
  }

  Future<List<UserModel>> search(String query) {
    return _service.searchUsers(query);
  }

  void invalidate(String uid) {
    _cache.remove(uid);
  }
}
