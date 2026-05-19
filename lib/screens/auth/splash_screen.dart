import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {

    // Splash delay
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    final User? user =
        FirebaseAuth.instance.currentUser;

    // USER ALREADY LOGGED IN
    if (user != null) {

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.main,
      );

    } else {

      // USER NOT LOGGED IN
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.onboarding,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),

        child: Center(

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              Container(
                width: 120,
                height: 120,

                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.directions_car,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Campus Carpool',

                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 48),

              const CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}