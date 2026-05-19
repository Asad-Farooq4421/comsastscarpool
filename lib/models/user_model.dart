class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? photo;
  final String university;
  final String? phone;
  final String? bio;
  final bool isDriver;
  final int ridesAsDriver;
  final double driverRating;
  final int earnings;
  final String vehicleType;
  final String vehicleModel;
  final String vehicleColor;
  final String vehiclePlate;
  final int vehicleSeats;
  final int ridesAsPassenger;
  final double passengerRating;
  final int savedRoutes;
  final DateTime createdAt;
  final DateTime? lastSeen;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.photo,
    this.university = 'COMSATS Islamabad',
    this.phone,
    this.bio,
    this.isDriver = false,
    this.ridesAsDriver = 0,
    this.driverRating = 0.0,
    this.earnings = 0,
    this.vehicleType = '',
    this.vehicleModel = '',
    this.vehicleColor = '',
    this.vehiclePlate = '',
    this.vehicleSeats = 0,
    this.ridesAsPassenger = 0,
    this.passengerRating = 0.0,
    this.savedRoutes = 0,
    required this.createdAt,
    this.lastSeen,
  });

  // Convert from JSON (Firebase Realtime DB)
  factory AppUser.fromJson(
      Map<String, dynamic> json,
      String uid,
      ) {
    return AppUser(
      uid: uid,

      email: json['email']?.toString() ?? '',

      name: json['name']?.toString() ?? '',

      photo: json['photo']?.toString(),

      university:
      json['university']?.toString() ??
          'COMSATS Islamabad',

      phone: json['phone']?.toString(),

      bio: json['bio']?.toString(),

      isDriver: json['isDriver'] ?? false,

      ridesAsDriver:
      (json['ridesAsDriver'] ?? 0) is int
          ? json['ridesAsDriver']
          : int.tryParse(
        json['ridesAsDriver'].toString(),
      ) ??
          0,


      driverRating:
      (json['driverRating'] ?? 0)
          .toDouble(),

      earnings:
      (json['earnings'] ?? 0) is int
          ? json['earnings']
          : int.tryParse(
        json['earnings'].toString(),
      ) ??
          0,

      vehicleType:
      json['vehicleType']?.toString() ?? '',

      vehicleModel:
      json['vehicleModel']?.toString() ?? '',

      vehicleColor:
      json['vehicleColor']?.toString() ?? '',

      vehiclePlate:
      json['vehiclePlate']?.toString() ?? '',

      vehicleSeats:
      (json['vehicleSeats'] ?? 0) is int
          ? json['vehicleSeats']
          : int.tryParse(
        json['vehicleSeats'].toString(),
      ) ??
          0,

      ridesAsPassenger:
      (json['ridesAsPassenger'] ?? 0) is int
          ? json['ridesAsPassenger']
          : int.tryParse(
        json['ridesAsPassenger'].toString(),
      ) ??
          0,

      passengerRating:
      (json['passengerRating'] ?? 0)
          .toDouble(),

      savedRoutes:
      (json['savedRoutes'] ?? 0) is int
          ? json['savedRoutes']
          : int.tryParse(
        json['savedRoutes'].toString(),
      ) ??
          0,

      // FIXED CREATED AT
      createdAt: _parseFirebaseDate(
        json['createdAt'],
      ),

      // FIXED LAST SEEN
      lastSeen: json['lastSeen'] != null
          ? _parseFirebaseDate(
        json['lastSeen'],
      )
          : null,
    );
  }

  static DateTime _parseFirebaseDate(dynamic value) {

    if (value == null) {
      return DateTime.now();
    }

    // Timestamp int
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value,
      );
    }

    // Timestamp string number
    if (value is String) {

      final intValue = int.tryParse(value);

      if (intValue != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          intValue,
        );
      }

      // ISO date string
      return DateTime.tryParse(value) ??
          DateTime.now();
    }

    return DateTime.now();
  }
  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'photo': photo,
      'university': university,
      'phone': phone,
      'bio': bio,
      'isDriver': isDriver,
      'ridesAsDriver': ridesAsDriver,
      'driverRating': driverRating,
      'earnings': earnings,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehiclePlate': vehiclePlate,
      'vehicleSeats': vehicleSeats,
      'ridesAsPassenger': ridesAsPassenger,
      'passengerRating': passengerRating,
      'savedRoutes': savedRoutes,
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  // Copy with method for updates
  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? photo,
    String? university,
    String? phone,
    String? bio,
    bool? isDriver,
    int? ridesAsDriver,
    double? driverRating,
    int? earnings,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleColor,
    String? vehiclePlate,
    int? vehicleSeats,
    int? ridesAsPassenger,
    double? passengerRating,
    int? savedRoutes,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      university: university ?? this.university,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      isDriver: isDriver ?? this.isDriver,
      ridesAsDriver: ridesAsDriver ?? this.ridesAsDriver,
      driverRating: driverRating ?? this.driverRating,
      earnings: earnings ?? this.earnings,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleSeats: vehicleSeats ?? this.vehicleSeats,
      ridesAsPassenger: ridesAsPassenger ?? this.ridesAsPassenger,
      passengerRating: passengerRating ?? this.passengerRating,
      savedRoutes: savedRoutes ?? this.savedRoutes,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}