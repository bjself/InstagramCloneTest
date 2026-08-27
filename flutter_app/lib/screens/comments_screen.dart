import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment_model.dart';
import '../providers/auth_provider.dart' as ap;
import '../services/firestore_service.dart';
import '../widgets/comment_item.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final FirestoreService _service = FirestoreService();
  final _commentController = TextEditingController();
  bool _submitting = false;

  late String _postOwnerUid;
  late String _postId;
  late String _currentUserName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;
    _postOwnerUid = args['postOwnerUid'] as String;
    _postId = args['postId'] as String;
    _currentUserName = args['currentUserName'] as String? ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    await _service.addComment(
      postOwnerUid: _postOwnerUid,
      postId: _postId,
      comment: text,
      name: _currentUserName,
    );
    if (mounted) {
      _commentController.clear();
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: _service.commentsStream(_postOwnerUid, _postId),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final comments = snap.data!;
                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'No comments yet. Be the first!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) =>
                      CommentItem(comment: comments[index]),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: _submit,
                        child: const Text(
                          'Post',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
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
