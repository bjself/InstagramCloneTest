import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../services/app_state.dart';
import '../../../services/firestore_service.dart';

/// Lets users pick a photo from their gallery and upload it as a new post.
/// Mirrors the React Native Camera + Save screens combined.
class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  final _captionCtrl = TextEditingController();
  bool _uploading = false;
  String? _error;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (_image == null) {
      setState(() => _error = 'Please select a photo first.');
      return;
    }
    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      final fs = context.read<FirestoreService>();
      final path =
          'post/${fs.uid}/${DateTime.now().millisecondsSinceEpoch}';
      final url = await fs.uploadFile(_image!, path);
      await fs.addPost(
        downloadURL: url,
        caption: _captionCtrl.text.trim(),
        type: 1, // image
      );
      // Refresh feed so the new post appears immediately.
      await context.read<AppState>().refreshFeed();
      if (mounted) {
        _captionCtrl.clear();
        setState(() => _image = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post shared!')),
        );
      }
    } catch (e) {
      setState(() => _error = 'Upload failed. Please try again.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Image preview / picker
          GestureDetector(
            onTap: _uploading ? null : _pickImage,
            child: Container(
              height: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _image == null
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to choose a photo',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!, fit: BoxFit.cover,
                          width: double.infinity),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Caption
          TextField(
            controller: _captionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write a caption…',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _uploading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF405DE6),
                foregroundColor: Colors.white,
              ),
              child: _uploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Share',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
