import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/posts_provider.dart';
import 'post/feed_screen.dart';
import 'profile/search_screen.dart';
import 'add/camera_screen.dart';
import 'chat/chat_list_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _lastUid = '';

  static const List<String> _titles = [
    'Instagram',
    'Search',
    'Camera',
    'Chat',
    'Profile',
  ];

  List<Widget> _buildScreens(String currentUid) => [
    const FeedScreen(),
    const SearchScreen(),
    const CameraScreen(),
    const ChatListScreen(),
    ProfileScreen(uid: currentUid),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Guard: if user is banned, navigate to blocked screen.
    if (authProvider.currentUser?.banned == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/main/blocked');
      });
    }

    final currentUid = authProvider.currentUser?.uid ?? '';

    final screens = _buildScreens(currentUid);

    return Scaffold(
      appBar: _currentIndex != 2
          ? AppBar(
              title: Text(_titles[_currentIndex]),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Camera'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}
