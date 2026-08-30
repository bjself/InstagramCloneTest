import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/comment_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../widgets/user_avatar.dart';

class CommentScreen extends StatefulWidget {
  final String ownerUid;
  final String postId;

  const CommentScreen({
    super.key,
    required this.ownerUid,
    required this.postId,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _inputCtrl = TextEditingController();
  List<CommentModel> _comments = [];
  final Map<String, UserModel> _usersCache = {};
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final db = context.read<FirestoreService>();
    final comments =
        await db.fetchComments(widget.ownerUid, widget.postId);
    // Enrich with user data.
    for (final c in comments) {
      if (!_usersCache.containsKey(c.creator)) {
        final user = await db.fetchUser(c.creator);
        if (user != null) _usersCache[c.creator] = user;
      }
      c.user = _usersCache[c.creator];
    }
    if (mounted) setState(() {
      _comments = comments;
      _loading = false;
    });
  }

  Future<void> _sendComment() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    _inputCtrl.clear();
    final db = context.read<FirestoreService>();
    await db.addComment(widget.ownerUid, widget.postId, text);
    await _loadComments();
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(
                        child: Text('No comments yet.',
                            style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (_, i) => _buildCommentRow(_comments[i]),
                      ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                UserAvatar(
                    image: currentUser?.image ?? 'default', size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment…',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
                TextButton(
                  onPressed: _sending ? null : _sendComment,
                  child: const Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentRow(CommentModel comment) {
    final user = comment.user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(image: user?.image ?? 'default', size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${user?.name ?? 'Unknown'} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment.text),
                    ],
                  ),
                ),
                if (comment.creation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      timeago.format(comment.creation!.toDate()),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
