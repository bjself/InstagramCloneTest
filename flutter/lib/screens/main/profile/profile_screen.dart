import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  List<PostModel> _posts = [];
  bool _following = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didUpdateWidget(ProfileScreen old) {
    super.didUpdateWidget(old);
    if (old.uid != widget.uid) _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final db = context.read<FirestoreService>();
    final authProvider = context.read<AuthProvider>();
    final currentUid = authProvider.currentUser?.uid ?? '';

    if (widget.uid == currentUid) {
      _user = authProvider.currentUser;
    } else {
      _user = await db.fetchUser(widget.uid);
    }

    _posts = await db.fetchUserPosts(widget.uid);

    // Check following.
    final followSnap = await db
        .followingStream(currentUid)
        .first;
    _following = followSnap.contains(widget.uid);

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleFollow() async {
    final db = context.read<FirestoreService>();
    if (_following) {
      await db.unfollowUser(widget.uid);
    } else {
      await db.followUser(widget.uid);
    }
    setState(() => _following = !_following);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isOwnProfile =
        widget.uid == (authProvider.currentUser?.uid ?? '');

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.username),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isOwnProfile)),
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildGridItem(_posts[i]),
              childCount: _posts.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isOwnProfile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(image: _user!.image, size: 80),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statColumn(_posts.length.toString(), 'Posts'),
                    _statColumn(
                        _user!.followersCount.toString(), 'Followers'),
                    _statColumn(
                        _user!.followingCount.toString(), 'Following'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_user!.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (_user!.description?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_user!.description!),
            ),
          const SizedBox(height: 12),
          if (isOwnProfile)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/main/edit'),
                child: const Text('Edit Profile'),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _toggleFollow,
                    child: Text(_following ? 'Following' : 'Follow'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final db = context.read<FirestoreService>();
                      final chatId = await db.ensureChat(widget.uid);
                      if (mounted) {
                        context.go(
                          '/main/chat/$chatId?otherUid=${widget.uid}',
                        );
                      }
                    },
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statColumn(String count, String label) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildGridItem(PostModel post) {
    return GestureDetector(
      onTap: () =>
          context.go('/main/post/${post.creatorUid}/${post.id}'),
      child: CachedNetworkImage(
        imageUrl: post.type == 0
            ? (post.downloadURLStill ?? post.downloadURL)
            : post.downloadURL,
        fit: BoxFit.cover,
      ),
    );
  }
}
