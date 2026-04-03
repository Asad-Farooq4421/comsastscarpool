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
              ProfileScreen.shouldSwitchToDriver = true;  // ← SET FLAG
              setState(() => currentIndex = 3);
            },
          ),

          MyRidesScreen(allRides: dummyRides),
          const ChatListScreen(),
          const ProfileScreen(),
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