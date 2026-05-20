import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';

import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../services/ride_service.dart';

import '../../models/user_model.dart';
import '../../models/ride_model.dart';

import '../passenger/my_requests_screen.dart';
import '../driver/my_posted_rides_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({
    Key? key,
    this.onProfileUpdated,
  }) : super(key: key);

  static bool shouldSwitchToDriver = false;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final RideService _rideService = RideService();

  AppUser? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isDriverModeSelected = false;
  bool _hasShownDriverPopup = false;
  int _selectedInnerTab = 0; // 0=Stats, 1=Analytics

  // Analytics data
  List<Ride> _userRides = [];
  bool _isLoadingAnalytics = false;

  // CONTROLLERS
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _vehicleSeatsController = TextEditingController();
  final _scrollController = ScrollController();
  final _vehicleDetailsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView('profile_screen');
    });
  }

  // LOAD USER
  Future<void> _loadUserProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      final user = await _userService.getUserProfile(firebaseUser.uid);

      if (!mounted) return;

      if (user != null) {
        _user = user;
        _populateControllers();
        _isDriverModeSelected = user.isDriver;
        await _loadUserRides();
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // LOAD USER'S RIDES FOR ANALYTICS
  Future<void> _loadUserRides() async {
    if (_user == null) return;

    setState(() {
      _isLoadingAnalytics = true;
    });

    try {
      final String userId = _user!.uid;
      List<Ride> rides = [];

      if (_user!.isDriver) {
        rides = await _rideService.getRidesByDriverId(userId);
      } else {
        rides = await _rideService.getRidesByPassengerId(userId);
      }

      setState(() {
        _userRides = rides;
        _isLoadingAnalytics = false;
      });
    } catch (e) {
      print('Error loading rides: $e');
      setState(() {
        _isLoadingAnalytics = false;
      });
    }
  }

  // POPULATE CONTROLLERS
  void _populateControllers() {
    if (_user == null) return;

    _nameController.text = _user!.name;
    _phoneController.text = _user?.phone ?? '';
    _bioController.text = _user?.bio ?? '';
    _vehicleTypeController.text = _user!.vehicleType;
    _vehicleModelController.text = _user!.vehicleModel;
    _vehicleColorController.text = _user!.vehicleColor;
    _vehiclePlateController.text = _user!.vehiclePlate;
    _vehicleSeatsController.text = _user!.vehicleSeats.toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('🔍 didChangeDependencies called');
    print('🔍 shouldSwitchToDriver: ${ProfileScreen.shouldSwitchToDriver}');
    print('🔍 _user is null? ${_user == null}');
    print('🔍 _user?.isDriver: ${_user?.isDriver}');
    print('🔍 _isDriverModeSelected: $_isDriverModeSelected');

    // Check if we need to switch to driver mode (coming from Search Screen)
    if (ProfileScreen.shouldSwitchToDriver && _user != null && !_user!.isDriver) {
      print('✅ CONDITION MATCHED - Switching to Driver mode');
      ProfileScreen.shouldSwitchToDriver = false;

      // Add a small delay to ensure everything is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isDriverModeSelected = true;
            _isEditing = true;
            _hasShownDriverPopup = true;
            _selectedInnerTab = 0; // Reset to Stats tab
          });
          print('✅ State updated - _isDriverModeSelected: $_isDriverModeSelected');
          print('✅ State updated - _isEditing: $_isEditing');
        }

        // Scroll to vehicle details section
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_vehicleDetailsKey.currentContext != null && mounted) {
            Scrollable.ensureVisible(
              _vehicleDetailsKey.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add your vehicle details to become a driver'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    } else {
      // Check for regular openEditMode argument (from other places)
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == 'openEditMode' && !_isEditing && !_isDriverModeSelected) {
        print('✅ openEditMode matched - Opening edit mode');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isEditing = true;
            });
          }
        });
      }
    }
  }

  // DRIVER DIALOG
  void _showDriverModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.directions_car, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Become Driver?'),
          ],
        ),
        content: const Text(
          'Please add your vehicle details to continue as a driver.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _hasShownDriverPopup = true;
          _isEditing = true;
          _isDriverModeSelected = true;
        });
      }
    });
  }

  // TOGGLE EDIT
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _populateControllers();
      }
    });
  }

  // SAVE PROFILE
  Future<void> _saveProfile() async {
    if (_user == null) return;

    // DRIVER VALIDATION
    if (_isDriverModeSelected && !_user!.isDriver) {
      if (_vehicleTypeController.text.trim().isEmpty ||
          _vehicleModelController.text.trim().isEmpty ||
          _vehicleColorController.text.trim().isEmpty ||
          _vehiclePlateController.text.trim().isEmpty ||
          _vehicleSeatsController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fill all vehicle details'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    final seats = int.tryParse(_vehicleSeatsController.text.trim()) ?? 0;

    if (_isDriverModeSelected && (seats < 1 || seats > 4)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seats must be 1-4'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> updates = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        'isDriver': _isDriverModeSelected,
        'vehicleType': _vehicleTypeController.text.trim(),
        'vehicleModel': _vehicleModelController.text.trim(),
        'vehicleColor': _vehicleColorController.text.trim(),
        'vehiclePlate': _vehiclePlateController.text.trim(),
        'vehicleSeats': seats,
      };

      await _userService.updateUserProfile(
        uid: _user!.uid,
        updates: updates,
      );

      await AnalyticsService.logProfileUpdate();

      if (_isDriverModeSelected && !_user!.isDriver) {
        await AnalyticsService.logRoleSwitch('became_driver');
      }

      await _loadUserProfile();
      await _loadUserRides();

      setState(() {
        _isEditing = false;
      });

      widget.onProfileUpdated?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // LOGOUT
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AnalyticsService.logLogout();
      await _authService.signOut();

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _vehicleTypeController.dispose();
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    _vehiclePlateController.dispose();
    _vehicleSeatsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // HEADER
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing)
                    Text(
                      _user!.name,
                      style: AppTextStyles.heading2,
                    ),
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    _user!.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildModeSwitch(),
                  const SizedBox(height: 20),
                  _buildInnerTabBar(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TAB CONTENT
            if (_selectedInnerTab == 0) ...[
              if (_isDriverModeSelected) _buildDriverStats(),
              if (!_isDriverModeSelected) _buildPassengerStats(),
              const SizedBox(height: 16),
            ],

            if (_selectedInnerTab == 1) ...[
              _buildAnalyticsTab(),
              const SizedBox(height: 16),
            ],

            // VEHICLE DETAILS (only in Driver mode)
            if (_isDriverModeSelected) _buildVehicleDetails(),
            const SizedBox(height: 16),

            // CONTACT INFO
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing)
                    Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Phone'),
                          subtitle: Text(_user!.phone ?? 'Not added'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Bio'),
                          subtitle: Text(_user!.bio ?? 'No bio'),
                        ),
                      ],
                    ),
                  if (_isEditing)
                    Column(
                      children: [
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bioController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Bio',
                            prefixIcon: Icon(Icons.info_outline),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // BUTTONS
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            onPressed: _toggleEdit,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Save',
                            onPressed: _saveProfile,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Settings',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                    backgroundColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Logout',
                    onPressed: _logout,
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // MODE SWITCH (PASSENGER/DRIVER TOGGLE)
  Widget _buildModeSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildModeButton(
            title: 'Passenger',
            icon: Icons.person,
            selected: !_isDriverModeSelected,
            onTap: () {
              setState(() {
                _isDriverModeSelected = false;
                _selectedInnerTab = 0;
              });
              AnalyticsService.logRoleSwitch('passenger');
            },
          ),
          _buildModeButton(
            title: 'Driver',
            icon: Icons.directions_car,
            selected: _isDriverModeSelected,
            onTap: () {
              if (_user!.isDriver) {
                setState(() {
                  _isDriverModeSelected = true;
                  _selectedInnerTab = 0;
                });
                AnalyticsService.logRoleSwitch('driver');
              } else {
                _showDriverModeDialog();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INNER TAB BAR (STATS | ANALYTICS)
  Widget _buildInnerTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildInnerTabButton(
            title: 'Stats',
            isSelected: _selectedInnerTab == 0,
            onTap: () {
              setState(() {
                _selectedInnerTab = 0;
              });
            },
          ),
          _buildInnerTabButton(
            title: 'Analytics',
            isSelected: _selectedInnerTab == 1,
            onTap: () {
              setState(() {
                _selectedInnerTab = 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInnerTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==================== ANALYTICS TAB ====================

  Widget _buildAnalyticsTab() {
    if (_isLoadingAnalytics) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your ride history...'),
            ],
          ),
        ),
      );
    }

    if (_isDriverModeSelected) {
      return _buildDriverAnalytics();
    } else {
      return _buildPassengerAnalytics();
    }
  }

  // Driver Analytics
  Widget _buildDriverAnalytics() {
    final int totalRides = _user!.ridesAsDriver;
    final double avgRating = _user!.driverRating;
    final int totalEarnings = _user!.earnings;
    final int acceptedRequests = _userRides.where((r) => r.status == 'active' || r.status == 'completed').length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'Driver Analytics',
                style: AppTextStyles.heading2,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildAnalyticsCard('Total Rides', totalRides.toString(), Icons.directions_car),
              const SizedBox(width: 12),
              _buildAnalyticsCard('Rating', avgRating.toStringAsFixed(1), Icons.star),
              const SizedBox(width: 12),
              _buildAnalyticsCard('Earnings', '₨$totalEarnings', Icons.money),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAnalyticsCard('Accepted', acceptedRequests.toString(), Icons.check_circle),
              const SizedBox(width: 12),
              _buildAnalyticsCard('Pending', (_userRides.where((r) => r.status == 'scheduled').length).toString(), Icons.pending),
              const SizedBox(width: 12),
              _buildAnalyticsCard('Completed', (_userRides.where((r) => r.status == 'completed').length).toString(), Icons.done_all),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Ride Trends',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildRideTrendsChart(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Driver Tips',
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Higher ratings lead to more ride requests\n• Keep your vehicle clean and on time\n• Respond to requests quickly\n• Complete rides to increase earnings',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Passenger Analytics
  Widget _buildPassengerAnalytics() {
    final int totalRides = _user!.ridesAsPassenger;
    final double avgRating = _user!.passengerRating;
    final int savedRoutes = _user!.savedRoutes;
    final int completedRides = _userRides.where((r) => r.status == 'completed').length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'Passenger Analytics',
                style: AppTextStyles.heading2,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildAnalyticsCard('Total Rides', totalRides.toString(), Icons.person),
              const SizedBox(width: 12),
              _buildAnalyticsCard('Rating', avgRating.toStringAsFixed(1), Icons.star),
              const SizedBox(width: 12),
              _buildAnalyticsCard('Saved Routes', savedRoutes.toString(), Icons.bookmark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAnalyticsCard('Completed', completedRides.toString(), Icons.done_all),
              const SizedBox(width: 12),
              _buildAnalyticsCard('Upcoming', (_userRides.where((r) => r.status == 'scheduled' && r.availableSeats > 0).length).toString(), Icons.schedule),
              const SizedBox(width: 12),
              _buildAnalyticsCard('Money Saved', '₨${totalRides * 150}', Icons.savings),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Ride Activity',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildRideTrendsChart(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Passenger Tips',
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Book rides in advance for better prices\n• Be on time at the pickup location\n• Rate drivers after each ride\n• Save frequent routes for quick booking',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Chart for ride trends
  Widget _buildRideTrendsChart() {
    final List<FlSpot> spots = [
      const FlSpot(0, 2),
      const FlSpot(1, 4),
      const FlSpot(2, 3),
      const FlSpot(3, 7),
      const FlSpot(4, 5),
      const FlSpot(5, 8),
      const FlSpot(6, 6),
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                if (value.toInt() >= 0 && value.toInt() < weekdays.length) {
                  return Text(weekdays[value.toInt()]);
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  // DRIVER STATS
  Widget _buildDriverStats() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver Stats',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Rides',
                _user!.ridesAsDriver.toString(),
                Icons.directions_car,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Rating',
                _user!.driverRating.toString(),
                Icons.star,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Earnings',
                '₨${_user!.earnings}',
                Icons.money,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'My Posted Rides',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyPostedRidesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // PASSENGER STATS
  Widget _buildPassengerStats() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passenger Stats',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Rides',
                _user!.ridesAsPassenger.toString(),
                Icons.person,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Rating',
                _user!.passengerRating.toString(),
                Icons.star,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Routes',
                _user!.savedRoutes.toString(),
                Icons.bookmark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'My Requests',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyRequestsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // VEHICLE DETAILS
  Widget _buildVehicleDetails() {
    return Container(
      key: _vehicleDetailsKey,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Details',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            controller: _vehicleTypeController,
            label: 'Vehicle Type',
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: _vehicleModelController,
            label: 'Vehicle Model',
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: _vehicleColorController,
            label: 'Vehicle Color',
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: _vehiclePlateController,
            label: 'License Plate',
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: _vehicleSeatsController,
            label: 'Seats',
            keyboard: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
  }) {
    if (!_isEditing) {
      return _buildInfoRow(
        label,
        controller.text.isEmpty ? 'Not added' : controller.text,
      );
    }

    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  // INFO ROW
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  // STAT CARD
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}