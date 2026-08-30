import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_model.dart';
import 'user_model.dart';

/// Mirrors the Firestore `chats/{chatId}` document.
class ChatModel {
  final String id;
  final List<String> users;
  final String lastMessage;
  final Timestamp? lastMessageTimestamp;
  // Enriched client-side
  UserModel? otherUser;

  ChatModel({
    required this.id,
    required this.users,
    required this.lastMessage,
    this.lastMessageTimestamp,
    this.otherUser,
  });

  factory ChatModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawUsers = data['users'];
    final List<String> userList = rawUsers is List
        ? rawUsers.map((e) => e.toString()).toList()
        : [];
    return ChatModel(
      id: doc.id,
      users: userList,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] as Timestamp?,
    );
  }

  bool isRead(String currentUid) {
    // Firestore stores `{uid}: true` when message is read by that user
    return true; // handled separately in listeners
  }
}

/// Mirrors `chats/{chatId}/messages/{messageId}`.
class MessageModel {
  final String id;
  final String creator;
  final String text;
  final Timestamp? creation;
  final PostModel? post;

  const MessageModel({
    required this.id,
    required this.creator,
    required this.text,
    this.creation,
    this.post,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      creator: data['creator'] as String? ?? '',
      text: data['text'] as String? ?? '',
      creation: data['creation'] as Timestamp?,
    );
  }
}
