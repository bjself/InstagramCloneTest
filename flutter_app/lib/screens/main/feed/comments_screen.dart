import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/comment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';

/// Shows all comments on a post, with an input bar to add a new one.
/// Mirrors React Native Comment.js.
class CommentsScreen extends StatefulWidget {
  final String creatorUid;
  final String postId;

  const CommentsScreen({
    super.key,
    required this.creatorUid,
    required this.postId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _inputCtrl = TextEditingController();
  List<CommentModel> _comments = [];
  final Map<String, UserModel> _users = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fs = context.read<FirestoreService>();
    final comments =
        await fs.fetchComments(widget.creatorUid, widget.postId);
    // Pre-fetch user for each unique creator.
    for (final c in comments) {
      if (!_users.containsKey(c.creator)) {
        final u = await fs.fetchUser(c.creator);
        if (u != null) _users[c.creator] = u;
      }
    }
    if (mounted) setState(() {
      _comments = comments;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    final fs = context.read<FirestoreService>();
    await fs.addComment(
      postCreatorUid: widget.creatorUid,
      postId: widget.postId,
      text: text,
    );
    await _load();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

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
                    ? const Center(child: Text('No comments yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _comments.length,
                        itemBuilder: (_, i) {
                          final c = _comments[i];
                          final user = _users[c.creator];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _avatar(user?.image),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: '${user?.name ?? ''} ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(text: c.text),
                                          ],
                                        ),
                                      ),
                                      if (c.creation != null)
                                        Text(
                                          timeago
                                              .format(c.creation!.toDate()),
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          // Input bar
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              top: 8,
            ),
            child: Row(
              children: [
                _avatar(null),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment…',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                TextButton(
                  onPressed: _send,
                  child: const Text('Post',
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

  Widget _avatar(String? image) {
    if (image == null || image == 'default') {
      return const CircleAvatar(radius: 18, child: Icon(Icons.person));
    }
    return CircleAvatar(
      radius: 18,
      backgroundImage: CachedNetworkImageProvider(image),
    );
  }
}
