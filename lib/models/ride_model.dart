class Ride {
  final String rideId;
  final String driverId;
  final String driverName;
  final String driverPhoto;
  final double driverRating;
  final String from;
  final String destination;
  final String date;
  final String time;
  final int totalSeats;
  int availableSeats;
  final int price;
  final String status;
  final String notes;
  final int pendingRequests;
  final List<PassengerInfo> passengers;

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
  });

  // Helper to get filled seats count
  int get filledSeats => totalSeats - availableSeats;

  // Helper to check if ride is active
  bool get isActive => status == 'active' || status == 'scheduled';

  // Helper to get price per seat as string
  String get priceString => 'Rs. $price';

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
    );
  }
}

class PassengerInfo {
  final String userId;
  final String name;
  final String status; // pending, accepted, declined, cancelled

  PassengerInfo({
    required this.userId,
    required this.name,
    required this.status,
  });

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
