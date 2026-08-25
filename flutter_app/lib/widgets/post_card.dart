import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/post_model.dart';
import '../services/firestore_service.dart';

/// A single post card shown in the feed and on the post detail screen.
class PostCard extends StatelessWidget {
  final PostModel post;
  final bool showDeleteOption;

  const PostCard({
    super.key,
    required this.post,
    this.showDeleteOption = false,
  });

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirestoreService>();
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final user = post.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: GestureDetector(
            onTap: () => context.go('/home/profile/${post.creatorUid}'),
            child: _avatar(user?.image),
          ),
          title: GestureDetector(
            onTap: () => context.go('/home/profile/${post.creatorUid}'),
            child: Text(
              user?.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          trailing: post.creatorUid == myUid
              ? IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptions(context, fs),
                )
              : null,
        ),

        // ── Media ─────────────────────────────────────────────────────────
        GestureDetector(
          onDoubleTap: () => fs.likePost(post.creatorUid, post.id),
          child: AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: post.type == 0
                  ? (post.downloadURLStill ?? post.downloadURL)
                  : post.downloadURL,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
        ),

        // ── Action bar ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              StreamBuilder<bool>(
                stream: fs.likeStream(post.creatorUid, post.id),
                builder: (ctx, snap) {
                  final liked = snap.data ?? false;
                  return IconButton(
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? Colors.red : Colors.black,
                    ),
                    onPressed: () => liked
                        ? fs.unlikePost(post.creatorUid, post.id)
                        : fs.likePost(post.creatorUid, post.id),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => context
                    .go('/home/comments/${post.creatorUid}/${post.id}'),
              ),
            ],
          ),
        ),

        // ── Like count ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${post.likesCount} likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // ── Caption ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: '${user?.name ?? ''} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: post.caption),
              ],
            ),
          ),
        ),

        // ── Comments shortcut ─────────────────────────────────────────────
        if (post.commentsCount > 0)
          GestureDetector(
            onTap: () =>
                context.go('/home/comments/${post.creatorUid}/${post.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(
                'View all ${post.commentsCount} comments',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),

        // ── Timestamp ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            timeago.format(post.creation.toDate()),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _showOptions(BuildContext context, FirestoreService fs) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Delete post',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await fs.deletePost(post.id);
              },
            ),
            ListTile(
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String? image) {
    if (image == null || image == 'default') {
      return const CircleAvatar(child: Icon(Icons.person));
    }
    return CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(image),
    );
  }
}
