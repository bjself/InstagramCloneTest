import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/post_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/posts_provider.dart';
import '../../widgets/user_avatar.dart';

/// Reusable card shown in the feed and on post detail pages.
class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postsProvider = context.read<PostsProvider>();
    final currentUser = authProvider.currentUser;
    final user = post.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: GestureDetector(
            onTap: () => context.go('/main/profile/${user?.uid ?? ''}'),
            child: UserAvatar(image: user?.image ?? 'default', size: 36),
          ),
          title: GestureDetector(
            onTap: () => context.go('/main/profile/${user?.uid ?? ''}'),
            child: Text(
              user?.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                await context
                    .read<PostsProvider>()
                    // ignore: use_build_context_synchronously
                    .reload(currentUser!.uid);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'profile', child: Text('View Profile')),
              if (post.creatorUid == currentUser?.uid)
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
        // ── Image ──
        AspectRatio(
          aspectRatio: 1,
          child: CachedNetworkImage(
            imageUrl: post.type == 0
                ? (post.downloadURLStill ?? post.downloadURL)
                : post.downloadURL,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.grey[200]),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 60),
          ),
        ),
        // ── Actions ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  post.currentUserLike ? Icons.favorite : Icons.favorite_border,
                  color: post.currentUserLike ? Colors.red : Colors.black,
                ),
                onPressed: () async {
                  if (currentUser == null) return;
                  await postsProvider.toggleLike(post, currentUser.uid);
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => context.go(
                    '/main/comment/${post.creatorUid}/${post.id}'),
              ),
            ],
          ),
        ),
        // ── Likes count ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${post.likesCount} likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // ── Caption ──
        if (post.caption.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
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
        // ── Comments link ──
        GestureDetector(
          onTap: () =>
              context.go('/main/comment/${post.creatorUid}/${post.id}'),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              'View all ${post.commentsCount} comments',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        // ── Timestamp ──
        if (post.creation != null)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              timeago.format(post.creation!.toDate()),
              style:
                  const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
