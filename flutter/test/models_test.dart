import 'package:flutter_test/flutter_test.dart';

// ── Unit tests for models ──────────────────────────────────────────────────
//
// These tests verify that the Dart data models parse Firestore documents
// correctly, matching the schema used by the React Native app.
// They run without Firebase or a device.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:instagram_clone_flutter/models/user_model.dart';
import 'package:instagram_clone_flutter/models/post_model.dart';
import 'package:instagram_clone_flutter/models/comment_model.dart';
import 'package:instagram_clone_flutter/models/chat_model.dart';

void main() {
  group('UserModel', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('parses a full user document correctly', () async {
      await fakeFirestore.collection('users').doc('uid1').set({
        'email': 'alice@example.com',
        'username': 'alice',
        'name': 'Alice Smith',
        'image': 'https://example.com/alice.jpg',
        'description': 'Hello!',
        'followersCount': 42,
        'followingCount': 7,
        'notificationToken': 'token123',
        'banned': false,
      });

      final snap =
          await fakeFirestore.collection('users').doc('uid1').get();
      final user = UserModel.fromDoc(snap);

      expect(user.uid, 'uid1');
      expect(user.email, 'alice@example.com');
      expect(user.username, 'alice');
      expect(user.name, 'Alice Smith');
      expect(user.image, 'https://example.com/alice.jpg');
      expect(user.description, 'Hello!');
      expect(user.followersCount, 42);
      expect(user.followingCount, 7);
      expect(user.notificationToken, 'token123');
      expect(user.banned, false);
    });

    test('uses default values for missing optional fields', () async {
      await fakeFirestore.collection('users').doc('uid2').set({
        'email': 'bob@example.com',
        'username': 'bob',
        'name': 'Bob',
        'image': 'default',
      });
      final snap =
          await fakeFirestore.collection('users').doc('uid2').get();
      final user = UserModel.fromDoc(snap);

      expect(user.followersCount, 0);
      expect(user.followingCount, 0);
      expect(user.description, isNull);
      expect(user.banned, false);
    });

    test('copyWith returns updated model without mutating original', () async {
      await fakeFirestore.collection('users').doc('uid3').set({
        'email': 'carol@example.com',
        'username': 'carol',
        'name': 'Carol',
        'image': 'default',
        'followersCount': 10,
        'followingCount': 5,
      });
      final snap =
          await fakeFirestore.collection('users').doc('uid3').get();
      final original = UserModel.fromDoc(snap);
      final updated = original.copyWith(name: 'Carol Updated', followersCount: 11);

      expect(updated.name, 'Carol Updated');
      expect(updated.followersCount, 11);
      expect(original.name, 'Carol'); // unchanged
      expect(original.followersCount, 10); // unchanged
    });
  });

  group('PostModel', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('parses an image post document', () async {
      await fakeFirestore
          .collection('posts')
          .doc('uid1')
          .collection('userPosts')
          .doc('post1')
          .set({
        'downloadURL': 'https://example.com/post.jpg',
        'caption': 'Nice photo!',
        'likesCount': 5,
        'commentsCount': 2,
        'type': 1,
        'creator': 'uid1',
        'creation': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      final snap = await fakeFirestore
          .collection('posts')
          .doc('uid1')
          .collection('userPosts')
          .doc('post1')
          .get();
      final post = PostModel.fromDoc(snap, 'uid1');

      expect(post.id, 'post1');
      expect(post.creatorUid, 'uid1');
      expect(post.downloadURL, 'https://example.com/post.jpg');
      expect(post.caption, 'Nice photo!');
      expect(post.likesCount, 5);
      expect(post.commentsCount, 2);
      expect(post.type, 1);
    });

    test('parses a video post with thumbnail', () async {
      await fakeFirestore
          .collection('posts')
          .doc('uid1')
          .collection('userPosts')
          .doc('post2')
          .set({
        'downloadURL': 'https://example.com/video.mp4',
        'downloadURLStill': 'https://example.com/thumb.jpg',
        'caption': '',
        'likesCount': 0,
        'commentsCount': 0,
        'type': 0,
        'creator': 'uid1',
      });

      final snap = await fakeFirestore
          .collection('posts')
          .doc('uid1')
          .collection('userPosts')
          .doc('post2')
          .get();
      final post = PostModel.fromDoc(snap, 'uid1');

      expect(post.type, 0);
      expect(post.downloadURLStill, 'https://example.com/thumb.jpg');
    });

    test('copyWith does not mutate original', () async {
      await fakeFirestore
          .collection('posts')
          .doc('uid1')
          .collection('userPosts')
          .doc('post3')
          .set({
        'downloadURL': 'https://example.com/p.jpg',
        'caption': 'x',
        'likesCount': 3,
        'commentsCount': 1,
        'type': 1,
        'creator': 'uid1',
      });
      final snap = await fakeFirestore
          .collection('posts')
          .doc('uid1')
          .collection('userPosts')
          .doc('post3')
          .get();
      final original = PostModel.fromDoc(snap, 'uid1');
      final updated = original.copyWith(currentUserLike: true, likesCount: 4);

      expect(updated.currentUserLike, true);
      expect(updated.likesCount, 4);
      expect(original.currentUserLike, false);
      expect(original.likesCount, 3);
    });
  });

  group('CommentModel', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('parses a comment document', () async {
      await fakeFirestore
          .collection('posts')
          .doc('uid1')
          .collection('userPosts')
          .doc('post1')
          .collection('comments')
          .doc('comment1')
          .set({
        'creator': 'uid2',
        'text': 'Great post!',
        'creation': Timestamp.fromDate(DateTime(2024, 2, 1)),
      });

      final snap = await fakeFirestore
          .collection('posts')
          .doc('uid1')
          .collection('userPosts')
          .doc('post1')
          .collection('comments')
          .doc('comment1')
          .get();
      final comment = CommentModel.fromDoc(snap);

      expect(comment.id, 'comment1');
      expect(comment.creator, 'uid2');
      expect(comment.text, 'Great post!');
      expect(comment.creation, isNotNull);
    });
  });

  group('ChatModel', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('parses a chat document', () async {
      await fakeFirestore.collection('chats').doc('chat1').set({
        'users': ['uid1', 'uid2'],
        'lastMessage': 'Hey!',
        'lastMessageTimestamp':
            Timestamp.fromDate(DateTime(2024, 3, 1)),
      });

      final snap =
          await fakeFirestore.collection('chats').doc('chat1').get();
      final chat = ChatModel.fromDoc(snap);

      expect(chat.id, 'chat1');
      expect(chat.users, containsAll(['uid1', 'uid2']));
      expect(chat.lastMessage, 'Hey!');
      expect(chat.lastMessageTimestamp, isNotNull);
    });
  });
}
