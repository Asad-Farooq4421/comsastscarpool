import 'package:comsastscarpool/screens/passenger/ride_details_screen.dart';
import 'package:comsastscarpool/screens/passenger/search_rides_screen.dart';
import 'package:comsastscarpool/screens/profile/profile_screen.dart';
import 'package:comsastscarpool/screens/passenger/my_rides.dart';
import 'package:comsastscarpool/screens/driver/my_posted_rides_screen.dart';
import 'package:flutter/material.dart';

import '../data/dummy_rides.dart';
import '../utils/routes.dart';
import '../widgets/app_bottom_nav.dart';
import 'chat/chat_list_screen.dart';
import 'driver/driver_home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  bool isDriverMode = false;

  // ==================== ADD THIS METHOD ====================
  void _refreshDriverStatus() {
    setState(() {
      // Force rebuild to refresh isDriverUser in SearchScreen
      isDriverMode = isDriverMode;
    });
  }
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          isDriverMode
              ? DriverHomeScreen(
            onSwitch: () => setState(() => isDriverMode = false),
          )
              : SearchScreen(
            onSwitch: () => setState(() => isDriverMode = true),
            onNavigateToProfile: () {
              ProfileScreen.shouldSwitchToDriver = true;
              setState(() => currentIndex = 3);
            },
          ),
          MyRidesScreen(allRides: dummyRides),
          const ChatListScreen(),
          // ==================== UPDATE THIS ====================
          ProfileScreen(
            onProfileUpdated: () {
              setState(() {
                isDriverMode = true;
              });
            },
          ),
          // ====================================================
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;

          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}