import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/ride_model.dart';
import '../../widgets/custom_button.dart';
import '../../utils/routes.dart';
import '../../services/emergency_contact_service.dart';
import '../../services/user_service.dart';
import '../../services/ride_service.dart';

class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  final EmergencyContactService _contactService = EmergencyContactService();
  final UserService _userService = UserService();
  final RideService _rideService = RideService();

  bool _isSOSActivating = false;
  bool _hasActiveRide = false;
  String? _currentRideId;

  final List<String> safetyTips = const [
    'Always verify the driver and vehicle before getting in',
    'Share your trip details with friends or family',
    'Trust your instincts - if something feels wrong, don\'t hesitate to cancel',
    'Keep your phone charged and accessible',
    'Rate and review your experiences honestly',
  ];

  @override
  void initState() {
    super.initState();
    _checkActiveRide();
  }

  Future<void> _checkActiveRide() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final passengerRides = await _rideService.getRidesByPassengerId(currentUser.uid);

      // Method 1: Using a simple loop (most readable)
      Ride? activeRide;
      for (var ride in passengerRides) {
        if (ride.isActive) {
          activeRide = ride;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _hasActiveRide = activeRide != null;
          _currentRideId = activeRide?.rideId;
        });
      }
    } catch (e) {
      print('Error checking active ride: $e');
      if (mounted) {
        setState(() {
          _hasActiveRide = false;
          _currentRideId = null;
        });
      }
    }
  }

  Future<void> _activateSOS() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showError('User not logged in');
      return;
    }

    // Check if user has emergency contacts
    final hasContacts = await _contactService.hasEmergencyContacts();
    if (!hasContacts) {
      _showError('Please add emergency contacts first');
      return;
    }

    setState(() {
      _isSOSActivating = true;
    });

    try {
      final userProfile = await _userService.getUserProfile(currentUser.uid);

      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // Get current ride details if available
      String rideFrom = 'Unknown';
      String rideTo = 'Unknown';

      if (_hasActiveRide && _currentRideId != null) {
        final ride = await _rideService.getRideById(_currentRideId!);
        if (ride != null) {
          rideFrom = ride.from;
          rideTo = ride.destination;
        }
      }

      // Send SOS to all emergency contacts
      await _contactService.sendSOS(
        userName: userProfile.name,
        userPhone: userProfile.phone ?? 'Not provided',
        rideFrom: rideFrom,
        rideTo: rideTo,
        currentLocation: 'Location will be shared', // You can add GPS here
      );

      // Show success message
      _showSuccess('SOS Activated! Your emergency contacts have been notified.');

      // Navigate to emergency info screen or show detailed info
      _showSOSSuccessDialog();

    } catch (e) {
      _showError('Failed to activate SOS: ${e.toString()}');
    } finally {
      setState(() {
        _isSOSActivating = false;
      });
    }
  }

  void _showSOSSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('SOS Activated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your emergency contacts have been notified with:'),
            const SizedBox(height: 12),
            const Text('• Your name and phone number'),
            const Text('• Your current ride details'),
            const Text('• Your live location'),
            const SizedBox(height: 16),
            Text(
              'Stay calm. Help is on the way.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Optionally call emergency services
            },
            child: const Text('Call Emergency Services', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showShareTripDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Trip Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share your ride details with emergency contacts:'),
            const SizedBox(height: 16),
            if (!_hasActiveRide)
              const Text(
                'No active ride found. Start a ride to share your trip status.',
                style: TextStyle(color: Colors.orange),
              ),
            if (_hasActiveRide)
              const Text('Your current ride will be shared with your emergency contacts.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (_hasActiveRide)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _shareTripDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Share Now'),
            ),
        ],
      ),
    );
  }

  Future<void> _shareTripDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final hasContacts = await _contactService.hasEmergencyContacts();
    if (!hasContacts) {
      _showError('Please add emergency contacts first');
      return;
    }

    try {
      final userProfile = await _userService.getUserProfile(currentUser.uid);
      final ride = await _rideService.getRideById(_currentRideId!);

      await _contactService.sendSOS(
        userName: userProfile?.name ?? 'User',
        userPhone: userProfile?.phone ?? 'Not provided',
        rideFrom: ride?.from ?? 'Unknown',
        rideTo: ride?.destination ?? 'Unknown',
        currentLocation: 'Trip shared',
      );

      _showSuccess('Trip details shared with your emergency contacts!');
    } catch (e) {
      _showError('Failed to share trip: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showResourceDialog(BuildContext context, String title) {
    String content;
    switch (title) {
      case 'Community Guidelines':
        content = '• Respect all users\n• No harassment or discrimination\n• Be punctual for rides\n• Keep vehicles clean\n• Rate honestly and fairly';
        break;
      case 'Safety Best Practices':
        content = '• Verify driver identity before ride\n• Share trip details with family\n• Keep phone charged\n• Sit in back seat if possible\n• Trust your instincts';
        break;
      case 'Report a Safety Issue':
        content = 'To report a safety issue:\n1. Go to your ride history\n2. Select the problematic ride\n3. Tap "Report Issue"\n4. Describe the incident\n5. Submit for review';
        break;
      default:
        content = 'More information about "$title" will be available soon.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Safety Center'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency SOS Section
            _buildEmergencySOS(context),
            const SizedBox(height: 24),

            // Quick Actions
            _buildShareTripButton(context),
            const SizedBox(height: 12),
            _buildEmergencyContactsButton(context),
            const SizedBox(height: 32),

            // Safety Tips Section
            _buildSafetyTipsSection(),
            const SizedBox(height: 32),

            // Resources Section
            _buildResourcesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencySOS(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency SOS',
                      style: AppTextStyles.heading3,
                    ),
                    Text(
                      'Get help immediately',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSOSActivating ? null : _activateSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSOSActivating
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Activate SOS', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This will alert your emergency contacts',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShareTripButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showShareTripDialog,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share Trip Status',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _hasActiveRide
                            ? 'Share your current ride with contacts'
                            : 'No active ride to share',
                        style: AppTextStyles.caption.copyWith(
                          color: _hasActiveRide ? AppColors.textSecondary : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.emergencyContacts);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Contacts',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Manage your emergency contacts',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Safety Tips',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...safetyTips.asMap().entries.map((entry) {
          int index = entry.key;
          String tip = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Resources',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildResourceTile(context, 'Community Guidelines'),
        _buildResourceTile(context, 'Safety Best Practices'),
        _buildResourceTile(context, 'Report a Safety Issue'),
      ],
    );
  }

  Widget _buildResourceTile(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title, style: AppTextStyles.bodyMedium),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: () {
          _showResourceDialog(context, title);
        },
      ),
    );
  }
}