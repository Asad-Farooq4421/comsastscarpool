import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emergency_contact_model.dart';

class EmergencyContactService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new emergency contact
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      final String contactId = _databaseRef
          .child('users/${currentUser.uid}/emergencyContacts')
          .push()
          .key!;

      final updatedContact = EmergencyContact(
        id: contactId,
        userId: currentUser.uid,
        name: contact.name,
        phone: contact.phone,
        relationship: contact.relationship,
      );

      await _databaseRef
          .child('users/${currentUser.uid}/emergencyContacts/$contactId')
          .set(updatedContact.toMap());
    } catch (e) {
      throw Exception('Failed to add emergency contact: $e');
    }
  }

  // Get all emergency contacts for current user
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      DatabaseEvent event = await _databaseRef
          .child('users/${currentUser.uid}/emergencyContacts')
          .once();
      DataSnapshot snapshot = event.snapshot;

      List<EmergencyContact> contacts = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> contactsMap = snapshot.value as Map;
        contactsMap.forEach((key, value) {
          Map<String, dynamic> contactData = Map<String, dynamic>.from(value);
          contacts.add(EmergencyContact.fromMap(contactData));
        });
      }

      return contacts;
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  // Update an emergency contact
  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      await _databaseRef
          .child('users/${currentUser.uid}/emergencyContacts/${contact.id}')
          .update(contact.toMap());
    } catch (e) {
      throw Exception('Failed to update emergency contact: $e');
    }
  }

  // Delete an emergency contact
  Future<void> deleteEmergencyContact(String contactId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      await _databaseRef
          .child('users/${currentUser.uid}/emergencyContacts/$contactId')
          .remove();
    } catch (e) {
      throw Exception('Failed to delete emergency contact: $e');
    }
  }

  // Get emergency contact by ID
  Future<EmergencyContact?> getEmergencyContactById(String contactId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      DatabaseEvent event = await _databaseRef
          .child('users/${currentUser.uid}/emergencyContacts/$contactId')
          .once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<String, dynamic> contactData = Map<String, dynamic>.from(snapshot.value as Map);
        return EmergencyContact.fromMap(contactData);
      }
    } catch (e) {
      print('Error getting emergency contact: $e');
    }
    return null;
  }

  // Stream of emergency contacts (real-time updates)
  Stream<List<EmergencyContact>> streamEmergencyContacts() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _databaseRef
        .child('users/${currentUser.uid}/emergencyContacts')
        .onValue
        .map((event) {
      List<EmergencyContact> contacts = [];

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> contactsMap = event.snapshot.value as Map;
        contactsMap.forEach((key, value) {
          Map<String, dynamic> contactData = Map<String, dynamic>.from(value);
          contacts.add(EmergencyContact.fromMap(contactData));
        });
      }

      return contacts;
    });
  }

  // Send SOS message to all emergency contacts
  Future<void> sendSOS({
    required String userName,
    required String userPhone,
    required String rideFrom,
    required String rideTo,
    required String currentLocation,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      final contacts = await getEmergencyContacts();
      if (contacts.isEmpty) {
        throw Exception('No emergency contacts added');
      }

      // Create SOS message
      final String sosId = _databaseRef.child('sosMessages').push().key!;
      final sosMessage = {
        'userId': currentUser.uid,
        'userName': userName,
        'userPhone': userPhone,
        'rideFrom': rideFrom,
        'rideTo': rideTo,
        'currentLocation': currentLocation,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'active',
      };

      await _databaseRef.child('sosMessages/$sosId').set(sosMessage);

      // In a real app, you would also:
      // 1. Send SMS to emergency contacts using a backend service
      // 2. Send push notifications
      // 3. Share live location

      print('SOS sent to ${contacts.length} contacts');
    } catch (e) {
      throw Exception('Failed to send SOS: $e');
    }
  }

  // Check if user has any emergency contacts
  Future<bool> hasEmergencyContacts() async {
    final contacts = await getEmergencyContacts();
    return contacts.isNotEmpty;
  }

  // Get count of emergency contacts
  Future<int> getEmergencyContactsCount() async {
    final contacts = await getEmergencyContacts();
    return contacts.length;
  }
}