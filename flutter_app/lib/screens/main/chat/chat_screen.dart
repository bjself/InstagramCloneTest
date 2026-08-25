import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';

/// One-on-one conversation screen.
/// Mirrors React Native Chat.js.
class ChatScreen extends StatefulWidget {
  final String otherUid;

  const ChatScreen({super.key, required this.otherUid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  UserModel? _otherUser;
  ChatModel? _chat;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final fs = context.read<FirestoreService>();
    _otherUser = await fs.fetchUser(widget.otherUid);
    _chat = await fs.findOrCreateChat(widget.otherUid);
    if (_chat != null) await fs.markChatRead(_chat!.id);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _chat == null) return;
    _inputCtrl.clear();
    await context.read<FirestoreService>().sendMessage(
          chatId: _chat!.id,
          text: text,
          chatUsers: _chat!.users,
        );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final fs = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: _otherUser == null
            ? const Text('Chat')
            : Row(
                children: [
                  _otherUser!.image == 'default'
                      ? const CircleAvatar(
                          radius: 16, child: Icon(Icons.person))
                      : CircleAvatar(
                          radius: 16,
                          backgroundImage: CachedNetworkImageProvider(
                              _otherUser!.image),
                        ),
                  const SizedBox(width: 10),
                  Text(_otherUser!.name),
                ],
              ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _chat == null
                      ? const Center(child: Text('Starting chat…'))
                      : StreamBuilder<List<MessageModel>>(
                          stream: fs.messagesStream(_chat!.id),
                          builder: (ctx, snap) {
                            final msgs = snap.data ?? [];
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _scrollToBottom());
                            return ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.all(12),
                              itemCount: msgs.length,
                              itemBuilder: (_, i) {
                                final m = msgs[i];
                                final isMe = m.creator == myUid;
                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? const Color(0xFF405DE6)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.text,
                                          style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                        if (m.creation != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            timeago.format(
                                                m.creation!.toDate()),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isMe
                                                  ? Colors.white70
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                // Input bar
                const Divider(height: 1),
                Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    top: 8,
                  ),
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
                        onPressed: _send,
                        child: const Text('Send',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF405DE6))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
