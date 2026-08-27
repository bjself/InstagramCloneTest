import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ─── Users ────────────────────────────────────────────────────────────────

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromDoc(doc);
    });
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final snap = await _db
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();
    return snap.docs.map(UserModel.fromDoc).toList();
  }

  // ─── Posts ────────────────────────────────────────────────────────────────

  Future<List<PostModel>> getUserPosts(String uid) async {
    final snap = await _db
        .collection('posts')
        .doc(uid)
        .collection('userPosts')
        .orderBy('creation', descending: true)
        .get();
    return snap.docs.map(PostModel.fromDoc).toList();
  }

  /// Fetches the feed posts for the current user from /feed/{uid}
  Stream<List<PostModel>> feedStream() {
    return _db
        .collection('feed')
        .doc(_uid)
        .collection('userFeed')
        .orderBy('creation', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) => snap.docs.map(PostModel.fromDoc).toList());
  }

  // ─── Likes ────────────────────────────────────────────────────────────────

  Future<void> likePost(String postOwnerUid, String postId) {
    return _db
        .collection('posts')
        .doc(postOwnerUid)
        .collection('userPosts')
        .doc(postId)
        .collection('likes')
        .doc(_uid)
        .set({});
  }

  Future<void> unlikePost(String postOwnerUid, String postId) {
    return _db
        .collection('posts')
        .doc(postOwnerUid)
        .collection('userPosts')
        .doc(postId)
        .collection('likes')
        .doc(_uid)
        .delete();
  }

  Stream<bool> likedByMe(String postOwnerUid, String postId) {
    return _db
        .collection('posts')
        .doc(postOwnerUid)
        .collection('userPosts')
        .doc(postId)
        .collection('likes')
        .doc(_uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ─── Comments ─────────────────────────────────────────────────────────────

  Stream<List<CommentModel>> commentsStream(
      String postOwnerUid, String postId) {
    return _db
        .collection('posts')
        .doc(postOwnerUid)
        .collection('userPosts')
        .doc(postId)
        .collection('comments')
        .orderBy('creation', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(CommentModel.fromDoc).toList());
  }

  Future<void> addComment({
    required String postOwnerUid,
    required String postId,
    required String comment,
    required String name,
  }) {
    return _db
        .collection('posts')
        .doc(postOwnerUid)
        .collection('userPosts')
        .doc(postId)
        .collection('comments')
        .add({
      'creator': _uid,
      'name': name,
      'comment': comment,
      'creation': FieldValue.serverTimestamp(),
    });
  }

  // ─── Following ────────────────────────────────────────────────────────────

  Future<void> followUser(String targetUid) {
    return _db
        .collection('following')
        .doc(_uid)
        .collection('userFollowing')
        .doc(targetUid)
        .set({});
  }

  Future<void> unfollowUser(String targetUid) {
    return _db
        .collection('following')
        .doc(_uid)
        .collection('userFollowing')
        .doc(targetUid)
        .delete();
  }

  Stream<List<String>> followingUids() {
    return _db
        .collection('following')
        .doc(_uid)
        .collection('userFollowing')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  Future<bool> isFollowing(String targetUid) async {
    final doc = await _db
        .collection('following')
        .doc(_uid)
        .collection('userFollowing')
        .doc(targetUid)
        .get();
    return doc.exists;
  }
}
