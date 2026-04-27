import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buddy/providers/auth_provider.dart';
import 'package:buddy/features/auth/presentation/splash_screen.dart';
import 'package:buddy/features/auth/presentation/login_screen.dart';
import 'package:buddy/features/home/presentation/home_screen.dart';
import 'package:buddy/features/mood_checkin/presentation/mood_check_in_screen.dart';
import 'package:buddy/features/chat/presentation/chat_screen.dart';
import 'package:buddy/features/chat/presentation/voice_call_screen.dart';
import 'package:buddy/features/chat/presentation/history_screen.dart';
import 'package:buddy/features/settings/presentation/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final auth = authState;

      if (auth.isLoading) return '/splash';

      final isLoggedIn = auth.value != null;

      final isOnAuthScreen =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isOnAuthScreen) {
        return '/login';
      }

      if (isLoggedIn && isOnAuthScreen) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/mood',
        builder: (context, state) => const MoodCheckInScreen(),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(
        path: '/voice',
        builder: (context, state) => const VoiceCallScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
