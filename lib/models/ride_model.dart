import 'package:google_maps_flutter/google_maps_flutter.dart';

class Ride {
  final String rideId;
  final String driverId;
  final String driverName;
  final String driverPhoto;
  final double driverRating;
  final String from;        // Pickup location NAME
  final String destination; // Dropoff location NAME
  final String date;
  final String time;
  final int totalSeats;
  int availableSeats;
  final int price;
  final String status;
  final String notes;
  final int pendingRequests;
  final List<PassengerInfo> passengers;

  // Google Maps coordinates
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;

  // Full formatted addresses
  final String? pickupAddress;
  final String? dropoffAddress;

  Ride({
    required this.rideId,
    required this.driverId,
    required this.driverName,
    required this.driverPhoto,
    required this.driverRating,
    required this.from,
    required this.destination,
    required this.date,
    required this.time,
    required this.totalSeats,
    required this.availableSeats,
    required this.price,
    required this.status,
    required this.notes,
    required this.pendingRequests,
    required this.passengers,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.pickupAddress,
    this.dropoffAddress,
  });

  // From JSON (Firebase)
  factory Ride.fromJson(Map<String, dynamic> json, String id) {
    return Ride(
      rideId: id,
      driverId: json['driverId'] ?? '',
      driverName: json['driverName'] ?? '',
      driverPhoto: json['driverPhoto'] ?? '',
      driverRating: (json['driverRating'] ?? 0.0).toDouble(),
      from: json['from'] ?? '',
      destination: json['destination'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      totalSeats: json['totalSeats'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      price: json['price'] ?? 0,
      status: json['status'] ?? 'scheduled',
      notes: json['notes'] ?? '',
      pendingRequests: json['pendingRequests'] ?? 0,
      passengers: (json['passengers'] as List? ?? [])
          .map((p) => PassengerInfo.fromJson(Map<String, dynamic>.from(p)))
          .toList(),
      pickupLatitude: json['pickupLatitude'] != null ? (json['pickupLatitude'] as num).toDouble() : null,
      pickupLongitude: json['pickupLongitude'] != null ? (json['pickupLongitude'] as num).toDouble() : null,
      dropoffLatitude: json['dropoffLatitude'] != null ? (json['dropoffLatitude'] as num).toDouble() : null,
      dropoffLongitude: json['dropoffLongitude'] != null ? (json['dropoffLongitude'] as num).toDouble() : null,
      pickupAddress: json['pickupAddress'] ?? json['from'],
      dropoffAddress: json['dropoffAddress'] ?? json['destination'],
    );
  }

  // To JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'driverPhoto': driverPhoto,
      'driverRating': driverRating,
      'from': from,
      'destination': destination,
      'date': date,
      'time': time,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'price': price,
      'status': status,
      'notes': notes,
      'pendingRequests': pendingRequests,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      if (pickupLatitude != null) 'pickupLatitude': pickupLatitude,
      if (pickupLongitude != null) 'pickupLongitude': pickupLongitude,
      if (dropoffLatitude != null) 'dropoffLatitude': dropoffLatitude,
      if (dropoffLongitude != null) 'dropoffLongitude': dropoffLongitude,
      'pickupAddress': pickupAddress ?? from,
      'dropoffAddress': dropoffAddress ?? destination,
    };
  }

  // Helper getters
  int get filledSeats => totalSeats - availableSeats;
  bool get isActive => status == 'active' || status == 'scheduled';
  bool get hasCoordinates => pickupLatitude != null && pickupLongitude != null;
  String get priceString => 'Rs. $price';

  LatLng? get pickupLatLng {
    if (pickupLatitude != null && pickupLongitude != null) {
      return LatLng(pickupLatitude!, pickupLongitude!);
    }
    return null;
  }

  LatLng? get dropoffLatLng {
    if (dropoffLatitude != null && dropoffLongitude != null) {
      return LatLng(dropoffLatitude!, dropoffLongitude!);
    }
    return null;
  }

  Ride copyWith({
    String? rideId,
    String? driverId,
    String? driverName,
    String? driverPhoto,
    double? driverRating,
    String? from,
    String? destination,
    String? date,
    String? time,
    int? totalSeats,
    int? availableSeats,
    int? price,
    String? status,
    String? notes,
    int? pendingRequests,
    List<PassengerInfo>? passengers,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    String? pickupAddress,
    String? dropoffAddress,
  }) {
    return Ride(
      rideId: rideId ?? this.rideId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhoto: driverPhoto ?? this.driverPhoto,
      driverRating: driverRating ?? this.driverRating,
      from: from ?? this.from,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      time: time ?? this.time,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      passengers: passengers ?? this.passengers,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    );
  }
}

// ============================================
// PassengerInfo Class (MUST be defined here)
// ============================================
class PassengerInfo {
  final String userId;
  final String name;
  final String status; // pending, accepted, declined, cancelled

  PassengerInfo({
    required this.userId,
    required this.name,
    required this.status,
  });

  // From JSON (Firebase)
  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  // To JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'status': status,
    };
  }

  PassengerInfo copyWith({
    String? userId,
    String? name,
    String? status,
  }) {
    return PassengerInfo(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}