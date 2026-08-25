import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the `chats` collection document.
class ChatModel {
  final String id;
  final List<String> users;
  final String lastMessage;
  final Timestamp? lastMessageTimestamp;

  const ChatModel({
    required this.id,
    required this.users,
    required this.lastMessage,
    this.lastMessageTimestamp,
  });

  factory ChatModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      users: List<String>.from(d['users'] ?? []),
      lastMessage: d['lastMessage'] ?? '',
      lastMessageTimestamp: d['lastMessageTimestamp'],
    );
  }
}

/// Mirrors `chats/{chatId}/messages/{msgId}`.
class MessageModel {
  final String id;
  final String creator;
  final String text;
  final Timestamp? creation;

  const MessageModel({
    required this.id,
    required this.creator,
    required this.text,
    this.creation,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      creator: d['creator'] ?? '',
      text: d['text'] ?? '',
      creation: d['creation'],
    );
  }
}

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
