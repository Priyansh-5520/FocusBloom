import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'constants/app_constants.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'repositories/user_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/user_data_provider.dart';
import 'providers/focus_timer_provider.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main/main_scaffold.dart';
import 'screens/focus/focus_setup_screen.dart';
import 'screens/focus/focus_active_screen.dart';
import 'screens/focus/focus_result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Safe Firebase Initialization
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  final authService = AuthService();
  final userRepository = UserRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => UserDataProvider(userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => FocusTimerProvider(userRepository),
        ),
      ],
      child: const FocusBloomApp(),
    ),
  );
}

class FocusBloomApp extends StatelessWidget {
  const FocusBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const MainScaffold(),
        '/focus': (context) => const FocusSetupScreen(),
        '/focus/active': (context) => const FocusActiveScreen(),
        '/focus/result': (context) => const FocusResultScreen(),
      },
    );
  }
}
