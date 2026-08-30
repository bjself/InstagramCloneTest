import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../widgets/user_avatar.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  UserModel? _otherUser;
  ChatModel? _chat;
  List<MessageModel> _messages = [];
  bool _sending = false;
  List<String> _chatUsers = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = context.read<FirestoreService>();
    if (widget.otherUserId.isNotEmpty) {
      _otherUser = await db.fetchUser(widget.otherUserId);
    }

    // Subscribe to messages.
    db.messagesStream(widget.chatId).listen((msgs) {
      if (mounted) {
        setState(() => _messages = msgs);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    // Mark as read and load chat users.
    await db.markChatRead(widget.chatId);
    final chatSnap = await db
        .chatsStream()
        .first;
    final chat =
        chatSnap.where((c) => c.id == widget.chatId).firstOrNull;
    if (chat != null) {
      _chatUsers = chat.users;
      if (mounted) setState(() => _chat = chat);
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _chatUsers.isEmpty) return;
    setState(() => _sending = true);
    _inputCtrl.clear();
    final db = context.read<FirestoreService>();
    await db.sendMessage(widget.chatId, text, _chatUsers);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUid =
        context.watch<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(image: _otherUser?.image ?? 'default', size: 32),
            const SizedBox(width: 8),
            Text(_otherUser?.name ?? '…'),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: _messages.length,
              itemBuilder: (_, i) =>
                  _buildMessageBubble(_messages[i], currentUid),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Message…',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                TextButton(
                  onPressed: _sending ? null : _send,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, String currentUid) {
    final isMe = msg.creator == currentUid;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
