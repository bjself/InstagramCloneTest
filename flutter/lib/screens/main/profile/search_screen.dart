import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';
import '../../widgets/user_avatar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<UserModel> _results = [];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final db = context.read<FirestoreService>();
    final results = await db.searchUsers(query);
    if (mounted) setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: 'Search users…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _search,
          ),
        ),
        Expanded(
          child: _results.isEmpty
              ? const Center(
                  child: Text('Search for users by username',
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, i) => _buildUserRow(_results[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildUserRow(UserModel user) {
    return ListTile(
      leading: UserAvatar(image: user.image, size: 50),
      title: Text(user.username,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(user.name),
      onTap: () => context.go('/main/profile/${user.uid}'),
    );
  }
}
