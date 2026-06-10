  import 'package:comsastscarpool/services/gemini_service.dart';
import 'package:comsastscarpool/services/google_place_service.dart';
  import 'package:flutter/material.dart';

  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/foundation.dart';

  import 'package:firebase_database/firebase_database.dart';
  import 'package:firebase_analytics/firebase_analytics.dart';
  import 'package:firebase_analytics/observer.dart';

  import 'package:comsastscarpool/screens/MainScreen.dart';

  import 'package:comsastscarpool/screens/driver/edit_ride_screen.dart';
  import 'package:comsastscarpool/screens/driver/post_ride_screen.dart';
  import 'package:comsastscarpool/screens/driver/ride_requests_inbox_screen.dart';

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
  import 'firebase_options.dart';

  Future<void> main() async {
    // Required before Firebase initialization
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase Initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Google Places Service
    GooglePlacesService.initialize('API');
    print('Google Places Service initialized with API key');

    GeminiService().initialize('API');
    // Realtime Database Persistence (NOT supported on Web)
    if (!kIsWeb) {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }

    runApp(const CampusCarpoolApp());
  }

  class CampusCarpoolApp extends StatelessWidget {
    const CampusCarpoolApp({super.key});

    // Firebase Analytics
    static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Campus Carpool',
        debugShowCheckedModeBanner: false,

        // Analytics Observer for auto screen tracking
        navigatorObservers: [observer],

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
          AppRoutes.profile: (context) => const ProfileScreen(),
          AppRoutes.settings: (context) => const SettingsScreen(),
          AppRoutes.main: (context) => const MainScreen(),
          AppRoutes.chatList: (context) => const ChatListScreen(),
         // AppRoutes.individualChat: (context) => const IndividualChatScreen(),
          AppRoutes.postRide: (context) => const PostRideScreen(),
          AppRoutes.editRide: (context) => const EditRideScreen(),
          AppRoutes.rideRequests: (context) => const RideRequestsInboxScreen(),
          AppRoutes.safetyCenter: (context) => const SafetyCenterScreen(),
          AppRoutes.emergencyContacts: (context) => const EmergencyContactsScreen(),
        },
      );
    }
  }
