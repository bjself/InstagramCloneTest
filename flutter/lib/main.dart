import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/posts_provider.dart';
import 'providers/chats_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const InstagramCloneApp());
}

class InstagramCloneApp extends StatefulWidget {
  const InstagramCloneApp({super.key});

  @override
  State<InstagramCloneApp> createState() => _InstagramCloneAppState();
}

class _InstagramCloneAppState extends State<InstagramCloneApp> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(_authService, _firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => PostsProvider(_firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatsProvider(_firestoreService),
        ),
        // Expose FirestoreService so screens can access it directly.
        Provider<FirestoreService>.value(value: _firestoreService),
      ],
      child: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Kick off data loading whenever the user logs in.
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      final uid = authProvider.currentUser!.uid;
      Future.microtask(() {
        if (!mounted) return;
        context.read<PostsProvider>().init(uid);
        context.read<ChatsProvider>().init(uid);
      });
    }

    // Build the router only once; GoRouter's refreshListenable handles
    // subsequent auth changes internally without recreating the whole router.
    _router ??= buildRouter(authProvider);

    return MaterialApp.router(
      title: 'Instagram Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router!,
      debugShowCheckedModeBanner: false,
    );
  }
}
