import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String creator;   // uid
  final String name;
  final String comment;
  final Timestamp creation;

  CommentModel({
    required this.id,
    required this.creator,
    required this.name,
    required this.comment,
    required this.creation,
  });

  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      creator: data['creator'] ?? '',
      name: data['name'] ?? '',
      comment: data['comment'] ?? '',
      creation: data['creation'] ?? Timestamp.now(),
    );
  }
}
