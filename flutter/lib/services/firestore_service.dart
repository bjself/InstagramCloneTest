import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/chat_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ──────────────────────────────── Users ────────────────────────────────

  Stream<UserModel> userStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .where((s) => s.exists)
      .map((s) => UserModel.fromDoc(s));

  Future<UserModel?> fetchUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return UserModel.fromDoc(snap);
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    await _db.collection('users').doc(_uid).update(data);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    // Matches React Native: where('username', '>=', username).limit(10)
    final snap = await _db
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .limit(10)
        .get();
    return snap.docs.map(UserModel.fromDoc).toList();
  }

  // ──────────────────────────────── Posts ────────────────────────────────

  Future<List<PostModel>> fetchUserPosts(String uid) async {
    final snap = await _db
        .collection('posts')
        .doc(uid)
        .collection('userPosts')
        .orderBy('creation', descending: true)
        .get();
    return snap.docs.map((d) => PostModel.fromDoc(d, uid)).toList();
  }

  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<PostModel> createPost({
    required String downloadURL,
    String? downloadURLStill,
    required String caption,
    required int type, // 0=video, 1=image
  }) async {
    final Map<String, dynamic> data = {
      'downloadURL': downloadURL,
      'caption': caption,
      'likesCount': 0,
      'commentsCount': 0,
      'type': type,
      'creation': FieldValue.serverTimestamp(),
      'creator': _uid,
    };
    if (downloadURLStill != null) data['downloadURLStill'] = downloadURLStill;

    final ref = await _db
        .collection('posts')
        .doc(_uid)
        .collection('userPosts')
        .add(data);
    final snap = await ref.get();
    return PostModel.fromDoc(snap, _uid);
  }

  Future<void> deletePost(String ownerUid, String postId) async {
    await _db
        .collection('posts')
        .doc(ownerUid)
        .collection('userPosts')
        .doc(postId)
        .delete();
  }

  // ──────────────────────────────── Likes ────────────────────────────────

  Stream<bool> likeStream(String ownerUid, String postId) => _db
      .collection('posts')
      .doc(ownerUid)
      .collection('userPosts')
      .doc(postId)
      .collection('likes')
      .doc(_uid)
      .snapshots()
      .map((s) => s.exists);

  Future<void> addLike(String ownerUid, String postId) async {
    await _db
        .collection('posts')
        .doc(ownerUid)
        .collection('userPosts')
        .doc(postId)
        .collection('likes')
        .doc(_uid)
        .set({});
  }

  Future<void> removeLike(String ownerUid, String postId) async {
    await _db
        .collection('posts')
        .doc(ownerUid)
        .collection('userPosts')
        .doc(postId)
        .collection('likes')
        .doc(_uid)
        .delete();
  }

  // ──────────────────────────────── Comments ────────────────────────────────

  Future<List<CommentModel>> fetchComments(
      String ownerUid, String postId) async {
    final snap = await _db
        .collection('posts')
        .doc(ownerUid)
        .collection('userPosts')
        .doc(postId)
        .collection('comments')
        .orderBy('creation', descending: true)
        .get();
    return snap.docs.map(CommentModel.fromDoc).toList();
  }

  Future<void> addComment(
      String ownerUid, String postId, String text) async {
    await _db
        .collection('posts')
        .doc(ownerUid)
        .collection('userPosts')
        .doc(postId)
        .collection('comments')
        .add({
      'creator': _uid,
      'text': text,
      'creation': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────────────────────── Following ────────────────────────────────

  Stream<List<String>> followingStream(String uid) => _db
      .collection('following')
      .doc(uid)
      .collection('userFollowing')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toList());

  Future<void> followUser(String targetUid) async {
    await _db
        .collection('following')
        .doc(_uid)
        .collection('userFollowing')
        .doc(targetUid)
        .set({});
  }

  Future<void> unfollowUser(String targetUid) async {
    await _db
        .collection('following')
        .doc(_uid)
        .collection('userFollowing')
        .doc(targetUid)
        .delete();
  }

  // ──────────────────────────────── Chats ────────────────────────────────

  Stream<List<ChatModel>> chatsStream() => _db
      .collection('chats')
      .where('users', arrayContains: _uid)
      .orderBy('lastMessageTimestamp', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ChatModel.fromDoc).toList());

  Stream<List<MessageModel>> messagesStream(String chatId) => _db
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('creation')
      .snapshots()
      .map((s) => s.docs.map(MessageModel.fromDoc).toList());

  Future<String> ensureChat(String otherUid) async {
    final snap = await _db
        .collection('chats')
        .where('users', arrayContains: _uid)
        .get();
    for (final doc in snap.docs) {
      final users = List<String>.from(doc['users'] as List);
      if (users.contains(otherUid)) return doc.id;
    }
    // Create new chat.
    final ref = await _db.collection('chats').add({
      'users': [_uid, otherUid],
      'lastMessage': 'Send the first message',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> sendMessage(
      String chatId, String text, List<String> chatUsers) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'creator': _uid,
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

  Future<void> markChatRead(String chatId) async {
    await _db.collection('chats').doc(chatId).update({_uid: true});
  }
}
