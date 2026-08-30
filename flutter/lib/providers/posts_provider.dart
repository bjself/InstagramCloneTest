import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';

/// Manages the feed (posts from followed users) and the current user's own posts.
class PostsProvider extends ChangeNotifier {
  final FirestoreService _db;

  List<PostModel> _feed = [];
  List<PostModel> _myPosts = [];
  List<String> _following = [];
  // Cache of loaded users by uid to avoid duplicate Firestore reads.
  final Map<String, UserModel> _usersCache = {};
  StreamSubscription<List<String>>? _followingSub;
  // Per-user post subscriptions.
  final Map<String, StreamSubscription<bool>> _likeSubs = {};

  PostsProvider(this._db);

  List<PostModel> get feed => List.unmodifiable(_feed);
  List<PostModel> get myPosts => List.unmodifiable(_myPosts);
  List<String> get following => List.unmodifiable(_following);

  /// Start listening for the current user's following list and load their posts.
  void init(String currentUid) {
    _followingSub?.cancel();
    _followingSub =
        _db.followingStream(currentUid).listen((followingIds) async {
      _following = followingIds;
      await _reloadFeed(currentUid);
      notifyListeners();
    });
  }

  /// Reload own posts (called after creating/deleting a post).
  Future<void> refreshMyPosts(String uid) async {
    _myPosts = await _db.fetchUserPosts(uid);
    notifyListeners();
  }

  Future<void> _reloadFeed(String currentUid) async {
    final List<PostModel> newFeed = [];
    for (final uid in _following) {
      final user = await _resolveUser(uid);
      final posts = await _db.fetchUserPosts(uid);
      for (final post in posts) {
        final enriched = post.copyWith(user: user);
        newFeed.add(enriched);
        _subscribeLike(currentUid, enriched);
      }
    }
    newFeed.sort((a, b) {
      final at = a.creation?.toDate();
      final bt = b.creation?.toDate();
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    _feed = newFeed;
  }

  void _subscribeLike(String currentUid, PostModel post) {
    final key = post.id;
    if (_likeSubs.containsKey(key)) return;
    final sub = _db
        .likeStream(post.creatorUid, post.id)
        .listen((liked) {
      _updateLike(post.id, liked);
    });
    _likeSubs[key] = sub;
  }

  void _updateLike(String postId, bool liked) {
    bool changed = false;
    _feed = _feed.map((p) {
      if (p.id == postId && p.currentUserLike != liked) {
        changed = true;
        return p.copyWith(currentUserLike: liked);
      }
      return p;
    }).toList();
    if (changed) notifyListeners();
  }

  Future<UserModel> _resolveUser(String uid) async {
    if (_usersCache.containsKey(uid)) return _usersCache[uid]!;
    final user = await _db.fetchUser(uid);
    final resolved = user ??
        UserModel(
          uid: uid,
          email: '',
          username: 'unknown',
          name: 'Unknown',
          image: 'default',
        );
    _usersCache[uid] = resolved;
    return resolved;
  }

  Future<void> toggleLike(PostModel post, String currentUid) async {
    if (post.currentUserLike) {
      await _db.removeLike(post.creatorUid, post.id);
    } else {
      await _db.addLike(post.creatorUid, post.id);
    }
    // Optimistic update while Firestore listener propagates.
    _updateLike(post.id, !post.currentUserLike);
  }

  Future<void> reload(String currentUid) async {
    for (final sub in _likeSubs.values) {
      await sub.cancel();
    }
    _likeSubs.clear();
    _usersCache.clear();
    _feed = [];
    await _reloadFeed(currentUid);
    await refreshMyPosts(currentUid);
    notifyListeners();
  }

  @override
  void dispose() {
    _followingSub?.cancel();
    for (final sub in _likeSubs.values) {
      sub.cancel();
    }
    super.dispose();
  }
}
