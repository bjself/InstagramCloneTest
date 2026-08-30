import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/posts_provider.dart';
import '../../../services/firestore_service.dart';

class SaveScreen extends StatefulWidget {
  final String filePath;
  final int type; // 0=video, 1=image
  final String? thumbnailPath;

  const SaveScreen({
    super.key,
    required this.filePath,
    required this.type,
    this.thumbnailPath,
  });

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  final _captionCtrl = TextEditingController();
  bool _uploading = false;
  String? _error;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (_uploading) return;
    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      final db = context.read<FirestoreService>();
      final authProvider = context.read<AuthProvider>();
      final uid = authProvider.currentUser!.uid;
      final random =
          DateTime.now().millisecondsSinceEpoch.toString();

      final downloadURL = await db.uploadFile(
        File(widget.filePath),
        'post/$uid/$random',
      );

      String? downloadURLStill;
      if (widget.thumbnailPath != null) {
        final thumbRandom =
            DateTime.now().millisecondsSinceEpoch.toString();
        downloadURLStill = await db.uploadFile(
          File(widget.thumbnailPath!),
          'post/$uid/thumb_$thumbRandom',
        );
      }

      await db.createPost(
        downloadURL: downloadURL,
        downloadURLStill: downloadURLStill,
        caption: _captionCtrl.text.trim(),
        type: widget.type,
      );

      if (!mounted) return;
      // Refresh own posts in the provider.
      await context.read<PostsProvider>().refreshMyPosts(uid);
      if (!mounted) return;
      context.go('/main');
    } catch (e) {
      if (mounted) setState(() {
        _uploading = false;
        _error = 'Upload failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _uploading ? null : _upload,
          ),
        ],
      ),
      body: _uploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading…',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _captionCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption…',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1,
                    child: widget.type == 1
                        ? Image.file(File(widget.filePath),
                            fit: BoxFit.cover)
                        : Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(Icons.videocam,
                                  color: Colors.white, size: 64),
                            ),
                          ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
    );
  }
}
