import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _service = FirestoreService();

  String? _uid;
  UserModel? _user;
  List<PostModel> _posts = [];
  bool _loading = true;
  bool _following = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    final String targetUid;
    if (arg is String) {
      targetUid = arg;
    } else {
      final authProvider =
          Provider.of<ap.AuthProvider>(context, listen: false);
      targetUid = authProvider.currentUser?.uid ?? '';
    }

    if (targetUid != _uid) {
      _uid = targetUid;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final user = await _service.getUser(_uid!);
    final posts = await _service.getUserPosts(_uid!);
    final following = await _service.isFollowing(_uid!);
    if (mounted) {
      setState(() {
        _user = user;
        _posts = posts;
        _following = following;
        _loading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final userProvider =
        Provider.of<UserProvider>(context, listen: false);
    if (_following) {
      await userProvider.unfollow(_uid!);
    } else {
      await userProvider.follow(_uid!);
    }
    setState(() => _following = !_following);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<ap.AuthProvider>(context, listen: false);
    final isMe = _uid == authProvider.currentUser?.uid;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
        elevation: 0.5,
        actions: isMe
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await authProvider.signOut();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                )
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _ProfileHeader(
                user: _user!,
                postCount: _posts.length,
                isMe: isMe,
                following: _following,
                onFollowToggle: _toggleFollow,
              ),
              const Divider(height: 1),
              _PostGrid(posts: _posts, user: _user!),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  final int postCount;
  final bool isMe;
  final bool following;
  final VoidCallback onFollowToggle;

  const _ProfileHeader({
    required this.user,
    required this.postCount,
    required this.isMe,
    required this.following,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          CachedNetworkImageProvider(user.image),
                    ),
              const SizedBox(width: 20),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(label: 'Posts', value: postCount),
                    _Stat(
                        label: 'Followers',
                        value: user.followersCount),
                    _Stat(
                        label: 'Following',
                        value: user.followingCount),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(user.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (user.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(user.description),
          ],
          const SizedBox(height: 12),
          if (!isMe)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onFollowToggle,
                child: Text(
                  following ? 'Following' : 'Follow',
                  style: TextStyle(
                    color: following ? Colors.black : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ── Post grid ──────────────────────────────────────────────────────────────────

class _PostGrid extends StatelessWidget {
  final List<PostModel> posts;
  final UserModel user;

  const _PostGrid({required this.posts, required this.user});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No posts yet.')),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final imageUrl =
            post.type == 0 ? post.downloadURLStill : post.downloadURL;
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/comments',
            arguments: {
              'postOwnerUid': user.uid,
              'postId': post.id,
              'currentUserName': '',
            },
          ),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image)),
          ),
        );
      },
    );
  }
}
