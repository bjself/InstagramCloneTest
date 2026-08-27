import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart' as ap;
import '../services/firestore_service.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final UserModel postUser;
  final VoidCallback onTap;

  const PostCard({
    Key? key,
    required this.post,
    required this.postUser,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(post: post, postUser: postUser),
          _PostImage(post: post, onTap: onTap),
          _Actions(post: post, postUser: postUser),
          _Caption(post: post, postUser: postUser, onTap: onTap),
          _Timestamp(post: post),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Header row ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final PostModel post;
  final UserModel postUser;

  const _Header({required this.post, required this.postUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/profile',
              arguments: postUser.uid,
            ),
            child: _Avatar(imageUrl: postUser.image),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/profile',
              arguments: postUser.uid,
            ),
            child: Text(
              postUser.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Post image ────────────────────────────────────────────────────────────────

class _PostImage extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const _PostImage({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        post.type == 0 ? post.downloadURLStill : post.downloadURL;
    return GestureDetector(
      onDoubleTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image, size: 48)),
        ),
      ),
    );
  }
}

// ── Action row (like, comment) ────────────────────────────────────────────────

class _Actions extends StatelessWidget {
  final PostModel post;
  final UserModel postUser;

  const _Actions({required this.post, required this.postUser});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final authProvider =
        Provider.of<ap.AuthProvider>(context, listen: false);
    final me = authProvider.currentUser;

    return StreamBuilder<bool>(
      stream: firestoreService.likedByMe(postUser.uid, post.id),
      builder: (context, snap) {
        final liked = snap.data ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.black,
                ),
                onPressed: () async {
                  if (liked) {
                    await firestoreService.unlikePost(postUser.uid, post.id);
                  } else {
                    await firestoreService.likePost(postUser.uid, post.id);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/comments',
                  arguments: {
                    'postOwnerUid': postUser.uid,
                    'postId': post.id,
                    'currentUserName': me?.name ?? '',
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Caption ────────────────────────────────────────────────────────────────────

class _Caption extends StatelessWidget {
  final PostModel post;
  final UserModel postUser;
  final VoidCallback onTap;

  const _Caption(
      {required this.post, required this.postUser, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${post.likesCount} likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          if (post.caption.isNotEmpty)
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '${postUser.name} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'View all ${post.commentsCount} comments',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timestamp ─────────────────────────────────────────────────────────────────

class _Timestamp extends StatelessWidget {
  final PostModel post;

  const _Timestamp({required this.post});

  @override
  Widget build(BuildContext context) {
    final date = post.creation.toDate();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        timeago.format(date),
        style: const TextStyle(color: Colors.grey, fontSize: 11),
      ),
    );
  }
}

// ── Avatar helper ─────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const _Avatar({required this.imageUrl, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == 'default') {
      return CircleAvatar(
        radius: radius,
        child: const Icon(Icons.person),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: CachedNetworkImageProvider(imageUrl),
    );
  }
}
