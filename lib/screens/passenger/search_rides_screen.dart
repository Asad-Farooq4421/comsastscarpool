import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/user_model.dart';
import '../../models/ride_model.dart';
import '../../data/dummy_rides.dart';
import '../../widgets/role_toggle.dart';
import '../../widgets/ride_card.dart';
import '../driver/driver_home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  UserRole selectedRole = UserRole.passenger;

  final TextEditingController destinationController =
  TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<Ride> filteredRides = [];
  bool hasSearched = false;

  // 🔍 SEARCH FUNCTION
  void searchRides() {
    final destination = destinationController.text.toLowerCase().trim();
    final date = dateController.text.trim();

    setState(() {
      hasSearched = true;

      filteredRides = dummyRides.where((ride) {
        final matchDestination =
        ride.destination.toLowerCase().contains(destination);

        final matchDate = date.isEmpty || ride.date == date;

        return matchDestination && matchDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchForm(),
            _buildRideList(),
          ],
        ),
      ),
    );
  }

  // 🔵 HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Find a Ride",
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
              Stack(
                children: const [
                  Icon(Icons.notifications, color: Colors.white),
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.red,
                    ),
                  )
                ],
              )
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "Where are we heading?",
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 16),

          // Role Toggle
          RoleToggle(
            selectedRole: selectedRole,
            onChanged: (role) {
              if (role == UserRole.driver) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverHomeScreen(),
                  ),
                );
              } else {
                setState(() {
                  selectedRole = UserRole.passenger;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // 🔍 SEARCH FORM
  Widget _buildSearchForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _inputField(
            controller: destinationController,
            hint: "Where to?",
            icon: Icons.location_on,
          ),
          const SizedBox(height: 10),
          _inputField(
            controller: dateController,
            hint: "When?",
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: searchRides,
            icon: const Icon(Icons.search, color: Colors.white),
            label: Text("Search Rides", style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  // 🧾 INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: AppTextStyles.inputHint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🚗 RIDE LIST (UPDATED)
  Widget _buildRideList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasSearched)
              Text("Available Rides", style: AppTextStyles.heading3),

            const SizedBox(height: 10),

            Expanded(
              child: !hasSearched
                  ? const Center(
                child: Text("Search for rides to see results"),
              )
                  : filteredRides.isEmpty
                  ? const Center(
                child: Text("No rides found"),
              )
                  : ListView.builder(
                itemCount: filteredRides.length,
                itemBuilder: (context, index) {
                  final ride = filteredRides[index];
                  return RideCard(ride);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔻 BOTTOM NAV
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.textHint,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Rides"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}