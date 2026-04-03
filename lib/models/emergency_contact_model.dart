class EmergencyContact {
  final String id;
  final String userId;  // ← ADD THIS - Which user does this contact belong to?
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.id,
    required this.userId,  // ← ADD THIS
    required this.name,
    required this.phone,
    required this.relationship,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,  // ← ADD THIS
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  // Create from Map
  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      userId: map['userId'],  // ← ADD THIS
      name: map['name'],
      phone: map['phone'],
      relationship: map['relationship'],
    );
  }
}