class EmergencyContact {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  // Create from Map
  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
    );
  }

  // For Firebase JSON
  Map<String, dynamic> toJson() => toMap();

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact.fromMap(json);
  }

  EmergencyContact copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? relationship,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
    );
  }
}