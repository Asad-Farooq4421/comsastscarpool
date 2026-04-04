import '../models/ride_model.dart';
import '../models/ride_model.dart';

final List<Ride> dummyRides = [
  Ride(
    rideId: '1',
    driverId: 'ali@isbstudent.comsats.edu.pk',  // ✅ Changed
    driverName: 'Ali Khan',
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
      PassengerInfo(userId: 'ahmed@isbstudent.comsats.edu.pk', name: 'Ahmed', status: 'pending'),
      PassengerInfo(userId: 'fatima@isbstudent.comsats.edu.pk', name: 'Fatima', status: 'pending'),
    ],
  ),
  Ride(
    rideId: '2',
    driverId: 'ali@isbstudent.comsats.edu.pk',  // ✅ Changed
    driverName: 'Ali Khan',
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
    driverId: 'ahmed@isbstudent.comsats.edu.pk',  // ✅ Changed
    driverName: 'Ahmed Raza',
    driverPhoto: '',
    driverRating: 4.5,
    from: 'University Library',
    destination: 'F-10 Markaz',
    date: '2026-04-30',
    time: '11:00 AM',
    totalSeats: 4,
    availableSeats: 2,
    price: 300,
    status: 'scheduled',
    notes: 'No smoking please',
    pendingRequests: 1,
    passengers: [
      PassengerInfo(userId: 'Bilal@isbstudent.comsats.edu.pk', name: 'Bilal Ahmed', status: 'accepted'),
    ],
  ),
  Ride(
    rideId: '4',
    driverId: 'ahmed@isbstudent.comsats.edu.pk',  // ✅ Changed
    driverName: 'Ahmed Raza',
    driverPhoto: '',
    driverRating: 4.2,
    from: 'COMSATS Gate',
    destination: 'G-11',
    date: '2026-04-15',
    time: '11:00 AM',
    totalSeats: 2,
    availableSeats: 0,
    price: 150,
    status: 'active',
    notes: '',
    pendingRequests: 0,
    passengers: [
      PassengerInfo(userId: 'zara@isbstudent.comsats.edu.pk', name: 'Zara', status: 'accepted'),
      PassengerInfo(userId: 'hassan@isbstudent.comsats.edu.pk', name: 'Hassan', status: 'accepted'),
    ],
  ),
  Ride(
    rideId: '5',
    driverId: 'bilal@isbstudent.comsats.edu.pk',  // ✅ Changed
    driverName: 'Bilal Ahmed',
    driverPhoto: '',
    driverRating: 4.9,
    from: 'Girls Hostel',
    destination: 'F-10',
    date: '2026-04-11',
    time: '09:00 AM',
    totalSeats: 4,
    availableSeats: 2,
    price: 180,
    status: 'scheduled',
    notes: 'Female only',
    pendingRequests: 2,
    passengers: [
      PassengerInfo(userId: 'ayesha@isbstudent.comsats.edu.pk', name: 'Ayesha', status: 'pending'),
      PassengerInfo(userId: 'maria@isbstudent.comsats.edu.pk', name: 'Maria', status: 'pending'),
    ],
  ),
];

// Helper functions
List<Ride> getRidesByDriverId(String driverId) {
  return dummyRides.where((ride) => ride.driverId == driverId).toList();
}

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

void addNewRide(Ride newRide) {
  dummyRides.add(newRide);
}

void updateRide(Ride updatedRide) {
  final index = dummyRides.indexWhere((r) => r.rideId == updatedRide.rideId);
  if (index != -1) {
    dummyRides[index] = updatedRide;
  }
}

void deleteRide(String rideId) {
  dummyRides.removeWhere((r) => r.rideId == rideId);
}

void updateAvailableSeats(String rideId, int newAvailableSeats) {
  final index = dummyRides.indexWhere((r) => r.rideId == rideId);
  if (index != -1) {
    final updatedRide = dummyRides[index].copyWith(availableSeats: newAvailableSeats);
    dummyRides[index] = updatedRide;
  }
}

void updatePassengerStatus(String rideId, String passengerName, String newStatus) {
  final index = dummyRides.indexWhere((r) => r.rideId == rideId);
  if (index != -1) {
    final passengerIndex = dummyRides[index].passengers.indexWhere((p) => p.name == passengerName);
    if (passengerIndex != -1) {
      final updatedPassengers = List<PassengerInfo>.from(dummyRides[index].passengers);
      updatedPassengers[passengerIndex] = PassengerInfo(
        userId: updatedPassengers[passengerIndex].userId,
        name: updatedPassengers[passengerIndex].name,
        status: newStatus,
      );
      final updatedRide = dummyRides[index].copyWith(passengers: updatedPassengers);
      dummyRides[index] = updatedRide;
    }
  }
}