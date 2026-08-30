# Flutter Front-End — Instagram Clone

A Flutter mobile app that shares the **same Firebase backend** as the React Native front-end in `/frontend/`. Users on both platforms interact with the same Firestore data — same posts, likes, comments, follows, and messages.

---

## Features

| Screen | Description |
|--------|-------------|
| Login / Sign Up | Firebase Auth — email + password |
| Feed | Posts from followed users, real-time likes |
| Post detail | Full post view, like/unlike, comments |
| Comments | Add and view comments |
| Profile | Posts grid, followers/following counts, follow/unfollow, message |
| Edit Profile | Change name, bio, and profile photo |
| Search | Find users by username |
| Camera / Add Post | Pick photo or video from gallery, write caption, upload to Firebase Storage |
| Chat List | All DM conversations |
| Direct Message | Real-time messages via Firestore |
| Blocked | Shown when admin has banned the account |

---

## Project Structure

```
flutter/
  lib/
    main.dart                   # App entry point, providers wired up
    router.dart                 # go_router navigation
    firebase_config.dart        # Credential placeholders (see setup)
    models/
      user_model.dart           # Matches Firestore users/{uid}
      post_model.dart           # Matches posts/{uid}/userPosts/{postId}
      comment_model.dart        # Matches .../comments/{commentId}
      chat_model.dart           # Matches chats/{chatId} + messages
    services/
      auth_service.dart         # Firebase Auth wrapper
      firestore_service.dart    # All Firestore + Storage operations
    providers/
      auth_provider.dart        # Auth state + current user stream
      posts_provider.dart       # Feed, own posts, like state
      chats_provider.dart       # Chat list stream
    screens/
      auth/
        login_screen.dart
        register_screen.dart
      main/
        main_screen.dart        # Bottom-tab shell
        post/
          feed_screen.dart
          post_screen.dart
          post_card.dart        # Reusable post card widget
          comment_screen.dart
        profile/
          profile_screen.dart
          edit_screen.dart
          search_screen.dart
        add/
          camera_screen.dart    # Photo/video picker
          save_screen.dart      # Caption + upload
        chat/
          chat_list_screen.dart
          chat_screen.dart
        random/
          blocked_screen.dart
      widgets/
        user_avatar.dart        # Shared avatar widget
  test/
    models_test.dart            # Unit tests for data models
  android/
    app/
      google-services.json      # ← replace with real credentials
  ios/
    README.md                   # iOS setup instructions
  pubspec.yaml
```

---

## Setup

### 1. Firebase credentials

This app connects to the **same Firebase project** as the React Native app.

**Android:**
1. Go to Firebase Console → Project Settings → Your apps
2. Add an Android app with package name `com.example.instagram_clone_flutter`
3. Download `google-services.json`
4. Replace `flutter/android/app/google-services.json` with the real file

**iOS:**
1. Add an iOS app in the same Firebase project
2. Download `GoogleService-Info.plist`
3. Place it at `flutter/ios/Runner/GoogleService-Info.plist`
4. Follow instructions in `flutter/ios/README.md`

### 2. Install dependencies

```bash
cd flutter
flutter pub get
```

### 3. Run

```bash
flutter run
```

---

## Shared Firestore Schema

The Flutter app reads and writes the same collections as the React Native app:

| Collection | Description |
|-----------|-------------|
| `users/{uid}` | User profiles |
| `posts/{uid}/userPosts/{postId}` | Posts |
| `posts/{uid}/userPosts/{postId}/likes/{likerUid}` | Likes (Cloud Function updates count) |
| `posts/{uid}/userPosts/{postId}/comments/{id}` | Comments (Cloud Function updates count) |
| `following/{uid}/userFollowing/{targetUid}` | Following relationships (Cloud Function updates counts) |
| `chats/{chatId}` | Chat rooms |
| `chats/{chatId}/messages/{id}` | Messages |

The existing Cloud Functions (`addLike`, `removeLike`, `addFollower`, `removeFollower`, `addComment`) work automatically for Flutter users too — no backend changes needed.

---

## Running Tests

```bash
cd flutter
flutter test
```

Tests in `test/models_test.dart` verify that data models parse Firestore documents correctly, using an in-memory Firestore fake — no Firebase project needed.

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `firebase_storage` | File uploads |
| `provider` | State management |
| `go_router` | Navigation |
| `image_picker` | Photo/video selection |
| `cached_network_image` | Efficient image loading |
| `timeago` | Human-readable timestamps |
