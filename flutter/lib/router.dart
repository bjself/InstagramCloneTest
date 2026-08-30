import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/main/post/post_screen.dart';
import 'screens/main/post/comment_screen.dart';
import 'screens/main/profile/profile_screen.dart';
import 'screens/main/profile/edit_screen.dart';
import 'screens/main/chat/chat_screen.dart';
import 'screens/main/add/save_screen.dart';
import 'screens/main/random/blocked_screen.dart';

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: authProvider.isLoggedIn ? '/main' : '/login',
    redirect: (context, state) {
      final loggedIn = authProvider.isLoggedIn;
      final onAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/main';
      return null;
    },
    refreshListenable: authProvider,
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/main',
        builder: (_, __) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'post/:ownerUid/:postId',
            builder: (_, state) => PostScreen(
              ownerUid: state.pathParameters['ownerUid']!,
              postId: state.pathParameters['postId']!,
            ),
          ),
          GoRoute(
            path: 'comment/:ownerUid/:postId',
            builder: (_, state) => CommentScreen(
              ownerUid: state.pathParameters['ownerUid']!,
              postId: state.pathParameters['postId']!,
            ),
          ),
          GoRoute(
            path: 'profile/:uid',
            builder: (_, state) =>
                ProfileScreen(uid: state.pathParameters['uid']!),
          ),
          GoRoute(path: 'edit', builder: (_, __) => const EditScreen()),
          GoRoute(
            path: 'chat/:chatId',
            builder: (_, state) => ChatScreen(
              chatId: state.pathParameters['chatId']!,
              otherUserId: state.uri.queryParameters['otherUid'] ?? '',
            ),
          ),
          GoRoute(
            path: 'save',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return SaveScreen(
                filePath: extra['filePath'] as String? ?? '',
                type: extra['type'] as int? ?? 1,
                thumbnailPath: extra['thumbnailPath'] as String?,
              );
            },
          ),
          GoRoute(path: 'blocked', builder: (_, __) => const BlockedScreen()),
        ],
      ),
    ],
  );
}
