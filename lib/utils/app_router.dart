import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/main/main_scaffold.dart';
import '../screens/focus/focus_setup_screen.dart';
import '../screens/focus/focus_active_screen.dart';
import '../screens/focus/focus_result_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String focus = '/focus';
  static const String focusActive = '/focus/active';
  static const String focusResult = '/focus/result';

  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) {
        final authProvider = context.read<ap.AuthProvider>();
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.uri.path == login ||
            state.uri.path == register ||
            state.uri.path == splash;

        if (!isAuthenticated && !isAuthRoute) {
          return login;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: home,
              builder: (context, state) =>
                  const SizedBox(), // handled by MainScaffold
            ),
          ],
        ),
        GoRoute(
          path: focus,
          builder: (context, state) => const FocusSetupScreen(),
        ),
        GoRoute(
          path: focusActive,
          builder: (context, state) => const FocusActiveScreen(),
        ),
        GoRoute(
          path: focusResult,
          builder: (context, state) => const FocusResultScreen(),
        ),
      ],
    );
  }
}
