import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../services/user_service.dart';
import '../../services/ride_service.dart';
import '../../models/ride_model.dart';
import '../../widgets/role_toggle.dart';
import '../../widgets/ride_card.dart';
import 'ride_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onNavigateToProfile;

  const SearchScreen({
    super.key,
    required this.onSwitch,
    required this.onNavigateToProfile,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  UserRole selectedRole = UserRole.passenger;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<Ride> _allRides = [];
  List<Ride> filteredRides = [];
  bool hasSearched = false;
  bool isDriverUser = false;
  bool _hasShownDriverPopup = false;
  bool _isLoading = true;

  final RideService _rideService = RideService();
  final UserService _userService = UserService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRides();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userProfile = await _userService.getUserProfile(currentUser.uid);
      setState(() {
        _currentUserId = currentUser.uid;
        isDriverUser = userProfile?.isDriver ?? false;
      });
    }
  }

  Future<void> _loadRides() async {
    setState(() {
      _isLoading = true;
    });

    final rides = await _rideService.getAvailableRides();

    setState(() {
      _allRides = rides;
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
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
        _hasShownDriverPopup = true;
        widget.onNavigateToProfile();
      }
    });
  }

  void searchRides() {
    final from = fromController.text.toLowerCase().trim();
    final to = toController.text.toLowerCase().trim();
    final date = dateController.text.trim();
    final now = DateTime.now();

    setState(() {
      hasSearched = true;

      filteredRides = _allRides.where((ride) {
        final matchFrom = from.isEmpty || ride.from.toLowerCase().contains(from);
        final matchTo = to.isEmpty || ride.destination.toLowerCase().contains(to);
        final matchDate = date.isEmpty || ride.date == date;
        final hasSeats = ride.availableSeats > 0;
        final notMyRide = _currentUserId == null || ride.driverId != _currentUserId;

        // Parse ride date and time
        DateTime rideDateTime;
        try {
          final rideDate = DateTime.parse(ride.date);
          final timeParts = ride.time.split(' ');
          final hm = timeParts[0].split(':');
          int hour = int.parse(hm[0]);
          int minute = int.parse(hm[1]);

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
          return false;
        }

        final isFutureRide = rideDateTime.isAfter(now);

        return matchFrom && matchTo && matchDate && hasSeats && notMyRide && isFutureRide;
      }).toList();
    });
  }

  // FIXED: Changed to Future<void> for RefreshIndicator
  Future<void> _refreshRides() async {
    await _loadRides();
    if (hasSearched) {
      searchRides();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshRides, // Now this works because it returns Future<void>
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchForm(),
              _buildRideList(),
            ],
          ),
        ),
      ),
    );
  }

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
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: RoleToggle(
              selectedRole: selectedRole,
              onChanged: (role) {
                if (role == UserRole.driver) {
                  if (isDriverUser) {
                    widget.onSwitch();
                  } else {
                    if (!_hasShownDriverPopup) {
                      _showDriverModeDialog();
                    } else {
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
                  dateController.text = pickedDate.toIso8601String().split('T')[0];
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !hasSearched
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
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RideDetailsScreen(ride: ride),
                        ),
                      );
                      if (result == true) {
                        await _refreshRides();
                      }
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