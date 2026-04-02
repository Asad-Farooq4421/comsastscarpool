import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

import '../../data/dummy_users.dart';
import '../../models/ride_model.dart';
import '../../data/dummy_rides.dart';
import '../../widgets/role_toggle.dart';
import '../../widgets/ride_card.dart';


import 'ride_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onSwitch;

  const SearchScreen({
    super.key,
    required this.onSwitch,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  UserRole selectedRole = UserRole.passenger;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<Ride> filteredRides = [];
  bool hasSearched = false;
  bool isDriverUser = false;

  @override
  void initState() {
    super.initState();
    isDriverUser = isCurrentUserDriver();
  }
  //SEARCH FUNCTION
  void searchRides() {
    final from = fromController.text.toLowerCase().trim();
    final to = toController.text.toLowerCase().trim();
    final date = dateController.text.trim();

    setState(() {
      hasSearched = true;

      filteredRides = dummyRides.where((ride) {
        final matchFrom =
            from.isEmpty || ride.from.toLowerCase().contains(from);

        final matchTo =
            to.isEmpty || ride.destination.toLowerCase().contains(to);

        final matchDate = date.isEmpty || ride.date == date;

        final hasSeats = (ride.availableSeats) > 0;

        return matchFrom && matchTo && matchDate && hasSeats;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

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

  // HEADER
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
            "Search by route and date",
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 16),

          // Role Toggle
          RoleToggle(
            selectedRole: selectedRole,
            isDriverEnabled: isDriverUser, // 👈 ADD THIS
            onChanged: (role) {
              if (role == UserRole.driver) {
                if (isDriverUser) {
                  widget.onSwitch();
                }
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

  // SEARCH FORM
  Widget _buildSearchForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _inputField(
            controller: fromController,
            hint: "From",
            icon: Icons.circle,
          ),
          const SizedBox(height: 10),

          _inputField(
            controller: toController,
            hint: "To",
            icon: Icons.location_on,
          ),
          const SizedBox(height: 10),

          // DATE
          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                setState(() {
                  dateController.text =
                  pickedDate.toIso8601String().split('T')[0];
                });
              }
            },
            child: AbsorbPointer(
              child: _inputField(
                controller: dateController,
                hint: "Select Date",
                icon: Icons.calendar_today,
              ),
            ),
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

  // INPUT FIELD
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

  // RIDE LIST
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

                  return RideCard(
                    ride: ride,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RideDetailsScreen(ride: ride),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}