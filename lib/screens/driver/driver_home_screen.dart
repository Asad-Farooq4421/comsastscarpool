import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../widgets/role_toggle.dart';
import '../../utils/routes.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  UserRole selectedRole = UserRole.driver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Home"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🔘 Toggle Button
          RoleToggle(
            selectedRole: selectedRole,
            onChanged: (role) {
              if (role == UserRole.passenger) {
                // Navigate back to passenger screen
                Navigator.pop(context);
              } else {
                setState(() {
                  selectedRole = UserRole.driver;
                });
              }
            },
          ),

          const SizedBox(height: 30),

          // 🧾 Dummy Content
          const Center(
            child: Text(
              "Welcome Driver 🚗",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.postRide);
        },
        label: const Text('Post a Ride'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
