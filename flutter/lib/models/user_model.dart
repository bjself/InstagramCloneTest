import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the Firestore `users/{uid}` document.
class UserModel {
  final String uid;
  final String email;
  final String username;
  final String name;
  final String image; // 'default' or a download URL
  final String? description;
  final int followersCount;
  final int followingCount;
  final String? notificationToken;
  final bool banned;

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.name,
    required this.image,
    this.description,
    this.followersCount = 0,
    this.followingCount = 0,
    this.notificationToken,
    this.banned = false,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      name: data['name'] as String? ?? '',
      image: data['image'] as String? ?? 'default',
      description: data['description'] as String?,
      followersCount: (data['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (data['followingCount'] as num?)?.toInt() ?? 0,
      notificationToken: data['notificationToken'] as String?,
      banned: data['banned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'username': username,
        'name': name,
        'image': image,
        'description': description,
        'followersCount': followersCount,
        'followingCount': followingCount,
        if (notificationToken != null) 'notificationToken': notificationToken,
        'banned': banned,
      };

  UserModel copyWith({
    String? name,
    String? description,
    String? image,
    String? notificationToken,
    int? followersCount,
    int? followingCount,
    bool? banned,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        username: username,
        name: name ?? this.name,
        image: image ?? this.image,
        description: description ?? this.description,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount ?? this.followingCount,
        notificationToken: notificationToken ?? this.notificationToken,
        banned: banned ?? this.banned,
      );
}
