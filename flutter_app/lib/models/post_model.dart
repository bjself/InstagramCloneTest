import 'package:cloud_firestore/cloud_firestore.dart';

/// type == 0 → video post  |  type == 1 → image post
class PostModel {
  final String id;
  final String creator;   // uid of the post owner
  final String caption;
  final String downloadURL;
  final String downloadURLStill; // thumbnail for video posts
  final int type;          // 0 = video, 1 = image
  final int likesCount;
  final int commentsCount;
  final Timestamp creation;

  PostModel({
    required this.id,
    required this.creator,
    required this.caption,
    required this.downloadURL,
    this.downloadURLStill = '',
    this.type = 1,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.creation,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      creator: data['creator'] ?? '',
      caption: data['caption'] ?? '',
      downloadURL: data['downloadURL'] ?? '',
      downloadURLStill: data['downloadURLStill'] ?? '',
      type: data['type'] ?? 1,
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      creation: data['creation'] ?? Timestamp.now(),
    );
  }

  PostModel copyWith({int? likesCount, int? commentsCount}) {
    return PostModel(
      id: id,
      creator: creator,
      caption: caption,
      downloadURL: downloadURL,
      downloadURLStill: downloadURLStill,
      type: type,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      creation: creation,
    );
  }
}
