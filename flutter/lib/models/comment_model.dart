import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

/// Mirrors the Firestore `posts/{uid}/userPosts/{postId}/comments/{commentId}`.
class CommentModel {
  final String id;
  final String creator; // uid
  final String text;
  final Timestamp? creation;
  // Enriched client-side
  UserModel? user;

  CommentModel({
    required this.id,
    required this.creator,
    required this.text,
    this.creation,
    this.user,
  });

  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      creator: data['creator'] as String? ?? '',
      text: data['text'] as String? ?? '',
      creation: data['creation'] as Timestamp?,
    );
  }
}
