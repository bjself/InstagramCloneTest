import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/add/add_post_screen.dart';
import 'screens/main/chat/chat_screen.dart';
import 'screens/main/chat/chat_list_screen.dart';
import 'screens/main/feed/comments_screen.dart';
import 'screens/main/feed/post_detail_screen.dart';
import 'screens/main/home_screen.dart';
import 'screens/main/profile/edit_profile_screen.dart';
import 'screens/main/profile/profile_screen.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InstagramCloneApp());
}

class InstagramCloneApp extends StatelessWidget {
  const InstagramCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
      ],
      child: _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/login',
      redirect: (ctx, state) {
        final user = FirebaseAuth.instance.currentUser;
        final onAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        if (user == null && !onAuth) return '/login';
        if (user != null && onAuth) return '/home';
        return null;
      },
      refreshListenable:
          _GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'profile/:uid',
              builder: (_, state) =>
                  ProfileScreen(uid: state.pathParameters['uid']!),
            ),
            GoRoute(
              path: 'post/:uid/:postId',
              builder: (_, state) => PostDetailScreen(
                creatorUid: state.pathParameters['uid']!,
                postId: state.pathParameters['postId']!,
              ),
            ),
            GoRoute(
              path: 'comments/:uid/:postId',
              builder: (_, state) => CommentsScreen(
                creatorUid: state.pathParameters['uid']!,
                postId: state.pathParameters['postId']!,
              ),
            ),
            GoRoute(
              path: 'chat/:otherUid',
              builder: (_, state) =>
                  ChatScreen(otherUid: state.pathParameters['otherUid']!),
            ),
            GoRoute(
              path: 'chatlist',
              builder: (_, __) => const ChatListScreen(),
            ),
            GoRoute(
              path: 'addpost',
              builder: (_, __) => const AddPostScreen(),
            ),
            GoRoute(
              path: 'edit',
              builder: (_, __) => const EditProfileScreen(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sync AppState whenever auth changes.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        final appState = ctx.read<AppState>();
        if (snapshot.hasData && snapshot.data != null) {
          appState.init(snapshot.data!);
        } else {
          appState.clear();
        }
        return MaterialApp.router(
          title: 'Instagram Clone',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF405DE6)),
            useMaterial3: true,
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

/// Bridges a Stream into a Listenable so GoRouter re-evaluates redirects.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
