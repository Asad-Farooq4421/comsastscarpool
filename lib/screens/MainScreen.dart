import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:comsastscarpool/screens/passenger/search_rides_screen.dart';
import 'package:comsastscarpool/screens/profile/profile_screen.dart';
import 'package:comsastscarpool/screens/passenger/my_rides.dart';
import 'package:comsastscarpool/screens/chat/chat_list_screen.dart';
import 'package:comsastscarpool/screens/driver/driver_home_screen.dart';

import '../widgets/app_bottom_nav.dart';
import '../services/ride_service.dart';
import '../services/user_service.dart';
import '../models/ride_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isDriverMode = false;
  bool _isLoading = true;

  final RideService _rideService = RideService();
  final UserService _userService = UserService();

  List<Ride> _userRides = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ================= FIREBASE INITIALIZATION =================
  Future<void> _initializeApp() async {
    if (!mounted) return; // ✅ FIXED: Check if widget is still mounted

    setState(() => _isLoading = true);

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final userProfile = await _userService.getUserProfile(firebaseUser.uid);

    if (!mounted) return; // ✅ FIXED: Check before setState

    _isDriverMode = userProfile?.isDriver ?? false;

    await _loadUserRides();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ================= LOAD RIDES =================
  Future<void> _loadUserRides() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    try {
      List<Ride> rides = [];

      if (_isDriverMode) {
        rides = await _rideService.getRidesByDriverId(firebaseUser.uid);
      } else {
        rides = await _rideService.getRidesByPassengerId(firebaseUser.uid);
      }

      // ✅ FIXED: Check mounted before setState
      if (mounted) {
        setState(() {
          _userRides = rides;
        });
      }
    } catch (e) {
      debugPrint("Error loading rides: $e");
      if (mounted) {
        setState(() {
          _userRides = [];
        });
      }
    }
  }

  // ================= SWITCH TAB =================
  void _onTabTapped(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // ================= REFRESH RIDES =================
  Future<void> _refreshRides() async {
    await _loadUserRides();
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [

          // ================= HOME =================
          _isDriverMode
              ? DriverHomeScreen(
            onSwitch: () {
              if (mounted) {
                setState(() {
                  _isDriverMode = false;
                });
                _loadUserRides();
              }
            },
          )
              : SearchScreen(
            onSwitch: () {
              if (mounted) {
                setState(() {
                  _isDriverMode = true;
                });
                _loadUserRides();
              }
            },
            onNavigateToProfile: () {
              ProfileScreen.shouldSwitchToDriver = true;
              if (mounted) {
                setState(() => _currentIndex = 3);
              }
            },
          ),

          // ================= MY RIDES =================
          MyRidesScreen(
            allRides: _userRides,
            onRideUpdate: _refreshRides,
          ),

          // ================= CHAT =================
          const ChatListScreen(),

          // ================= PROFILE =================
          ProfileScreen(
            onProfileUpdated: () async {
              await _initializeApp();
            },
          ),
        ],
      ),

      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}