import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/chat_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chats_provider.dart';
import '../../widgets/user_avatar.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatsProvider = context.watch<ChatsProvider>();
    final currentUid =
        context.watch<AuthProvider>().currentUser?.uid ?? '';
    final chats = chatsProvider.chats;

    if (chats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('No chats yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _buildChatTile(context, chats[i], currentUid),
    );
  }

  Widget _buildChatTile(
      BuildContext context, ChatModel chat, String currentUid) {
    final other = chat.otherUser;
    return ListTile(
      leading: UserAvatar(image: other?.image ?? 'default', size: 48),
      title: Text(other?.name ?? '…',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: chat.lastMessageTimestamp != null
          ? Text(
              timeago.format(chat.lastMessageTimestamp!.toDate()),
              style:
                  const TextStyle(color: Colors.grey, fontSize: 11),
            )
          : null,
      onTap: () => context.go(
        '/main/chat/${chat.id}?otherUid=${other?.uid ?? ''}',
      ),
    );
  }
}
