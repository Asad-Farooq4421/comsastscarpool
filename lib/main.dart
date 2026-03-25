import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'constants/text_styles.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'utils/routes.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';

void main() {
  runApp(const CampusCarpoolApp());
}

class CampusCarpoolApp extends StatelessWidget {
  const CampusCarpoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Carpool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: AppTextStyles.heading3,
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.emailVerification: (context) => const EmailVerificationScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
      },
    );
  }
}