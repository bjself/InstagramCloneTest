import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

/// Mirrors the Firestore `posts/{uid}/userPosts/{postId}` document.
/// type: 0 = video, 1 = image  (matches React Native app convention)
class PostModel {
  final String id;
  final String creatorUid; // the owner's uid (path segment)
  final String downloadURL;
  final String? downloadURLStill; // video thumbnail
  final String caption;
  final int likesCount;
  final int commentsCount;
  final int type; // 0 = video, 1 = image
  final Timestamp? creation;
  // Enriched client-side (not in Firestore doc itself)
  UserModel? user;
  bool currentUserLike;

  PostModel({
    required this.id,
    required this.creatorUid,
    required this.downloadURL,
    this.downloadURLStill,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.type,
    this.creation,
    this.user,
    this.currentUserLike = false,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc, String ownerUid) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      creatorUid: ownerUid,
      downloadURL: data['downloadURL'] as String? ?? '',
      downloadURLStill: data['downloadURLStill'] as String?,
      caption: data['caption'] as String? ?? '',
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (data['commentsCount'] as num?)?.toInt() ?? 0,
      type: (data['type'] as num?)?.toInt() ?? 1,
      creation: data['creation'] as Timestamp?,
    );
  }

  PostModel copyWith({
    int? likesCount,
    int? commentsCount,
    bool? currentUserLike,
    UserModel? user,
  }) =>
      PostModel(
        id: id,
        creatorUid: creatorUid,
        downloadURL: downloadURL,
        downloadURLStill: downloadURLStill,
        caption: caption,
        likesCount: likesCount ?? this.likesCount,
        commentsCount: commentsCount ?? this.commentsCount,
        type: type,
        creation: creation,
        user: user ?? this.user,
        currentUserLike: currentUserLike ?? this.currentUserLike,
      );
}
