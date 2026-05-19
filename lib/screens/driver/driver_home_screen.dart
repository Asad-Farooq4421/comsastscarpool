import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/ride_model.dart';
import '../../widgets/role_toggle.dart';
import '../../utils/routes.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../services/ride_service.dart';
import '../../services/user_service.dart';
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

  final RideService _rideService = RideService();
  final UserService _userService = UserService();

  List<Ride> _driverRides = [];
  bool _isLoading = true;
  String? _currentUserId;
  double _driverRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid;
      });
      await _loadDriverData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDriverData() async {
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Load user profile for rating
      final userProfile = await _userService.getUserProfile(_currentUserId!);
      setState(() {
        _driverRating = userProfile?.driverRating ?? 0.0;
      });

      // Load driver's rides
      await _loadDriverRides();
    } catch (e) {
      print('Error loading driver data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDriverRides() async {
    if (_currentUserId == null) return;

    try {
      final rides = await _rideService.getRidesByDriverId(_currentUserId!);
      setState(() {
        _driverRides = rides;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading driver rides: $e');
      setState(() {
        _driverRides = [];
        _isLoading = false;
      });
    }
  }

  // Calculate total earnings
  int get totalEarnings {
    int earnings = 0;
    for (var ride in _driverRides) {
      final filledSeats = ride.totalSeats - ride.availableSeats;
      earnings += filledSeats * ride.price;
    }
    return earnings;
  }

  Future<void> _deleteRide(String rideId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _rideService.deleteRide(rideId);
      await _loadDriverRides();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation(String rideId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ride'),
        content: const Text('Are you sure you want to delete this ride? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRide(rideId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadDriverRides,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                        // Notification bell removed - can be added later
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

                    // Dynamic Stats (based on current user's rides)
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(_driverRides.length.toString(), 'Total Rides'),
                          _buildStatItem(_driverRating.toStringAsFixed(1), 'Rating'),
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
                            Navigator.pushNamed(context, AppRoutes.postRide).then((_) {
                              _loadDriverRides();
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
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_driverRides.isEmpty)
                      Center(
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
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _driverRides.length,
                        itemBuilder: (context, index) {
                          final ride = _driverRides[index];
                          return DriverRideCard(
                            ride: ride,
                            onViewRequests: () {
                              Navigator.pushNamed(context, AppRoutes.rideRequests, arguments: ride).then((_) {
                                _loadDriverRides();
                              });
                            },
                            onEdit: () {
                              Navigator.pushNamed(context, AppRoutes.editRide, arguments: ride).then((_) {
                                _loadDriverRides();
                              });
                            },
                            onDelete: () {
                              _showDeleteConfirmation(ride.rideId);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
}