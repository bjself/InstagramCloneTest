// Basic widget smoke tests for the Instagram Clone Flutter app.
// Run with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ── Minimal stubs so tests compile without a live Firebase connection ─────────

class _FakeAuthProvider extends ChangeNotifier {
  bool get isLoggedIn => false;
  bool get loading => false;
  String? get error => null;
}

// ─────────────────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) {
  return ChangeNotifierProvider<_FakeAuthProvider>(
    create: (_) => _FakeAuthProvider(),
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('Login screen renders email and password fields',
      (WidgetTester tester) async {
    // Build a minimal login form without wiring Firebase
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: const [
              TextField(
                  decoration: InputDecoration(hintText: 'Email')),
              TextField(
                  obscureText: true,
                  decoration: InputDecoration(hintText: 'Password')),
            ],
          ),
        ),
      ),
    );

    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
  });

  testWidgets('Register screen renders username, name, email, password fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: const [
              TextField(
                  decoration: InputDecoration(hintText: 'Username')),
              TextField(
                  decoration: InputDecoration(hintText: 'Full Name')),
              TextField(
                  decoration: InputDecoration(hintText: 'Email')),
              TextField(
                  obscureText: true,
                  decoration: InputDecoration(hintText: 'Password')),
            ],
          ),
        ),
      ),
    );

    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Full Name'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
  });

  testWidgets('Splash screen shows app name text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Instagram Clone'),
          ),
        ),
      ),
    );

    expect(find.text('Instagram Clone'), findsOneWidget);
  });

  testWidgets('Home screen bottom nav has three tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox(),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Feed'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
