import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/posts_provider.dart';
import 'post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postsProvider = context.watch<PostsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final feed = postsProvider.feed;

    if (feed.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Follow some users to see their posts here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final uid = authProvider.currentUser?.uid;
        if (uid != null) {
          await postsProvider.reload(uid);
        }
      },
      child: ListView.builder(
        itemCount: feed.length,
        itemBuilder: (context, i) {
          final post = feed[i];
          return PostCard(post: post);
        },
      ),
    );
  }
}
