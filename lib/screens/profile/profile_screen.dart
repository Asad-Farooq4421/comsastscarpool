import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../data/dummy_users.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // For demo, using the first user as logged in user
  Map<String, dynamic> _user = {};
  bool _isEditing = false;

  // Controllers for editing
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load user data (using first user from dummy list as logged in)
    if (dummyUsers.isNotEmpty) {
      _user = Map.from(dummyUsers[0]);
      _nameController.text = _user['name'] ?? '';
      _phoneController.text = _user['phone'] ?? '';
      _bioController.text = _user['bio'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    setState(() {
      _user['name'] = _nameController.text;
      _user['phone'] = _phoneController.text;
      _user['bio'] = _bioController.text;
      _isEditing = false;
    });

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
            // Profile Header with Photo
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Profile Photo
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: _user['photoURL'] != null
                            ? ClipOval(
                          child: Image.network(
                            _user['photoURL'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              onPressed: () {
                                // In demo, just show message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Photo upload will be available soon'),
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
                  // Name
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
                  // Verification Badge
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
                  // Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        _user['email'] ?? 'student@isbstudent.comsats.edu.pk',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats Section
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stats',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard('Rides Given', '0', Icons.directions_car),
                        const SizedBox(width: 16),
                        _buildStatCard('Rides Taken', '0', Icons.person),
                        const SizedBox(width: 16),
                        _buildStatCard('Rating', '0.0', Icons.star),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact Info Section
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

            // Action Buttons
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