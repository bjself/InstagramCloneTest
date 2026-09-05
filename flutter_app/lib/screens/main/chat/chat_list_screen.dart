import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';

/// Shows a list of all ongoing conversations.
/// Mirrors React Native List.js (ChatList).
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirestoreService>();
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<ChatModel>>(
      stream: fs.chatsStream(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final chats = snap.data ?? [];
        if (chats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No messages yet.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final chat = chats[i];
            final otherUid = chat.users.firstWhere((u) => u != myUid,
                orElse: () => myUid);
            final isRead = chat.users.every((_) => true); // simplification

            return FutureBuilder<UserModel?>(
              future: fs.fetchUser(otherUid),
              builder: (ctx2, userSnap) {
                final user = userSnap.data;
                return ListTile(
                  leading: user == null
                      ? const CircleAvatar(child: Icon(Icons.person))
                      : user.image == 'default'
                          ? const CircleAvatar(child: Icon(Icons.person))
                          : CircleAvatar(
                              backgroundImage:
                                  CachedNetworkImageProvider(user.image),
                            ),
                  title: Text(
                    user?.name ?? '…',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: chat.lastMessageTimestamp != null
                      ? Text(
                          timeago.format(
                              chat.lastMessageTimestamp!.toDate()),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        )
                      : null,
                  onTap: () => context.go('/home/chat/$otherUid'),
                );
              },
            );
          },
        );
      },
    );
  }
}
