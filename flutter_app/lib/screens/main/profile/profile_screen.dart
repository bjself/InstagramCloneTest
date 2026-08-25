import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../../../services/app_state.dart';
import '../../../services/firestore_service.dart';

/// Displays a user's profile with their post grid, follower counts,
/// and follow/unfollow/message actions.
/// Mirrors React Native Profile.js.
class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  List<PostModel> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen old) {
    super.didUpdateWidget(old);
    if (old.uid != widget.uid) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final fs = context.read<FirestoreService>();
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    if (widget.uid == myUid) {
      final appState = context.read<AppState>();
      _user = appState.currentUser;
    } else {
      _user = await fs.fetchUser(widget.uid);
    }

    _posts = await fs.fetchUserPosts(widget.uid);
    for (final p in _posts) {
      p.user = _user;
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final isMe = widget.uid == myUid;

    // Use live currentUser data when viewing own profile.
    final user = isMe ? (appState.currentUser ?? _user) : _user;
    final following = appState.following;
    final isFollowing = following.contains(widget.uid);
    final fs = context.read<FirestoreService>();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: isMe
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, user, isMe, isFollowing, fs)),
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final p = _posts[i];
                  final thumb = p.type == 0
                      ? (p.downloadURLStill ?? p.downloadURL)
                      : p.downloadURL;
                  return GestureDetector(
                    onTap: () =>
                        context.go('/home/post/${p.creatorUid}/${p.id}'),
                    child: CachedNetworkImage(
                      imageUrl: thumb,
                      fit: BoxFit.cover,
                    ),
                  );
                },
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user, bool isMe,
      bool isFollowing, FirestoreService fs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              user.image == 'default'
                  ? const CircleAvatar(
                      radius: 40, child: Icon(Icons.person, size: 40))
                  : CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          CachedNetworkImageProvider(user.image),
                    ),
              const SizedBox(width: 24),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat(_posts.length.toString(), 'Posts'),
                    _stat(user.followersCount.toString(), 'Followers'),
                    _stat(user.followingCount.toString(), 'Following'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(user.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (user.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(user.description),
          ],
          const SizedBox(height: 12),
          // Action buttons
          if (isMe)
            _outlinedButton('Edit Profile',
                onTap: () => context.go('/home/edit'))
          else
            Row(
              children: [
                Expanded(
                  child: _outlinedButton(
                    isFollowing ? 'Following' : 'Follow',
                    color: isFollowing ? null : const Color(0xFF405DE6),
                    textColor: isFollowing ? Colors.black : Colors.white,
                    onTap: () => isFollowing
                        ? fs.unfollow(widget.uid)
                        : fs.follow(widget.uid),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _outlinedButton('Message',
                      onTap: () =>
                          context.go('/home/chat/${widget.uid}')),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _stat(String count, String label) => Column(
        children: [
          Text(count,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );

  Widget _outlinedButton(
    String label, {
    Color? color,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.black,
          ),
        ),
      ),
    );
  }
}
