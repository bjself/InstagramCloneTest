import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the Firestore `users` collection document structure.
class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String image; // 'default' or a download URL
  final String description;
  final int followersCount;
  final int followingCount;
  final bool banned;
  final String? notificationToken;

  const UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    this.image = 'default',
    this.description = '',
    this.followersCount = 0,
    this.followingCount = 0,
    this.banned = false,
    this.notificationToken,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: d['name'] ?? '',
      username: d['username'] ?? '',
      email: d['email'] ?? '',
      image: d['image'] ?? 'default',
      description: d['description'] ?? '',
      followersCount: (d['followersCount'] ?? 0) as int,
      followingCount: (d['followingCount'] ?? 0) as int,
      banned: d['banned'] ?? false,
      notificationToken: d['notificationToken'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'username': username,
        'email': email,
        'image': image,
        'description': description,
        'followersCount': followersCount,
        'followingCount': followingCount,
        'banned': banned,
        if (notificationToken != null) 'notificationToken': notificationToken,
      };
}
