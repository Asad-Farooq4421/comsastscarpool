import '../models/emergency_contact_model.dart';
import 'dummy_users.dart';  // For getCurrentUserId()

// All emergency contacts stored globally with userId
List<EmergencyContact> allEmergencyContacts = [
  EmergencyContact(
    id: 'ec1',
    userId: 'sara@isbstudent.comsats.edu.pk',
    name: 'Mother',
    phone: '+92 300 1111111',
    relationship: 'Parent',
  ),
  EmergencyContact(
    id: 'ec2',
    userId: 'sara@isbstudent.comsats.edu.pk',
    name: 'Sister',
    phone: '+92 300 2222222',
    relationship: 'Sibling',
  ),
  EmergencyContact(
    id: 'ec3',
    userId: 'ali@isbstudent.comsats.edu.pk',
    name: 'Brother',
    phone: '+92 300 3333333',
    relationship: 'Sibling',
  ),
  EmergencyContact(
    id: 'ec4',
    userId: 'ali@isbstudent.comsats.edu.pk',
    name: 'Friend',
    phone: '+92 300 4444444',
    relationship: 'Friend',
  ),
  EmergencyContact(
    id: 'ec5',
    userId: 'ahmed@isbstudent.comsats.edu.pk',
    name: 'Wife',
    phone: '+92 300 5555555',
    relationship: 'Spouse',
  ),
];

// ==================== STORE LOGIC ====================

// Get emergency contacts for currently logged-in user
List<EmergencyContact> getCurrentUserEmergencyContacts() {
  final currentUserId = getCurrentUserId();
  if (currentUserId.isEmpty) return [];
  return allEmergencyContacts.where((contact) => contact.userId == currentUserId).toList();
}

// Get emergency contact by ID
EmergencyContact? getEmergencyContactById(String contactId) {
  try {
    return allEmergencyContacts.firstWhere((contact) => contact.id == contactId);
  } catch (e) {
    return null;
  }
}

// Add emergency contact for current user
void addEmergencyContactForCurrentUser({
  required String name,
  required String phone,
  required String relationship,
}) {
  final currentUserId = getCurrentUserId();
  final newContact = EmergencyContact(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: currentUserId,
    name: name,
    phone: phone,
    relationship: relationship,
  );
  allEmergencyContacts.add(newContact);
  print('✅ Emergency contact added for: $currentUserId');
}

// Delete emergency contact
void deleteEmergencyContact(String contactId) {
  allEmergencyContacts.removeWhere((contact) => contact.id == contactId);
  print('✅ Emergency contact deleted: $contactId');
}

// Update emergency contact
void updateEmergencyContact(EmergencyContact updatedContact) {
  final index = allEmergencyContacts.indexWhere((c) => c.id == updatedContact.id);
  if (index != -1) {
    allEmergencyContacts[index] = updatedContact;
    print('✅ Emergency contact updated: ${updatedContact.id}');
  }
}

// Check if user has at least one emergency contact
bool hasEmergencyContacts() {
  return getCurrentUserEmergencyContacts().isNotEmpty;
}