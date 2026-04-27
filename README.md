# Buddy - Flutter App Setup Guide

## Overview
This document describes the Firebase configuration and backend proxy contract for the Buddy Flutter app.

---

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project: `buddy-app`
3. Enable Google Analytics (optional)

### 2. Add Firebase to Android
1. Go to Project Settings > Your apps > Android
2. Add app package name: `com.buddy.buddy`
3. Download `google-services.json`
4. Place in `android/app/google-services.json`

### 3. Add Firebase to iOS  
1. Go to Project Settings > Your apps > iOS
2. Add app bundle id: `com.buddy.buddy`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/GoogleService-Info.plist`

### 4. Enable Firebase Auth
1. Go to Authentication > Sign-in method
2. Enable Email/Password

### 5. Enable Cloud Firestore
1. Go to Firestore Database
2. Create database (start in test mode)
3. Configure security rules for production

### 6. Configure google-services.json
Update `lib/core/constants/app_constants.dart` with your Firebase config:
```dart
static const String firebaseApiKey = 'YOUR_API_KEY';
static const String firebaseProjectId = 'buddy-app';
static const String firebaseStorageBucket = 'buddy-app.appspot.com';
static const String firebaseMessagingSenderId = '000000000000';
static const String firebaseAppId = '1:000000000000:android:0000000000000';
static const String firebaseDatabaseUrl = 'https://buddy-app.firebaseio.com';
```

---

## Backend Proxy Contract

### Overview
The chat feature uses a backend AI proxy service to handle LLM interactions. The proxy exposes REST APIs that the Flutter app calls.

### API Endpoints

#### POST /chat
Send a message to the AI and get a response.

**Request:**
```json
{
  "message": "I'm feeling anxious today",
  "userId": "user_123",
  "context": {
    "mood": "good",
    "lastMoodEntry": "2024-01-15T10:30:00Z"
  }
}
```

**Response:**
```json
{
  "reply": "I hear that you're feeling anxious. Would you like to talk about what's causing these feelings?",
  "suggestions": ["Take deep breaths", "Share more details"],
  "conversationId": "conv_abc123"
}
```

#### GET /chat/{conversationId}
Get AI response for an existing conversation.

**Response:**
```json
{
  "reply": "Thank you for sharing that with me.",
  "timestamp": "2024-01-15T10:35:00Z"
}
```

### Implementation
Update `lib/core/constants/app_constants.dart` with your proxy URL:
```dart
static const String backendProxyBaseUrl = 'https://your-proxy.example.com';
```

---

## Firestore Data Models

### mood_entries Collection
```json
{
  "id": "uuid",
  "userId": "firebase_user_uid",
  "mood": 3,
  "note": "Feeling okay today",
  "tags": {"work": true},
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### users Collection
```json
{
  "id": "firebase_user_uid",
  "email": "user@example.com",
  "displayName": "John",
  "createdAt": "2024-01-01T00:00:00Z",
  "lastLoginAt": "2024-01-15T10:00:00Z"
}
```

---

## Next Steps

### High Priority
1. **Configure Firebase**: Add your Firebase config to `app_constants.dart`
2. **Set up Backend Proxy**: Deploy the AI proxy service
3. **Test Auth**: Verify email/password login works
4. **Test Chat**: Verify messages send/receive correctly

### Medium Priority
1. **Notifications**: Add Firebase Cloud Messaging
2. **Voice Calls**: Integrate WebRTC for voice calls
3. **Analytics**: Add Firebase Analytics events

### Low Priority
1. **Dark Mode**: Add theme switching
2. **Widgets**: Add home screen widgets
3. **Push Notifications**: Real-time alerts

---

## Build & Run

```bash
cd buddy_flutter
flutter pub get
flutter run
```

## Build APK
```bash
flutter build apk --debug
flutter build apk --release
```

## Build iOS
```bash
flutter build ios --debug
flutter build ios --release
```