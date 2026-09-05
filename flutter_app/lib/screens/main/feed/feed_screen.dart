import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/app_state.dart';
import '../../../widgets/post_card.dart';

/// Shows a chronological feed of posts from followed users.
/// Mirrors the React Native Feed.js screen.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appState.feed.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No posts yet.\nFollow people to see their posts here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: appState.refreshFeed,
      child: ListView.builder(
        itemCount: appState.feed.length,
        itemBuilder: (_, i) => PostCard(post: appState.feed[i]),
      ),
    );
  }
}
