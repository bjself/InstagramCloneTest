import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';

/// User search screen. Mirrors React Native Search.js.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<UserModel> _results = [];

  Future<void> _search(String query) async {
    final users =
        await context.read<FirestoreService>().searchUsers(query);
    if (mounted) setState(() => _results = users);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: 'Search users…',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: _search,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (_, i) {
              final u = _results[i];
              return ListTile(
                leading: u.image == 'default'
                    ? const CircleAvatar(child: Icon(Icons.person))
                    : CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(u.image),
                      ),
                title: Text(u.username,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(u.name),
                onTap: () => context.go('/home/profile/${u.uid}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
