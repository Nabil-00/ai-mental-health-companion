# Buddy

A cross-platform mental wellness companion built with Flutter.

Buddy combines mood check-ins, conversational support, and user-friendly wellness flows in a single mobile-first application, with optional backend proxy support for AI-powered chat.

## Highlights

- Mood check-in flow with local and backend-friendly data structures
- Chat interface designed for supportive conversations
- Authentication-ready architecture with Firebase integration
- Modular feature-based Flutter code organization
- Android, iOS, web, desktop scaffolding from one codebase

## Tech Stack

- Flutter + Dart
- Riverpod (state management)
- GoRouter (navigation)
- Firebase (Auth / Firestore / Realtime DB)
- Node.js backend proxy (`backend/`) for AI integrations

## Project Structure

```text
lib/
  app/                  # App bootstrap and router
  core/                 # Theme, constants, shared network/widgets
  features/             # Feature-first modules (auth, chat, mood, settings)
  providers/            # Global state providers
  models/               # Data models + generated serializers
backend/                # Optional API proxy service
```

## Prerequisites

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Android Studio and/or Xcode for device builds
- Node.js 18+ (only if running backend proxy)

## Quick Start

```bash
flutter pub get
flutter run
```

## Environment Setup

### Mobile App (Firebase)

1. Create a Firebase project.
2. Register Android app `com.buddy.buddy` and download `google-services.json`.
3. Register iOS app `com.buddy.buddy` and download `GoogleService-Info.plist`.
4. Place files in:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

These files are intentionally gitignored and must not be committed.

### Backend Proxy (Optional)

```bash
cd backend
cp .env.example .env
npm install
npm run start
```

Update `.env` values for your provider key and model.

## Build Commands

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

## Development Notes

- Keep production secrets in local env files or secret managers.
- Regenerate model files after model updates:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Roadmap

- Voice support integration
- Notifications and reminders
- Enhanced analytics and progress insights

## License

This repository is maintained by the project owner. Add a license file if you plan to distribute it publicly under a specific license.
