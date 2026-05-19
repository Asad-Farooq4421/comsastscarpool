import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _notificationsEnabled = true;
  bool _rideRemindersEnabled = true;
  bool _chatNotificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _shareLocationEnabled = true;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      DatabaseEvent event = await _databaseRef
          .child('users/${currentUser.uid}/settings')
          .once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<String, dynamic> settings = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _notificationsEnabled = settings['notificationsEnabled'] ?? true;
          _rideRemindersEnabled = settings['rideRemindersEnabled'] ?? true;
          _chatNotificationsEnabled = settings['chatNotificationsEnabled'] ?? true;
          _darkModeEnabled = settings['darkModeEnabled'] ?? false;
          _shareLocationEnabled = settings['shareLocationEnabled'] ?? true;
          _isLoading = false;
        });
      } else {
        // No settings saved yet, save defaults
        await _saveAllSettings();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _databaseRef
          .child('users/${currentUser.uid}/settings/$key')
          .set(value);
    } catch (e) {
      print('Error saving setting $key: $e');
      _showError('Failed to save settings');
    }
  }

  Future<void> _saveAllSettings() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final settings = {
        'notificationsEnabled': _notificationsEnabled,
        'rideRemindersEnabled': _rideRemindersEnabled,
        'chatNotificationsEnabled': _chatNotificationsEnabled,
        'darkModeEnabled': _darkModeEnabled,
        'shareLocationEnabled': _shareLocationEnabled,
      };

      await _databaseRef
          .child('users/${currentUser.uid}/settings')
          .set(settings);
    } catch (e) {
      print('Error saving all settings: $e');
    }
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await _saveSetting('notificationsEnabled', value);

    if (value) {
      _showSuccess('Notifications enabled');
    } else {
      _showSuccess('Notifications disabled');
    }
  }

  Future<void> _toggleRideReminders(bool value) async {
    setState(() {
      _rideRemindersEnabled = value;
    });
    await _saveSetting('rideRemindersEnabled', value);
  }

  Future<void> _toggleChatNotifications(bool value) async {
    setState(() {
      _chatNotificationsEnabled = value;
    });
    await _saveSetting('chatNotificationsEnabled', value);
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _darkModeEnabled = value;
    });
    await _saveSetting('darkModeEnabled', value);

    // TODO: Apply theme change across the app
    if (value) {
      _showInfo('Dark mode coming in next update');
    }
  }

  Future<void> _toggleShareLocation(bool value) async {
    setState(() {
      _shareLocationEnabled = value;
    });
    await _saveSetting('shareLocationEnabled', value);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Preferences Section
            _buildSection(
              title: 'Preferences',
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications about rides and messages',
                  value: _notificationsEnabled,
                  onChanged: _toggleNotification,
                ),
                _buildSwitchTile(
                  icon: Icons.timer,
                  title: 'Ride Reminders',
                  subtitle: 'Get reminders 15 minutes before ride',
                  value: _rideRemindersEnabled,
                  onChanged: _toggleRideReminders,
                ),
                _buildSwitchTile(
                  icon: Icons.chat,
                  title: 'Chat Notifications',
                  subtitle: 'Get notified when you receive new messages',
                  value: _chatNotificationsEnabled,
                  onChanged: _toggleChatNotifications,
                ),
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Use a dark theme for the app interface',
                  value: _darkModeEnabled,
                  onChanged: _toggleDarkMode,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Privacy & Safety Section
            _buildSection(
              title: 'Privacy & Safety',
              children: [
                _buildSwitchTile(
                  icon: Icons.location_on,
                  title: 'Share Location',
                  subtitle: 'Allow app to access your location for rides',
                  value: _shareLocationEnabled,
                  onChanged: _toggleShareLocation,
                ),

                _buildNavigationTile(
                  icon: Icons.security,
                  title: 'Safety Center',
                  subtitle: 'SOS, safety tips, and emergency resources',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.safetyCenter);
                  },
                ),

                _buildNavigationTile(
                  icon: Icons.emergency,
                  title: 'Emergency Contacts',
                  subtitle: 'Manage your emergency contacts for SOS',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.emergencyContacts);
                  },
                ),

                _buildNavigationTile(
                  icon: Icons.block,
                  title: 'Blocked Users',
                  subtitle: 'View and manage blocked users',
                  onTap: () {
                    _showInfoDialog(
                        'Blocked Users',
                        'This feature will be available soon.\n\n'
                            'You will be able to block users who:\n'
                            '• Cancel rides frequently\n'
                            '• Are disrespectful\n'
                            '• Violate safety guidelines'
                    );
                  },
                ),
                _buildNavigationTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    _showInfoDialog('Privacy Policy',
                        'Your privacy is important to us. We collect only your university email and ride information to facilitate ride-sharing.\n\n'
                            'Your data is never shared with third parties without your consent.\n\n'
                            'For more information, contact support@campuscarpool.com'
                    );
                  },
                ),
                _buildNavigationTile(
                  icon: Icons.description,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  onTap: () {
                    _showInfoDialog('Terms of Service',
                        'By using Campus Carpool, you agree to:\n\n'
                            '• Only share rides with verified university students\n'
                            '• Be punctual and respectful to fellow riders\n'
                            '• Report any safety concerns immediately\n'
                            '• Not use the app for commercial purposes\n\n'
                            'Violation of terms may result in account suspension.'
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Support Section
            _buildSection(
              title: 'Support',
              children: [
                _buildNavigationTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'FAQs and support articles',
                  onTap: () {
                    _showInfoDialog('Help Center',
                        'Frequently Asked Questions:\n\n'
                            'Q: How do I post a ride?\n'
                            'A: Switch to Driver mode and tap "Post New Ride"\n\n'
                            'Q: How do I find a ride?\n'
                            'A: Switch to Passenger mode and search for rides\n\n'
                            'Q: Is payment handled in app?\n'
                            'A: Currently, payments are cash-based between riders\n\n'
                            'Need more help? Contact: support@campuscarpool.com'
                    );
                  },
                ),
                _buildNavigationTile(
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the app',
                  onTap: () {
                    _showInfoDialog('Send Feedback',
                        'We\'d love to hear from you!\n\n'
                            'Send your feedback to:\n'
                            'feedback@campuscarpool.com\n\n'
                            'Or visit our website:\n'
                            'www.campus-carpool.com/feedback'
                    );
                  },
                ),
                _buildNavigationTile(
                  icon: Icons.star,
                  title: 'Rate the App',
                  subtitle: 'Share your experience',
                  onTap: () {
                    _showInfoDialog(
                        'Rate the App',
                        'Thank you for using Campus Carpool!\n\n'
                            'Your rating helps us improve.\n\n'
                            'Please rate us on the app store:'
                    );
                    _showSuccess('Thank you for rating!');
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // About Section
            _buildSection(
              title: 'About',
              children: [
                _buildInfoTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  subtitle: '1.0.0',
                ),
                _buildInfoTile(
                  icon: Icons.business,
                  title: 'Developed by',
                  subtitle: 'Campus Carpool Team',
                ),
                _buildInfoTile(
                  icon: Icons.email,
                  title: 'Contact',
                  subtitle: 'support@campuscarpool.com',
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          ...children,
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primary.withOpacity(0.5),
      activeThumbColor: AppColors.primary,
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
    );
  }
}