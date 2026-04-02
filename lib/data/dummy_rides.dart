import '../models/ride_model.dart';

final List<Ride> dummyRides = [
  Ride(
    rideId: '1',
    driverId: 'driver1',
    driverName: 'Ali',
    driverPhoto: '',
    driverRating: 4.8,
    from: 'University Main Gate',
    destination: 'Gulberg Center',
    date: '2026-03-30',
    time: '09:00 AM',
    totalSeats: 4,
    availableSeats: 2,
    price: 150,
    status: 'scheduled',
    notes: 'Can pick up near Starbucks',
    pendingRequests: 2,
    passengers: [
      PassengerInfo(userId: 'p1', name: 'Ahmed', status: 'pending'),
      PassengerInfo(userId: 'p2', name: 'Fatima', status: 'pending'),
    ],
  ),
  Ride(
    rideId: '2',
    driverId: 'driver1',
    driverName: 'Ali',
    driverPhoto: '',
    driverRating: 4.8,
    from: 'Hostel Block B',
    destination: 'DHA Phase 5',
    date: '2026-03-31',
    time: '02:00 PM',
    totalSeats: 3,
    availableSeats: 3,
    price: 200,
    status: 'scheduled',
    notes: '',
    pendingRequests: 0,
    passengers: [],
  ),
  Ride(
    rideId: '3',
    driverId: 'driver2',
    driverName: 'Asim',
    driverPhoto: '',
    driverRating: 4.5,
    from: 'University Library',
    destination: 'F-10 Markaz',
    date: '2026-03-30',
    time: '11:00 AM',
    totalSeats: 4,
    availableSeats: 1,
    price: 300,
    status: 'scheduled',
    notes: 'No smoking please',
    pendingRequests: 1,
    passengers: [
      PassengerInfo(userId: 'p3', name: 'Omar', status: 'pending'),
    ],
  ),
  Ride(
    rideId: '4',
    driverId: 'driver3',
    driverName: 'Ahmed',
    driverPhoto: '',
    driverRating: 4.2,
    from: 'COMSATS Gate',
    destination: 'G-11',
    date: '2026-03-30',
    time: '11:00 AM',
    totalSeats: 2,
    availableSeats: 0,
    price: 150,
    status: 'active',
    notes: '',
    pendingRequests: 0,
    passengers: [
      PassengerInfo(userId: 'p4', name: 'Zara', status: 'accepted'),
      PassengerInfo(userId: 'p5', name: 'Hassan', status: 'accepted'),
    ],
  ),
  Ride(
    rideId: '5',
    driverId: 'driver4',
    driverName: 'Sara',
    driverPhoto: '',
    driverRating: 4.9,
    from: 'Girls Hostel',
    destination: 'F-10',
    date: '2026-03-31',
    time: '09:00 AM',
    totalSeats: 4,
    availableSeats: 2,
    price: 180,
    status: 'scheduled',
    notes: 'Female only',
    pendingRequests: 2,
    passengers: [
      PassengerInfo(userId: 'p6', name: 'Ayesha', status: 'pending'),
      PassengerInfo(userId: 'p7', name: 'Maria', status: 'pending'),
    ],
  ),
];

// Helper function to get rides by driver ID
List<Ride> getRidesByDriverId(String driverId) {
  return dummyRides.where((ride) => ride.driverId == driverId).toList();
}

// Helper function to get ride by ID
Ride? getRideById(String rideId) {
  try {
    return dummyRides.firstWhere((ride) => ride.rideId == rideId);
  } catch (e) {
    return null;
  }
}
List<Ride> getRidesByDriverEmail(String driverEmail) {
  return dummyRides.where((ride) => ride.driverId == driverEmail).toList();
}
