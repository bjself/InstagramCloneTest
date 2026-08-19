# Contributing to Instagram Clone

Thank you for your interest in contributing! This document walks you through everything you need to set up the project locally, understand its structure, and submit high-quality contributions.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Project Overview](#project-overview)
3. [Prerequisites](#prerequisites)
4. [Firebase Setup](#firebase-setup)
5. [Local Setup](#local-setup)
   - [Frontend (React Native / Expo)](#frontend-react-native--expo)
   - [Admin Panel (ReactJS)](#admin-panel-reactjs)
   - [Backend (Firebase Cloud Functions)](#backend-firebase-cloud-functions)
6. [Configuration](#configuration)
7. [Running the Project](#running-the-project)
8. [Project Structure](#project-structure)
9. [Code Conventions](#code-conventions)
10. [Submitting a Contribution](#submitting-a-contribution)
11. [Reporting Bugs & Requesting Features](#reporting-bugs--requesting-features)

---

## Code of Conduct

Please be respectful and constructive in all interactions. Harassment, discrimination, or abusive language of any kind will not be tolerated.

---

## Project Overview

This repository has three independently runnable parts:

| Directory | Purpose | Tech |
|-----------|---------|------|
| `frontend/` | React Native mobile app | Expo 42, Redux, Firebase 8 |
| `admin/` | Web-based admin panel | ReactJS 17, Material-UI, Bootstrap |
| `backend/functions/` | Server-side logic | Node.js, Firebase Cloud Functions |

Security rules for Firestore and Storage live in `firestore_rules.txt` and `storage_rules.txt` at the repo root.

---

## Prerequisites

Make sure you have the following installed before starting:

- **Node.js** ≥ 14 (check with `node -v`)
- **npm** ≥ 6 or **Yarn** (check with `npm -v`)
- **Expo CLI** — install globally:
  ```bash
  npm install -g expo-cli
  ```
- **Firebase CLI** — install globally (needed for Cloud Functions):
  ```bash
  npm install -g firebase-tools
  ```
- A **Firebase project** with the following services enabled:
  - Authentication (Email/Password)
  - Firestore
  - Storage
  - Cloud Functions

---

## Firebase Setup

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project (or use an existing one).
2. Enable **Email/Password** authentication under *Authentication → Sign-in method*.
3. Create a **Firestore** database (start in test mode, then apply `firestore_rules.txt`).
4. Enable **Firebase Storage** and apply `storage_rules.txt`.
5. Enable **Cloud Functions** (requires the Blaze pay-as-you-go plan).
6. Retrieve your Firebase web config object from *Project Settings → General → Your apps*.

---

## Local Setup

### Frontend (React Native / Expo)

```bash
cd frontend
npm install
```

Copy your Firebase config values into `frontend/App.js`, replacing the `****` placeholders in the `firebaseConfig` object:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  databaseURL: "YOUR_DATABASE_URL",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};
```

For Android push notifications, place your `google-services.json` in `frontend/`.  
For iOS, place your `GoogleService-Info.plist` in `frontend/`.

> **Never commit real credentials.** The `****` placeholders are intentional — keep sensitive keys out of version control.

### Admin Panel (ReactJS)

```bash
cd admin
npm install
```

Copy your Firebase config values into `admin/src/config/config.js`, replacing the `****` placeholders:

```javascript
export var firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  databaseURL: "YOUR_DATABASE_URL",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};
```

To grant admin access to a user, add a document to the `admin` Firestore collection whose document ID matches the user's Firebase UID. Firestore rules prevent admin documents from being read or written by clients, so this must be done manually in the Firebase Console.

### Backend (Firebase Cloud Functions)

```bash
cd backend/functions
npm install
```

Log in to Firebase and link the project:

```bash
firebase login
firebase use --add   # select your Firebase project
```

---

## Configuration

| File | What to fill in |
|------|----------------|
| `frontend/App.js` | `firebaseConfig` object |
| `frontend/app.json` | Android `googleSignIn.apiKey`, iOS `reservedClientId` & `googleMapsApiKey` (optional for local dev) |
| `admin/src/config/config.js` | `firebaseConfig` object |
| `backend/functions/` | Firebase project is inferred from `firebase use`; no extra config needed |

---

## Running the Project

### Frontend

```bash
cd frontend
expo start
```

- Press **a** to open on a connected Android device/emulator.
- Press **i** to open on an iOS simulator (macOS only).
- Scan the QR code with the **Expo Go** app on your physical device.

### Admin Panel

```bash
cd admin
npm start
```

Opens at `http://localhost:3000` in your browser.

### Backend (deploy Cloud Functions)

```bash
cd backend
firebase deploy --only functions
```

To test functions locally with the Firebase Emulator Suite:

```bash
firebase emulators:start
```

### Firestore & Storage Rules

Apply rules from the repo root using the Firebase CLI:

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

---

## Project Structure

```
InstagramClone/
├── frontend/                   # React Native / Expo mobile app
│   ├── App.js                  # App entry point, navigation, Firebase init
│   ├── app.json                # Expo configuration
│   ├── assets/                 # Images and static assets
│   ├── components/
│   │   ├── auth/               # Login & Register screens
│   │   ├── main/
│   │   │   ├── add/            # Post creation (Save screen)
│   │   │   ├── chat/           # Chat & ChatList screens
│   │   │   ├── post/           # Post & Comment screens
│   │   │   ├── profile/        # Profile & Edit screens
│   │   │   └── random/         # Utility screens (e.g. Blocked)
│   │   ├── styles.js           # Shared style constants
│   │   └── utils.js            # Shared helper functions
│   └── redux/
│       ├── actions/            # Redux action creators
│       ├── reducers/           # Redux reducers
│       └── constants/          # Action type constants
│
├── admin/                      # ReactJS admin panel
│   └── src/
│       ├── App.js              # Root component with auth guard
│       ├── config/config.js    # Firebase config (fill in credentials)
│       └── components/         # Admin UI components
│
├── backend/
│   └── functions/
│       └── index.js            # Firebase Cloud Functions
│
├── firestore_rules.txt         # Firestore security rules
├── storage_rules.txt           # Firebase Storage security rules
└── README.md
```

---

## Code Conventions

### General

- **Component files** use PascalCase: `Login.js`, `Profile.js`
- **Utility files** use camelCase: `utils.js`, `styles.js`
- **Firestore collections** use camelCase: `userPosts`, `userFollowing`
- **Redux action types** use SCREAMING_SNAKE_CASE

### Frontend Components

- Screen components are named with a `Screen` suffix: `LoginScreen`, `ProfileScreen`
- Reuse `components/styles.js` and `components/utils.js` before adding new helpers
- Use the existing Redux store (with `redux-thunk`) for shared state; avoid local state for data that other screens need

### Backend Cloud Functions

- All counter updates must use `FieldValue.increment()` for atomicity — never read-modify-write
- Each function must return the resulting Promise so Firebase can track completion

### Firebase Credentials

- **Never commit real API keys or service-account files.** The `****` sentinel values in source files are intentional — fill them in locally only.
- Add any new credential files to `.gitignore`

---

## Submitting a Contribution

1. **Fork** the repository and create a feature branch from `master`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. **Make your changes**, following the conventions above.
3. **Test** your changes:
   - Frontend: verify on at least one platform with `expo start`
   - Admin: run `npm test` inside `admin/` and confirm the UI works in the browser
   - Backend: deploy to a test Firebase project or use the emulator suite
4. **Commit** with a clear, descriptive message:
   ```bash
   git commit -m "feat: add story viewing to the feed"
   ```
5. **Push** your branch and open a Pull Request against `master`.
6. Fill in the PR template, describing *what* changed and *why*.
7. Respond to any review feedback — PRs are merged once approved.

### Commit Message Guidelines

Use the [Conventional Commits](https://www.conventionalcommits.org/) format where possible:

| Prefix | When to use |
|--------|-------------|
| `feat:` | A new feature |
| `fix:` | A bug fix |
| `docs:` | Documentation only changes |
| `refactor:` | Code restructuring without behaviour change |
| `chore:` | Tooling, dependencies, config |

---

## Reporting Bugs & Requesting Features

- Open an issue using the **Bug Report** or **Feature Request** template on the [Issues page](https://github.com/bjself/InstagramCloneTest/issues).
- Include as much context as possible: steps to reproduce, expected vs actual behaviour, platform (Android/iOS/Web), and Expo SDK version if relevant.
