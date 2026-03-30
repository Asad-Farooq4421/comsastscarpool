class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  // Create from Map
  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      relationship: map['relationship'],
    );
  }
}