import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../services/auth_service.dart';
import 'add/add_post_screen.dart';
import 'chat/chat_list_screen.dart';
import 'feed/feed_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';

/// Shell screen that hosts the five bottom-tab destinations,
/// mirroring the React Native Main.js tab navigator.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _pages = [
      const FeedScreen(),
      const SearchScreen(),
      const AddPostScreen(),
      const ChatListScreen(),
      ProfileScreen(uid: uid),
    ];
  }

  static const _titles = [
    'Instagram',
    'Search',
    'New Post',
    'Messages',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // Redirect banned users.
    if (appState.currentUser?.banned == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Account Suspended'),
            content: const Text(
                'Your account has been suspended. Please contact support.'),
            actions: [
              TextButton(
                onPressed: () async {
                  await context.read<AuthService?>()?.signOut() ??
                      FirebaseAuth.instance.signOut();
                  if (mounted) context.go('/login');
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}
