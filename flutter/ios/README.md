# iOS Setup

To build for iOS:

1. Download `GoogleService-Info.plist` from your Firebase project console.
   - Firebase Console → Project Settings → Your apps → iOS → Download GoogleService-Info.plist
   - The Flutter app shares the **same Firebase project** as the React Native app.

2. Place the downloaded file at `flutter/ios/Runner/GoogleService-Info.plist`.

3. Open `flutter/ios/Runner.xcworkspace` in Xcode.

4. Make sure the Bundle ID matches the one registered in Firebase
   (default: `com.example.instagramCloneFlutter`).

5. Add the following keys to `Info.plist` for camera and photo library access:
   - `NSCameraUsageDescription`
   - `NSPhotoLibraryUsageDescription`
   - `NSMicrophoneUsageDescription`

6. Run `flutter pub get` and then `flutter run` from the `flutter/` directory.
