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

  // ================= FIREBASE INITIALIZATION =================
  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final userProfile =
    await _userService.getUserProfile(firebaseUser.uid);

    _isDriverMode = userProfile?.isDriver ?? false;

    await _loadUserRides();

    setState(() => _isLoading = false);
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

      setState(() {
        _userRides = rides;
      });
    } catch (e) {
      debugPrint("Error loading rides: $e");
      setState(() {
        _userRides = [];
      });
    }
  }

  // ================= SWITCH TAB =================
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
              setState(() {
                _isDriverMode = false;
              });
              _loadUserRides();
            },
          )
              : SearchScreen(
            onSwitch: () {
              setState(() {
                _isDriverMode = true;
              });
              _loadUserRides();
            },
            onNavigateToProfile: () {
              ProfileScreen.shouldSwitchToDriver = true;
              setState(() => _currentIndex = 3);
            },
          ),

          // ================= MY RIDES =================
          MyRidesScreen(
            allRides: _userRides,
            onRideUpdate: _loadUserRides,
          ),

          // ================= CHAT =================
          const ChatListScreen(),

          // ================= PROFILE =================
          ProfileScreen(
            onProfileUpdated: () async {
              await _initializeApp(); // refresh Firebase data
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