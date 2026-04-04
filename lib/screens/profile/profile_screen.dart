import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../data/dummy_users.dart';
import '../passenger/my_requests_screen.dart';
import '../driver/my_posted_rides_screen.dart';
class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;  // ADD THIS LINE

  const ProfileScreen({
    Key? key,
    this.onProfileUpdated,  // ADD THIS LINE
  }) : super(key: key);


  static bool shouldSwitchToDriver = false;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _user = {}; // Initialize as empty map, not nullable
  bool _isEditing = false;
  bool _isDriver = false;
  bool _isDriverModeSelected = false;
  bool _pendingDriverSwitch = false;
  bool _hasShownDriverPopup = false;

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
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    // Get the currently logged-in user (by index)
    final currentUser = getCurrentUser();

    if (currentUser != null) {
      _user = Map.from(currentUser);
      _nameController.text = _user['name'] ?? '';
      _phoneController.text = _user['phone'] ?? '';
      _bioController.text = _user['bio'] ?? '';
      _vehicleTypeController.text = _user['vehicleType'] ?? '';
      _vehicleModelController.text = _user['vehicleModel'] ?? '';
      _vehicleColorController.text = _user['vehicleColor'] ?? '';
      _vehiclePlateController.text = _user['vehiclePlate'] ?? '';
      _vehicleSeatsController.text = _user['vehicleSeats'] ?? '';
      _isDriver = _user['isDriver'] ?? false;
      setState(() {});
    } else {
      // No user logged in - redirect to login
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
    }
  }

// ==================== ADD THIS METHOD HERE ====================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if we need to switch to driver mode (coming from Search Screen)
    if (ProfileScreen.shouldSwitchToDriver && !_isDriver) {
      ProfileScreen.shouldSwitchToDriver = false;  // Reset flag

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isDriverModeSelected = true;  // Show Driver UI
          _isEditing = true;              // Open edit mode to fill vehicle details
          _hasShownDriverPopup = true;    // Mark popup as shown
          // _isDriver remains false until validation passes on save
        });

        // Scroll to vehicle details section
        Future.delayed(const Duration(milliseconds: 300), () {
          Scrollable.ensureVisible(
            _vehicleDetailsKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add your vehicle details to become a driver'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
    // Check if we should open edit mode (coming from other places)
    else {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == 'openEditMode' && !_isEditing && !_isDriver) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _isEditing = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add your vehicle details to become a driver'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        });
      }
    }
  }
// =============================================================

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
        setState(() {
          _isEditing = true;
          _isDriverModeSelected = true;// Open edit mode to fill vehicle details
        });
      }
      // If user clicks "Not Now", _hasShownDriverPopup remains false
    });
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
    super.dispose();
  }

  Widget _buildModeSwitch() {
    final currentUser = getCurrentUser();
    final isAlreadyDriver = currentUser?['isDriver'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Passenger Mode
          GestureDetector(
            onTap: () {
              // Switching to Passenger mode
              if (_isDriverModeSelected) {
                setState(() {
                  _isDriverModeSelected = false;
                  // If not actually a driver in database, reset _isDriver as well
                  if (!isAlreadyDriver) {
                    _isDriver = false;
                  }
                  _isEditing = false;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: !_isDriverModeSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 18,
                    color: !_isDriverModeSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Passenger',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: !_isDriverModeSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: !_isDriverModeSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Driver Mode
          GestureDetector(
            onTap: () {
              // Switching to Driver mode
              if (!_isDriverModeSelected) {
                if (isAlreadyDriver) {
                  // Already a driver in database - switch directly
                  setState(() {
                    _isDriverModeSelected = true;
                    _isDriver = true;
                  });
                } else {
                  // Not a driver yet - check if popup already shown
                  if (!_hasShownDriverPopup) {
                    _showDriverModeDialog();
                  } else {
                    // Popup already shown, just switch to Driver UI
                    setState(() {
                      _isDriverModeSelected = true;
                      _isEditing = true;
                      // _isDriver remains false until validation passes on save
                    });
                  }
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _isDriverModeSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 18,
                    color: _isDriverModeSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Driver',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _isDriverModeSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: _isDriverModeSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    // If trying to become driver (Driver UI selected but not actually driver yet)
    if (_isDriverModeSelected && !_isDriver) {
      // Validate all vehicle fields
      if (_vehicleTypeController.text.trim().isEmpty ||
          _vehicleModelController.text.trim().isEmpty ||
          _vehicleColorController.text.trim().isEmpty ||
          _vehiclePlateController.text.trim().isEmpty ||
          _vehicleSeatsController.text.trim().isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all vehicle details to become a driver'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      int seats = int.tryParse(_vehicleSeatsController.text) ?? 0;
      if (seats < 1 || seats > 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Number of seats must be between 1 and 4'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // ✅ Validation passed - now actually become driver
      setState(() {
        _isDriver = true;
      });
      widget.onProfileUpdated?.call();
    }

    // Save to database
    setState(() {
      _user['name'] = _nameController.text;
      _user['phone'] = _phoneController.text;
      _user['bio'] = _bioController.text;
      _user['isDriver'] = _isDriver;

      if (_isDriver) {
        _user['vehicleType'] = _vehicleTypeController.text;
        _user['vehicleModel'] = _vehicleModelController.text;
        _user['vehicleColor'] = _vehicleColorController.text;
        _user['vehiclePlate'] = _vehiclePlateController.text;
        _user['vehicleSeats'] = _vehicleSeatsController.text;
      }

      _isEditing = false;
    });

    updateCurrentUser(_user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear the current user tracking
              clearCurrentUser();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is empty (loading state)
    if (_user.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Photo upload coming soon'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 30,
                                minHeight: 30,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing)
                    Text(
                      _user['name'] ?? 'Student Name',
                      style: AppTextStyles.heading2,
                    ),
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Student',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        _user['email'] ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildModeSwitch(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ==================== CHANGED: Use _isDriverModeSelected ====================
            if (!_isDriverModeSelected) ...[
              _buildPassengerStats(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  text: 'My Requests',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyRequestsScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
            if (_isDriverModeSelected) _buildDriverStats(),
            const SizedBox(height: 16),
            if (_isDriverModeSelected) _buildVehicleDetails(),
            // =========================================================================
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              child: Padding(
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
                            title: const Text('Phone Number'),
                            subtitle: Text(
                              _user['phone']?.isNotEmpty == true
                                  ? _user['phone']
                                  : 'Not added',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('Bio'),
                            subtitle: Text(
                              _user['bio']?.isNotEmpty == true
                                  ? _user['bio']
                                  : 'No bio added',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    if (_isEditing)
                      Column(
                        children: [
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '+92 300 1234567',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _bioController,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              hintText: 'Tell us about yourself',
                              prefixIcon: Icon(Icons.info_outline),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              child: Padding(
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
                              isOutlined: true,
                            ),
                          ),
                          const SizedBox(width: 16),
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
                      isOutlined: true,
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStats() {
    return Container(
      color: Colors.white,
      child: Padding(
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
                _buildStatCard('Rides Given', _user['ridesAsDriver']?.toString() ?? '0', Icons.directions_car),
                const SizedBox(width: 16),
                _buildStatCard('Driver Rating', _user['driverRating']?.toString() ?? '0.0', Icons.star),
                const SizedBox(width: 16),
                _buildStatCard('Earnings', '₨${_user['earnings'] ?? '0'}', Icons.money),
              ],
            ),
            const SizedBox(height: 16),
            // My Posted Rides Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.directions_car, color: AppColors.primary),
                title: const Text('My Posted Rides'),
                subtitle: const Text('View and manage your rides'),
                trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyPostedRidesScreen()),
                    );
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerStats() {
    return Container(
      color: Colors.white,
      child: Padding(
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
                _buildStatCard('Rides Taken', _user['ridesAsPassenger']?.toString() ?? '0', Icons.person),
                const SizedBox(width: 16),
                _buildStatCard('Passenger Rating', _user['passengerRating']?.toString() ?? '0.0', Icons.star),
                const SizedBox(width: 16),
                _buildStatCard('Saved Routes', _user['savedRoutes']?.toString() ?? '0', Icons.bookmark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetails() {
    return Container(
      key: _vehicleDetailsKey,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Details',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            if (!_isEditing)
              Column(
                children: [
                  _buildInfoRow(Icons.directions_car, 'Vehicle Type', _user['vehicleType'] ?? 'Not added'),
                  _buildInfoRow(Icons.model_training, 'Model', _user['vehicleModel'] ?? 'Not added'),
                  _buildInfoRow(Icons.color_lens, 'Color', _user['vehicleColor'] ?? 'Not added'),
                  _buildInfoRow(Icons.confirmation_number, 'License Plate', _user['vehiclePlate'] ?? 'Not added'),
                  _buildInfoRow(Icons.chair, 'Seats', _user['vehicleSeats'] ?? 'Not added'),
                ],
              )
            else
              Column(
                children: [
                  TextField(
                    controller: _vehicleTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Type (Car/Bike)',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _vehicleModelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      prefixIcon: Icon(Icons.model_training),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _vehicleColorController,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      prefixIcon: Icon(Icons.color_lens),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _vehiclePlateController,
                    decoration: const InputDecoration(
                      labelText: 'License Plate',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _vehicleSeatsController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Seats (1-4)',
                      prefixIcon: Icon(Icons.chair),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
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

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}