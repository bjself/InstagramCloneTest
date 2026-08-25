import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

/// Mirrors the Firestore `posts/{uid}/userPosts/{postId}` document structure.
///
/// type == 0  →  video
/// type == 1  →  image
class PostModel {
  final String id;
  final String creatorUid;
  final String downloadURL;
  final String? downloadURLStill; // thumbnail for video posts
  final String caption;
  final int likesCount;
  final int commentsCount;
  final int type; // 0 = video, 1 = image
  final Timestamp creation;
  UserModel? user; // populated after join

  PostModel({
    required this.id,
    required this.creatorUid,
    required this.downloadURL,
    this.downloadURLStill,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.type,
    required this.creation,
    this.user,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc, String creatorUid) {
    final d = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      creatorUid: creatorUid,
      downloadURL: d['downloadURL'] ?? '',
      downloadURLStill: d['downloadURLStill'],
      caption: d['caption'] ?? '',
      likesCount: (d['likesCount'] ?? 0) as int,
      commentsCount: (d['commentsCount'] ?? 0) as int,
      type: (d['type'] ?? 1) as int,
      creation: d['creation'] ?? Timestamp.now(),
    );
  }
}
