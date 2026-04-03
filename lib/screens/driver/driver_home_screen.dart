import 'package:flutter/material.dart';
import '../../models/ride_model.dart';
import '../../widgets/role_toggle.dart';
import '../../utils/routes.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../data/dummy_rides.dart';
import '../../data/dummy_users.dart';
import '../../widgets/driver_ride_card.dart';

class DriverHomeScreen extends StatefulWidget {
  final VoidCallback onSwitch;

  const DriverHomeScreen({
    super.key,
    required this.onSwitch,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  UserRole selectedRole = UserRole.driver;

  // ✅ FIXED: Use current logged-in user's email
  List<Ride> get driverRides {
    final currentDriverEmail = getCurrentUserId();
    return getRidesByDriverEmail(currentDriverEmail);
  }

  // ✅ Calculate total earnings
  int get totalEarnings {
    int earnings = 0;
    for (var ride in driverRides) {
      final filledSeats = ride.totalSeats - ride.availableSeats;
      earnings += filledSeats * ride.price;
    }
    return earnings;
  }

  // ✅ Get driver rating from current user
  double get driverRating {
    final currentUser = getCurrentUser();
    return double.parse(currentUser?['driverRating'] ?? '0.0');
  }

  @override
  Widget build(BuildContext context) {
    final rides = driverRides;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Stats
            Container(
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
                            'Driver Dashboard',
                            style: AppTextStyles.heading2.copyWith(color: Colors.white),
                          ),
                          Text(
                            'Manage your rides',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          const Icon(Icons.notifications_none, color: Colors.white, size: 32),
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
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Role Toggle
                  Center(
                    child: RoleToggle(
                      selectedRole: selectedRole,
                      onChanged: (role) {
                        if (role == UserRole.passenger) {
                          widget.onSwitch();
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ✅ Dynamic Stats (based on current user's rides)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(rides.length.toString(), 'Total Rides'),
                      _buildStatItem(driverRating.toString(), 'Rating'),
                      _buildStatItem('Rs. $totalEarnings', 'Earnings'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // My Posted Rides Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Posted Rides',
                        style: AppTextStyles.heading3,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.postRide).then((value) {
                            if (value == true) setState(() {});
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Post Ride'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ride Cards List
                  rides.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.directions_car, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No rides posted yet',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap "Post Ride" to share your first ride',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rides.length,
                    itemBuilder: (context, index) {
                      final ride = rides[index];
                      return DriverRideCard(
                        ride: ride,
                        onViewRequests: () {
                          Navigator.pushNamed(context, AppRoutes.rideRequests, arguments: ride).then((value) {
                            if (value == true) setState(() {});
                          });
                        },
                        onEdit: () {
                          Navigator.pushNamed(context, AppRoutes.editRide, arguments: ride).then((value) {
                            if (value == true) setState(() {});
                          });
                        },
                        onDelete: () {
                          _showDeleteConfirmation(context, ride.rideId);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, String rideId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ride'),
        content: const Text('Are you sure you want to delete this ride? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              deleteRide(rideId);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ride deleted successfully'), backgroundColor: Colors.red),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}