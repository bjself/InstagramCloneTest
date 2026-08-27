import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/feed_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (feedProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final posts = feedProvider.posts;

    if (posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 12),
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
      onRefresh: () async {
        Provider.of<FeedProvider>(context, listen: false).startListening();
      },
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return FutureBuilder<UserModel?>(
            future: userProvider.loadUser(post.creator),
            builder: (context, snap) {
              final postUser = snap.data;
              if (postUser == null) {
                return const SizedBox(height: 8);
              }
              return PostCard(
                post: post,
                postUser: postUser,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/comments',
                  arguments: {
                    'postOwnerUid': postUser.uid,
                    'postId': post.id,
                    'currentUserName':
                        Provider.of<ap.AuthProvider>(context, listen: false)
                                .currentUser
                                ?.name ??
                            '',
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
