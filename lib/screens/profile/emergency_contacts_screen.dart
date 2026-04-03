import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/emergency_contact_model.dart';
import '../../data/dummy_emergency_contacts.dart';  // ← Import dummy data with store logic
import '../../data/dummy_users.dart';  // ← For getCurrentUserName()

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<EmergencyContact> contacts = [];
  bool isAdding = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedRelationship = 'Friend';

  final List<String> relationships = [
    'Parent',
    'Sibling',
    'Spouse',
    'Friend',
    'Roommate',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    nameController.dispose();  // ← IMPORTANT: Dispose controllers!
    phoneController.dispose();
    super.dispose();
  }


  void _loadContacts() {
    // ✅ Get contacts for CURRENT logged-in user only
    setState(() {
      contacts = getCurrentUserEmergencyContacts();
    });
  }

  void _addContact() {
    if (nameController.text.trim().isEmpty) {
      _showError('Please enter name');
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      _showError('Please enter phone number');
      return;
    }

    // ✅ Add contact for current user using store logic
    addEmergencyContactForCurrentUser(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      relationship: selectedRelationship,
    );

    setState(() {
      contacts = getCurrentUserEmergencyContacts();  // Refresh list
      isAdding = false;
      nameController.clear();
      phoneController.clear();
      selectedRelationship = 'Friend';
    });

    _showSuccess('Contact added successfully');
  }

  void _deleteContact(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to remove this emergency contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // ✅ Delete contact using store logic
              deleteEmergencyContact(id);

              setState(() {
                contacts = getCurrentUserEmergencyContacts();  // Refresh list
              });
              Navigator.pop(context);
              _showSuccess('Contact deleted');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

  void _refreshContacts() {
    setState(() {
      contacts = getCurrentUserEmergencyContacts();
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user name for header
    final currentUserName = getCurrentUserName();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        actions: [
          if (!isAdding)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  isAdding = true;
                });
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
        ],
      ),
      body: RefreshIndicator(  // ← Add pull to refresh
        onRefresh: () async {
          _refreshContacts();
        },
        child: Column(
        children: [
          // Info Banner with current user name
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$currentUserName,These contacts will be notified if you use the emergency SOS feature. At least one contact is recommended.',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Add Contact Form
          if (isAdding) _buildAddContactForm(),

          // Contact List
          Expanded(
            child: contacts.isEmpty && !isAdding
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _buildContactCard(contact);
                },
              ),
           ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddContactForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Emergency Contact',
            style: AppTextStyles.heading3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),

          // Name Field
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Full Name',
              hintStyle: AppTextStyles.inputHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // Phone Field
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              hintStyle: AppTextStyles.inputHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // Relationship Dropdown
          DropdownButtonFormField<String>(
            initialValue: selectedRelationship,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: relationships.map((relation) {
              return DropdownMenuItem(
                value: relation,
                child: Text(relation),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedRelationship = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _addContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text('Add Contact'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      isAdding = false;
                      nameController.clear();
                      phoneController.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.relationship,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.phone,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteContact(contact.id),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contact_phone,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No emergency contacts added',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first contact for safety',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}