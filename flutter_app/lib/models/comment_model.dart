import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors `posts/.../comments/{commentId}`.
class CommentModel {
  final String id;
  final String creator;
  final String text;
  final Timestamp? creation;

  const CommentModel({
    required this.id,
    required this.creator,
    required this.text,
    this.creation,
  });

  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      creator: d['creator'] ?? '',
      text: d['text'] ?? '',
      creation: d['creation'],
    );
  }
}
