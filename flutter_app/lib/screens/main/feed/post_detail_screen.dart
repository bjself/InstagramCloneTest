import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/post_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/post_card.dart';

/// Full-screen view of a single post (used when navigating from a notification
/// or from a profile grid). Mirrors React Native Post.js.
class PostDetailScreen extends StatefulWidget {
  final String creatorUid;
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.creatorUid,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fs = context.read<FirestoreService>();
    final posts = await fs.fetchUserPosts(widget.creatorUid);
    final post = posts.firstWhere((p) => p.id == widget.postId,
        orElse: () => posts.first);
    post.user ??= await fs.fetchUser(widget.creatorUid);
    if (mounted) setState(() {
      _post = post;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? const Center(child: Text('Post not found'))
              : SingleChildScrollView(
                  child: PostCard(
                    post: _post!,
                    showDeleteOption: true,
                  ),
                ),
    );
  }
}
