import 'package:comsastscarpool/screens/driver/driver_home_screen.dart';
import 'package:comsastscarpool/screens/driver/edit_ride_screen.dart';
import 'package:comsastscarpool/screens/driver/post_ride_screen.dart';
import 'package:comsastscarpool/screens/driver/ride_requests_inbox_screen.dart';
import 'screens/passenger/search_rides_screen.dart';
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
import 'screens/profile/safety_center_screen.dart';
import 'screens/profile/emergency_contacts_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/individual_chat_screen.dart';

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
      initialRoute: AppRoutes.driverHome,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.emailVerification: (context) => const EmailVerificationScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),

        AppRoutes.chatList: (context) => const ChatListScreen(),
        AppRoutes.individualChat: (context) => const IndividualChatScreen(),
        AppRoutes.searchRides: (context) => const SearchScreen(),
        AppRoutes.driverHome: (context) => const DriverHomeScreen(),
        AppRoutes.postRide: (context) => const PostRideScreen(),
        AppRoutes.editRide: (context) => const EditRideScreen(),
        AppRoutes.rideRequests: (context) => const RideRequestsInboxScreen(),

        AppRoutes.safetyCenter: (context) => const SafetyCenterScreen(),
        AppRoutes.emergencyContacts: (context) => const EmergencyContactsScreen(),
      },
    );
  }
}