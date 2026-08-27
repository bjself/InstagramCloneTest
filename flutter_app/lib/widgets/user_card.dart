import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const UserCard({Key? key, required this.user, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: user.image == 'default'
          ? const CircleAvatar(child: Icon(Icons.person))
          : CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(user.image),
            ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('@${user.username}'),
      onTap: onTap,
    );
  }
}
