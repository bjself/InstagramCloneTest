import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String image;
  final String description;
  final int followersCount;
  final int followingCount;
  final String? notificationToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.image,
    this.description = '',
    this.followersCount = 0,
    this.followingCount = 0,
    this.notificationToken,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      image: data['image'] ?? 'default',
      description: data['description'] ?? '',
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      notificationToken: data['notificationToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'image': image,
      'description': description,
      'followersCount': followersCount,
      'followingCount': followingCount,
      if (notificationToken != null) 'notificationToken': notificationToken,
    };
  }
}
