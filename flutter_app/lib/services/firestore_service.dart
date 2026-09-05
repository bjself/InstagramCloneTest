import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_model.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

export '../models/chat_model.dart';
export '../models/comment_model.dart';
export '../models/post_model.dart';
export '../models/user_model.dart';

/// Central service that talks to Firestore and Storage.
/// Mirrors the data operations from the React Native redux actions.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  // ─── USER ──────────────────────────────────────────────────────────────────

  Stream<UserModel> userStream() => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((s) => UserModel.fromDoc(s));

  Future<UserModel?> fetchUser(String userId) async {
    final s = await _db.collection('users').doc(userId).get();
    if (!s.exists) return null;
    return UserModel.fromDoc(s);
  }

  Future<void> updateUser(Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).update(data);

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final snap = await _db
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: '${query}z')
        .limit(10)
        .get();
    return snap.docs.map((d) => UserModel.fromDoc(d)).toList();
  }

  // ─── FOLLOWING ─────────────────────────────────────────────────────────────

  Stream<List<String>> followingStream() => _db
      .collection('following')
      .doc(uid)
      .collection('userFollowing')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toList());

  Future<void> follow(String targetUid) => _db
      .collection('following')
      .doc(uid)
      .collection('userFollowing')
      .doc(targetUid)
      .set({});

  Future<void> unfollow(String targetUid) => _db
      .collection('following')
      .doc(uid)
      .collection('userFollowing')
      .doc(targetUid)
      .delete();

  // ─── POSTS ─────────────────────────────────────────────────────────────────

  Future<List<PostModel>> fetchUserPosts(String userId) async {
    final snap = await _db
        .collection('posts')
        .doc(userId)
        .collection('userPosts')
        .orderBy('creation', descending: true)
        .get();
    return snap.docs.map((d) => PostModel.fromDoc(d, userId)).toList();
  }

  /// Loads the feed: posts from every followed user, sorted newest-first.
  Future<List<PostModel>> fetchFeed(List<String> followingIds) async {
    if (followingIds.isEmpty) return [];

    final futures = followingIds.map((fid) => fetchUserPosts(fid));
    final results = await Future.wait(futures);
    final posts = results.expand((list) => list).toList()
      ..sort((a, b) => b.creation.compareTo(a.creation));
    return posts;
  }

  Future<void> deletePost(String postId) => _db
      .collection('posts')
      .doc(uid)
      .collection('userPosts')
      .doc(postId)
      .delete();

  Future<void> addPost({
    required String downloadURL,
    String? downloadURLStill,
    required String caption,
    required int type, // 0=video 1=image
  }) async {
    final data = <String, dynamic>{
      'downloadURL': downloadURL,
      'caption': caption,
      'likesCount': 0,
      'commentsCount': 0,
      'type': type,
      'creation': FieldValue.serverTimestamp(),
    };
    if (downloadURLStill != null) data['downloadURLStill'] = downloadURLStill;
    await _db
        .collection('posts')
        .doc(uid)
        .collection('userPosts')
        .add(data);
  }

  // ─── LIKES ─────────────────────────────────────────────────────────────────

  Stream<bool> likeStream(String postCreatorUid, String postId) => _db
      .collection('posts')
      .doc(postCreatorUid)
      .collection('userPosts')
      .doc(postId)
      .collection('likes')
      .doc(uid)
      .snapshots()
      .map((s) => s.exists);

  Future<void> likePost(String postCreatorUid, String postId) => _db
      .collection('posts')
      .doc(postCreatorUid)
      .collection('userPosts')
      .doc(postId)
      .collection('likes')
      .doc(uid)
      .set({});

  Future<void> unlikePost(String postCreatorUid, String postId) => _db
      .collection('posts')
      .doc(postCreatorUid)
      .collection('userPosts')
      .doc(postId)
      .collection('likes')
      .doc(uid)
      .delete();

  // ─── COMMENTS ──────────────────────────────────────────────────────────────

  Future<List<CommentModel>> fetchComments(
          String postCreatorUid, String postId) async =>
      (await _db
              .collection('posts')
              .doc(postCreatorUid)
              .collection('userPosts')
              .doc(postId)
              .collection('comments')
              .orderBy('creation', descending: true)
              .get())
          .docs
          .map((d) => CommentModel.fromDoc(d))
          .toList();

  Future<void> addComment({
    required String postCreatorUid,
    required String postId,
    required String text,
  }) =>
      _db
          .collection('posts')
          .doc(postCreatorUid)
          .collection('userPosts')
          .doc(postId)
          .collection('comments')
          .add({
        'creator': uid,
        'text': text,
        'creation': FieldValue.serverTimestamp(),
      });

  // ─── CHATS ─────────────────────────────────────────────────────────────────

  Stream<List<ChatModel>> chatsStream() => _db
      .collection('chats')
      .where('users', arrayContains: uid)
      .orderBy('lastMessageTimestamp', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ChatModel.fromDoc(d)).toList());

  Stream<List<MessageModel>> messagesStream(String chatId) => _db
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('creation', descending: false)
      .snapshots()
      .map((s) => s.docs.map((d) => MessageModel.fromDoc(d)).toList());

  Future<ChatModel?> findOrCreateChat(String otherUid) async {
    // Try to find existing chat.
    final snap = await _db
        .collection('chats')
        .where('users', arrayContains: uid)
        .get();
    for (final doc in snap.docs) {
      final users = List<String>.from(doc['users']);
      if (users.contains(otherUid)) return ChatModel.fromDoc(doc);
    }
    // Create a new one.
    final ref = await _db.collection('chats').add({
      'users': [uid, otherUid],
      'lastMessage': 'Send the first message',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      uid: true,
      otherUid: true,
    });
    final newSnap = await ref.get();
    return ChatModel.fromDoc(newSnap);
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required List<String> chatUsers,
  }) async {
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'creator': uid,
      'text': text,
      'creation': FieldValue.serverTimestamp(),
    });
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      chatUsers[0]: false,
      chatUsers[1]: false,
    });
  }

  Future<void> markChatRead(String chatId) =>
      _db.collection('chats').doc(chatId).update({uid: true});

  // ─── STORAGE ───────────────────────────────────────────────────────────────

  Future<String> uploadFile(File file, String storagePath) async {
    final ref = _storage.ref().child(storagePath);
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  Future<String> uploadProfileImage(File file) =>
      uploadFile(file, 'profile/$uid');
}
