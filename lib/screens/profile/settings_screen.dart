import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _rideRemindersEnabled = true;
  bool _chatNotificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _shareLocationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
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
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.timer,
                  title: 'Ride Reminders',
                  subtitle: 'Get reminders 15 minutes before ride',
                  value: _rideRemindersEnabled,
                  onChanged: (value) {
                    setState(() {
                      _rideRemindersEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.chat,
                  title: 'Chat Notifications',
                  subtitle: 'Get notified when you receive new messages',
                  value: _chatNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _chatNotificationsEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Use a dark theme for the app interface',
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
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
                  onChanged: (value) {
                    setState(() {
                      _shareLocationEnabled = value;
                    });
                  },
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Blocked users feature coming soon'),
                        duration: Duration(seconds: 1),
                      ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for rating!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
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
}
