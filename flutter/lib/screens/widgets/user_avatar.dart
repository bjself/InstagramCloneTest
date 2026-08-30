import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shared avatar widget — shows a placeholder icon when image is 'default'.
class UserAvatar extends StatelessWidget {
  final String image;
  final double size;

  const UserAvatar({super.key, required this.image, this.size = 36});

  @override
  Widget build(BuildContext context) {
    if (image == 'default' || image.isEmpty) {
      return Icon(Icons.account_circle, size: size, color: Colors.grey[600]);
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Icon(Icons.account_circle,
            size: size, color: Colors.grey[400]),
        errorWidget: (_, __, ___) =>
            Icon(Icons.account_circle, size: size, color: Colors.grey[400]),
      ),
    );
  }
}
