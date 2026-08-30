// Firebase configuration for the Flutter app.
//
// This app shares the SAME Firebase project as the React Native frontend.
// Replace the placeholder values below with the actual credentials from
// your Firebase project console (Project Settings → General → Your apps).
//
// For Android: also place google-services.json in flutter/android/app/
// For iOS:     also place GoogleService-Info.plist in flutter/ios/Runner/
//
// NEVER commit real API keys to version control. Use environment variables
// or a secrets manager (e.g. --dart-define or a gitignored config file).

class FirebaseConfig {
  // Web / general credentials — matches the React Native firebaseConfig object.
  static const String apiKey = '****';
  static const String authDomain = '****.firebaseapp.com';
  static const String projectId = '****';
  static const String storageBucket = '****.appspot.com';
  static const String messagingSenderId = '****';
  static const String appId = '****';
}
