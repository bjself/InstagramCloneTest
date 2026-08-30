import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Camera tab — lets the user pick a photo or video from their device gallery
/// (or take one with the camera) before proceeding to the Save screen.
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  Future<void> _pick(BuildContext context, ImageSource source, bool video) async {
    final picker = ImagePicker();
    XFile? result;
    if (video) {
      result = await picker.pickVideo(source: source);
    } else {
      result = await picker.pickImage(
          source: source, imageQuality: 90);
    }
    if (result == null) return;
    if (!context.mounted) return;
    context.go('/main/save', extra: {
      'filePath': result.path,
      'type': video ? 0 : 1,
      'thumbnailPath': null,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'New Post',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _PickButton(
              icon: Icons.photo_library,
              label: 'Photo from Gallery',
              onTap: () => _pick(context, ImageSource.gallery, false),
            ),
            const SizedBox(height: 16),
            _PickButton(
              icon: Icons.videocam,
              label: 'Video from Gallery',
              onTap: () => _pick(context, ImageSource.gallery, true),
            ),
            const SizedBox(height: 16),
            _PickButton(
              icon: Icons.camera_alt,
              label: 'Take a Photo',
              onTap: () => _pick(context, ImageSource.camera, false),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: Icon(icon),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}
