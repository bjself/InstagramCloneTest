# Instagram Clone – Flutter Frontend

A Flutter mobile app connecting to the same Firebase backend as the existing React Native frontend.

## Features

- **Login & Register** – Firebase Authentication
- **Feed** – real-time posts from Firestore `/feed/{uid}/userFeed`
- **Likes & Comments** – stored in `/posts/{uid}/userPosts/{postId}/likes` and `.../comments`
- **User Profiles** – follow/unfollow, post grid, follower counts
- **Search** – find other users by name
- **Bottom tab navigation** – Feed · Search · Profile

## Getting Started

### 1. Prerequisites

- Flutter SDK ≥ 3.0 (https://flutter.dev/docs/get-started/install)
- A Firebase project (the same one used by the React Native app)

### 2. Add Firebase credentials

Two options:

**Option A – FlutterFire CLI (recommended)**
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This auto-generates `lib/firebase_options.dart` with your real credentials.

**Option B – Manual**
Edit `lib/firebase_options.dart` and replace every `'****'` value with the
credentials from your Firebase console → Project settings → Your apps.

For Android you also need `android/app/google-services.json`.  
For iOS you need `ios/Runner/GoogleService-Info.plist`.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
flutter run
```

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart               # Entry point, Firebase init, routing
│   ├── firebase_options.dart   # Firebase credentials (fill in or auto-generate)
│   ├── models/                 # Data classes matching Firestore documents
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   └── comment_model.dart
│   ├── services/               # Firebase access layer
│   │   ├── auth_service.dart
│   │   └── firestore_service.dart
│   ├── providers/              # State management (Provider package)
│   │   ├── auth_provider.dart
│   │   ├── feed_provider.dart
│   │   └── user_provider.dart
│   ├── screens/                # Full-page screens
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart    # Bottom tab shell
│   │   ├── feed_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── search_screen.dart
│   │   └── comments_screen.dart
│   └── widgets/                # Reusable UI components
│       ├── post_card.dart
│       ├── comment_item.dart
│       └── user_card.dart
└── test/
    └── widget_test.dart        # Basic widget smoke tests
```

## Firestore Data Model

Matches the existing React Native app exactly:

| Collection path | Description |
|---|---|
| `/users/{uid}` | User profile |
| `/posts/{uid}/userPosts/{postId}` | Post documents |
| `/posts/{uid}/userPosts/{postId}/likes/{likeId}` | Like markers |
| `/posts/{uid}/userPosts/{postId}/comments/{commentId}` | Comments |
| `/feed/{uid}/userFeed/{postId}` | Fan-out feed for home screen |
| `/following/{uid}/userFollowing/{targetUid}` | Follow relationships |

## Running Tests

```bash
flutter test
```
