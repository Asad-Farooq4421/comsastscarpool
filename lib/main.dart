import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:comsastscarpool/screens/MainScreen.dart';

// import 'package:comsastscarpool/screens/driver/driver_home_screen.dart';

import 'package:comsastscarpool/screens/driver/edit_ride_screen.dart';
import 'package:comsastscarpool/screens/driver/post_ride_screen.dart';
import 'package:comsastscarpool/screens/driver/ride_requests_inbox_screen.dart';

// import 'screens/passenger/search_rides_screen.dart';

import 'constants/colors.dart';
import 'constants/text_styles.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';


import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/safety_center_screen.dart';
import 'screens/profile/emergency_contacts_screen.dart';

import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/individual_chat_screen.dart';

import 'utils/routes.dart';

// OPTIONAL (If you used FlutterFire CLI)
import 'firebase_options.dart';

Future<void> main() async {

  // Required before Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Realtime Database Persistence
  // NOT supported on Web
  if (!kIsWeb) {
    FirebaseDatabase.instance
        .setPersistenceEnabled(true);
  }

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

        scaffoldBackgroundColor:
        AppColors.background,

        appBarTheme: AppBarTheme(

          backgroundColor:
          AppColors.surface,

          foregroundColor:
          AppColors.textPrimary,

          elevation: 1,

          centerTitle: true,

          titleTextStyle:
          AppTextStyles.heading3,
        ),
      ),

      initialRoute: AppRoutes.splash,

      routes: {

        AppRoutes.splash: (context) =>
        const SplashScreen(),

        AppRoutes.onboarding: (context) =>
        const OnboardingScreen(),

        AppRoutes.login: (context) =>
        const LoginScreen(),

        AppRoutes.signup: (context) =>
        const SignupScreen(),


        // AppRoutes.profile: (context) =>
        // const ProfileScreen(),

        AppRoutes.settings: (context) =>
        const SettingsScreen(),

        AppRoutes.main: (context) =>
        const MainScreen(),

        AppRoutes.chatList: (context) =>
        const ChatListScreen(),

        // AppRoutes.individualChat:
        //     (context) =>
        // const IndividualChatScreen(),

        AppRoutes.postRide: (context) =>
        const PostRideScreen(),

        AppRoutes.editRide: (context) =>
        const EditRideScreen(),

        AppRoutes.rideRequests:
            (context) =>
        const RideRequestsInboxScreen(),

        AppRoutes.safetyCenter:
            (context) =>
        const SafetyCenterScreen(),

        AppRoutes.emergencyContacts:
            (context) =>
        const EmergencyContactsScreen(),
      },
    );
  }
}