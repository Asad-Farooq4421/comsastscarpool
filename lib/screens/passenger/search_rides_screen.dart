import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

import '../../data/dummy_users.dart';
import '../../data/ride_requests.dart';
import '../../models/ride_model.dart';
import '../../data/dummy_rides.dart';
import '../../widgets/role_toggle.dart';
import '../../widgets/ride_card.dart';

import 'ride_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onNavigateToProfile;  // ← ADD THIS

  const SearchScreen({
    super.key,
    required this.onSwitch,
    required this.onNavigateToProfile,  // ← ADD THIS
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
  bool _hasShownDriverPopup = false;

  @override
  void initState() {
    super.initState();
    isDriverUser = isCurrentUserDriver();
    print('🔍 initState - isDriverUser: $isDriverUser');
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user status when returning to this screen (after profile update)
    isDriverUser = isCurrentUserDriver();
    print('didChangeDependencies - isDriverUser: $isDriverUser');
  }
  void _showDriverModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.directions_car, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Become a Driver?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To start offering rides as a driver, you need to provide:'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Vehicle type (Car/Bike)'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Vehicle model'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Color & License plate'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Number of seats'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'You can edit these details anytime from your profile.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Yes, Continue'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        // ✅ ONLY set to true when user clicks "Yes, Continue"
        _hasShownDriverPopup = true;
        // ✅ Navigate to profile via callback instead of direct navigation
        widget.onNavigateToProfile();
      }
      // If user clicks "Not Now", _hasShownDriverPopup remains false
    });
  }

  //SEARCH FUNCTION
  void searchRides() {
    final from = fromController.text.toLowerCase().trim();
    final to = toController.text.toLowerCase().trim();
    final date = dateController.text.trim();

    final currentUserId = getCurrentUserId();

    final now = DateTime.now();

    setState(() {
      hasSearched = true;

      filteredRides = dummyRides.where((ride) {
        final matchFrom =
            from.isEmpty || ride.from.toLowerCase().contains(from);

        final matchTo =
            to.isEmpty || ride.destination.toLowerCase().contains(to);

        final matchDate = date.isEmpty || ride.date == date;

        final hasSeats = ride.availableSeats > 0;

        final notMyRide = ride.driverId != currentUserId;

        // ✅ NEW: Convert ride date + time into DateTime
        DateTime rideDateTime;

        try {
          final rideDate = DateTime.parse(ride.date);

          final timeParts = ride.time.split(' ');
          final hm = timeParts[0].split(':');

          int hour = int.parse(hm[0]);
          int minute = int.parse(hm[1]);

          // Handle AM/PM
          if (timeParts[1] == "PM" && hour != 12) {
            hour += 12;
          } else if (timeParts[1] == "AM" && hour == 12) {
            hour = 0;
          }

          rideDateTime = DateTime(
            rideDate.year,
            rideDate.month,
            rideDate.day,
            hour,
            minute,
          );
        } catch (e) {
          // If parsing fails, exclude ride
          return false;
        }

        // ✅ Only future rides
        final isFutureRide = rideDateTime.isAfter(now);

        return matchFrom &&
            matchTo &&
            matchDate &&
            hasSeats &&
            notMyRide &&
            isFutureRide;
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
  // HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row (Title + Notification)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passenger Dashboard',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Find and book rides',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              Stack(
                children: [
                  const Icon(Icons.notifications_none,
                      color: Colors.white, size: 32),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Role Toggle (Centered) - ✅ FIXED LOGIC
          Center(
            child: RoleToggle(
              selectedRole: selectedRole,
              onChanged: (role) {
                if (role == UserRole.driver) {
                  // ✅ Check if user is already a driver
                  if (isDriverUser) {
                    // Already a driver - go to driver home
                    widget.onSwitch();
                  } else {
                    // Not a driver yet - check if popup already shown
                    if (!_hasShownDriverPopup) {
                      _showDriverModeDialog();
                    } else {
                      // Popup already shown before, just go to profile
                      widget.onNavigateToProfile();
                    }
                  }
                } else {
                  setState(() {
                    selectedRole = UserRole.passenger;
                  });
                }
              },
            ),
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