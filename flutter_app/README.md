# Instagram Clone — Flutter App

A Flutter mobile client for the Instagram Clone project.  
It connects to the **same Firebase project** as the existing React Native app, so both apps share users, posts, likes, comments, and messages seamlessly.

---

## Features

| Screen | What it does |
|---|---|
| **Login / Register** | Sign in or create an account using Firebase Auth |
| **Feed** | Chronological posts from people you follow |
| **Search** | Find users by username |
| **Add Post** | Pick a photo from your gallery and share it |
| **Messages** | Full chat list and one-on-one conversations |
| **Profile** | Your posts grid, follower counts, edit name/bio/photo |
| **Other Profile** | Follow/unfollow users, send a message |
| **Comments** | Read and add comments on any post |
| **Post Detail** | Full-screen view of a single post |

---

## Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | 3.x (stable channel) |
| Dart SDK | 3.x (comes with Flutter) |
| Android Studio or Xcode | Latest stable |
| A Firebase project | The same one used by the React Native app |

Install Flutter: https://docs.flutter.dev/get-started/install

---

## Quick Start

### 1 — Get the code

The Flutter app lives in the `flutter_app/` directory at the root of the repository.  
All other directories (`frontend/`, `backend/`, `admin/`) are unchanged.

```bash
cd flutter_app
flutter pub get
```

### 2 — Connect to Firebase

You need to point the Flutter app at your Firebase project.  
The easiest way is the **FlutterFire CLI**:

```bash
# Install the CLI once
dart pub global activate flutterfire_cli

# Inside flutter_app/, run:
flutterfire configure
```

This overwrites `lib/firebase_options.dart` with real values for Android, iOS, and web.

**Alternatively**, open `lib/firebase_options.dart` and replace every `YOUR_...` placeholder manually with the values from your Firebase Console → Project Settings → Your apps.  
These are the same credentials used in `frontend/App.js`.

#### Android extra step
Place your `google-services.json` file (downloaded from Firebase Console) at:
```
flutter_app/android/app/google-services.json
```

#### iOS extra step
Place your `GoogleService-Info.plist` file (downloaded from Firebase Console) inside:
```
flutter_app/ios/Runner/GoogleService-Info.plist
```
Then open `flutter_app/ios/Runner.xcworkspace` in Xcode and drag the plist into the Runner target.

### 3 — Run the app

```bash
flutter run
```

To target a specific device:
```bash
flutter run -d <device-id>   # e.g. flutter run -d emulator-5554
```

---

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                  # Entry point, routing, auth guard
│   ├── firebase_options.dart      # Firebase config (fill in your values)
│   ├── models/
│   │   ├── user_model.dart        # User document shape
│   │   ├── post_model.dart        # Post document shape
│   │   ├── chat_model.dart        # Chat + Message document shapes
│   │   └── comment_model.dart     # Comment document shape
│   ├── services/
│   │   ├── auth_service.dart      # Sign-in, register, sign-out
│   │   ├── firestore_service.dart # All Firestore + Storage operations
│   │   └── app_state.dart        # In-memory state (current user, feed)
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── main/
│   │       ├── home_screen.dart   # Bottom tab shell
│   │       ├── feed/
│   │       │   ├── feed_screen.dart
│   │       │   ├── post_detail_screen.dart
│   │       │   └── comments_screen.dart
│   │       ├── search/
│   │       │   └── search_screen.dart
│   │       ├── add/
│   │       │   └── add_post_screen.dart
│   │       ├── chat/
│   │       │   ├── chat_list_screen.dart
│   │       │   └── chat_screen.dart
│   │       └── profile/
│   │           ├── profile_screen.dart
│   │           └── edit_profile_screen.dart
│   └── widgets/
│       └── post_card.dart         # Reusable post card
├── android/                       # Android platform files
├── ios/                           # iOS platform files
├── pubspec.yaml                   # Dependencies
└── README.md                      # This file
```

---

## Shared Firebase Data

Both apps use the **same Firestore collections** and **Firebase Storage** paths:

| Collection | Contents |
|---|---|
| `users/{uid}` | Profile data |
| `posts/{uid}/userPosts/{postId}` | Posts |
| `posts/.../likes/{likerUid}` | Like records (Cloud Function updates count) |
| `posts/.../comments/{commentId}` | Comments (Cloud Function updates count) |
| `following/{uid}/userFollowing/{targetUid}` | Following graph (Cloud Function updates counts) |
| `chats/{chatId}` | Conversation metadata |
| `chats/{chatId}/messages/{msgId}` | Individual messages |
| `storage/post/{uid}/…` | Post images |
| `storage/profile/{uid}` | Profile photos |

The existing Firestore security rules (`firestore_rules.txt`) and Cloud Functions (`backend/functions/index.js`) work for both apps without any changes.

---

## Building for Release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS (requires macOS + Xcode)
```bash
flutter build ipa --release
```

---

## Troubleshooting

**`firebase_options.dart` has placeholder values**  
Run `flutterfire configure` or fill in your Firebase credentials manually.

**Android build fails with `google-services.json` not found**  
Download it from Firebase Console and place it at `android/app/google-services.json`.

**iOS build fails with missing `GoogleService-Info.plist`**  
Download it from Firebase Console and add it to the Xcode project under the Runner target.

**`MissingPluginException` on device**  
Run `flutter clean && flutter pub get` then rebuild.

**Posts or users not loading**  
Check that your Firestore security rules allow reads. The existing rules in `firestore_rules.txt` are compatible with the Flutter app.
