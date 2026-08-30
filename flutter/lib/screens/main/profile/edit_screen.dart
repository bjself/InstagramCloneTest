import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  File? _newImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _descCtrl =
        TextEditingController(text: user?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (result != null) setState(() => _newImage = File(result.path));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = context.read<FirestoreService>();
    String? imageUrl;

    if (_newImage != null) {
      final uid = context.read<AuthProvider>().currentUser!.uid;
      imageUrl = await db.uploadFile(_newImage!, 'profile/$uid');
    }

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      if (imageUrl != null) 'image': imageUrl,
    };
    await db.updateUser(data);

    if (!mounted) return;
    setState(() => _saving = false);
    context.pop();
  }

  Future<void> _signOut() async {
    await context.read<AuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: _newImage != null
                        ? FileImage(_newImage!) as ImageProvider
                        : (currentUser?.image != 'default' &&
                                currentUser?.image.isNotEmpty == true
                            ? NetworkImage(currentUser!.image)
                            : null),
                    child: (_newImage == null &&
                            (currentUser?.image == 'default' ||
                                currentUser?.image.isEmpty == true))
                        ? const Icon(Icons.account_circle,
                            size: 96, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  const Text('Change Profile Photo',
                      style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            if (_saving) const CircularProgressIndicator(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _signOut,
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
