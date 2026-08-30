import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/post_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/posts_provider.dart';
import '../../../services/firestore_service.dart';
import '../../widgets/user_avatar.dart';

class PostScreen extends StatefulWidget {
  final String ownerUid;
  final String postId;

  const PostScreen({
    super.key,
    required this.ownerUid,
    required this.postId,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  PostModel? _post;
  bool _currentUserLike = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _subscribeLike();
  }

  Future<void> _loadPost() async {
    final db = context.read<FirestoreService>();
    final posts = await db.fetchUserPosts(widget.ownerUid);
    final post = posts.where((p) => p.id == widget.postId).firstOrNull;
    if (post != null) {
      final user = await db.fetchUser(widget.ownerUid);
      setState(() {
        _post = post.copyWith(user: user);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _subscribeLike() {
    final db = context.read<FirestoreService>();
    db.likeStream(widget.ownerUid, widget.postId).listen((liked) {
      if (mounted) setState(() => _currentUserLike = liked);
    });
  }

  Future<void> _toggleLike() async {
    final db = context.read<FirestoreService>();
    if (_currentUserLike) {
      await db.removeLike(widget.ownerUid, widget.postId);
    } else {
      await db.addLike(widget.ownerUid, widget.postId);
    }
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
              : _buildPost(),
    );
  }

  Widget _buildPost() {
    final post = _post!;
    final user = post.user;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () => context.go('/main/profile/${widget.ownerUid}'),
              child: UserAvatar(image: user?.image ?? 'default'),
            ),
            title: Text(user?.name ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: post.type == 0
                  ? (post.downloadURLStill ?? post.downloadURL)
                  : post.downloadURL,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _currentUserLike
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _currentUserLike ? Colors.red : Colors.black,
                  ),
                  onPressed: _toggleLike,
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => context.go(
                      '/main/comment/${widget.ownerUid}/${widget.postId}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${post.likesCount} likes',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (post.caption.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(post.caption),
            ),
          GestureDetector(
            onTap: () => context
                .go('/main/comment/${widget.ownerUid}/${widget.postId}'),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Text(
                'View all ${post.commentsCount} comments',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          if (post.creation != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                timeago.format(post.creation!.toDate()),
                style:
                    const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
