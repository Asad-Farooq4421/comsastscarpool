import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ride_model.dart';

class RideService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new ride
  Future<void> createRide(Ride ride) async {
    try {
      final String rideId = _databaseRef.child('rides').push().key!;
      final updatedRide = ride.copyWith(rideId: rideId);
      await _databaseRef.child('rides/$rideId').set(updatedRide.toJson());
    } catch (e) {
      throw Exception('Failed to create ride: $e');
    }
  }

  // Get all rides (for searching)
  Future<List<Ride>> getAllRides() async {
    try {
      DatabaseEvent event = await _databaseRef.child('rides').once();
      DataSnapshot snapshot = event.snapshot;

      List<Ride> rides = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> ridesMap = snapshot.value as Map;
        ridesMap.forEach((key, value) {
          Map<String, dynamic> rideData = Map<String, dynamic>.from(value);
          Ride ride = Ride.fromJson(rideData, key.toString());
          rides.add(ride);
        });
      }

      return rides;
    } catch (e) {
      print('Error getting rides: $e');
      return [];
    }
  }

  // Get available rides (not full, active)
  Future<List<Ride>> getAvailableRides() async {
    final allRides = await getAllRides();
    return allRides.where((ride) =>
    ride.availableSeats > 0 && ride.isActive
    ).toList();
  }

  // Get rides by driver ID
  Future<List<Ride>> getRidesByDriverId(String driverId) async {
    try {
      final Query query = _databaseRef.child('rides').orderByChild('driverId').equalTo(driverId);
      DatabaseEvent event = await query.once();
      DataSnapshot snapshot = event.snapshot;

      List<Ride> rides = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> ridesMap = snapshot.value as Map;
        ridesMap.forEach((key, value) {
          Map<String, dynamic> rideData = Map<String, dynamic>.from(value);
          Ride ride = Ride.fromJson(rideData, key.toString());
          rides.add(ride);
        });
      }

      return rides;
    } catch (e) {
      print('Error getting driver rides: $e');
      return [];
    }
  }

  // Get rides where user is a passenger
  Future<List<Ride>> getRidesByPassengerId(String passengerId) async {
    try {
      List<Ride> allRides = await getAllRides();
      return allRides.where((ride) {
        return ride.passengers.any((p) => p.userId == passengerId);
      }).toList();
    } catch (e) {
      print('Error getting passenger rides: $e');
      return [];
    }
  }

  // Get ride by ID
  Future<Ride?> getRideById(String rideId) async {
    try {
      DatabaseEvent event = await _databaseRef.child('rides/$rideId').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<String, dynamic> rideData = Map<String, dynamic>.from(snapshot.value as Map);
        return Ride.fromJson(rideData, rideId);
      }
    } catch (e) {
      print('Error getting ride: $e');
    }
    return null;
  }

  // Update ride
  Future<void> updateRide(Ride ride) async {
    try {
      await _databaseRef.child('rides/${ride.rideId}').update(ride.toJson());
    } catch (e) {
      throw Exception('Failed to update ride: $e');
    }
  }

  // Update available seats
  Future<void> updateAvailableSeats(String rideId, int newAvailableSeats) async {
    try {
      await _databaseRef.child('rides/$rideId/availableSeats').set(newAvailableSeats);
    } catch (e) {
      throw Exception('Failed to update seats: $e');
    }
  }

  // Request to join a ride (add passenger with pending status)
  Future<void> requestToJoinRide(String rideId, String userId, String userName) async {
    try {
      final ride = await getRideById(rideId);
      if (ride != null) {
        // Check if user already requested
        final alreadyRequested = ride.passengers.any((p) => p.userId == userId);
        if (alreadyRequested) {
          throw Exception('You have already requested this ride');
        }

        // Check if seats are available
        if (ride.availableSeats <= 0) {
          throw Exception('No seats available for this ride');
        }

        final newPassenger = PassengerInfo(
          userId: userId,
          name: userName,
          status: 'pending',
        );

        final updatedPassengers = List<PassengerInfo>.from(ride.passengers);
        updatedPassengers.add(newPassenger);

        // Update pending requests count
        final newPendingRequests = ride.pendingRequests + 1;

        await _databaseRef.child('rides/$rideId').update({
          'passengers': updatedPassengers.map((p) => p.toJson()).toList(),
          'pendingRequests': newPendingRequests,
        });
      }
    } catch (e) {
      throw Exception('Failed to request ride: $e');
    }
  }

  // Accept a passenger request
  Future<void> acceptPassenger(String rideId, String userId) async {
    try {
      final ride = await getRideById(rideId);
      if (ride != null) {
        final updatedPassengers = ride.passengers.map((p) {
          if (p.userId == userId) {
            return p.copyWith(status: 'accepted');
          }
          return p;
        }).toList();

        // Decrement available seats and pending requests
        final newAvailableSeats = ride.availableSeats - 1;
        final newPendingRequests = ride.pendingRequests - 1;

        await _databaseRef.child('rides/$rideId').update({
          'passengers': updatedPassengers.map((p) => p.toJson()).toList(),
          'availableSeats': newAvailableSeats,
          'pendingRequests': newPendingRequests > 0 ? newPendingRequests : 0,
        });
      }
    } catch (e) {
      throw Exception('Failed to accept passenger: $e');
    }
  }

  // Reject a passenger request
  Future<void> rejectPassenger(String rideId, String userId) async {
    try {
      final ride = await getRideById(rideId);
      if (ride != null) {
        final updatedPassengers = ride.passengers.where((p) => p.userId != userId).toList();
        final newPendingRequests = ride.pendingRequests - 1;

        await _databaseRef.child('rides/$rideId').update({
          'passengers': updatedPassengers.map((p) => p.toJson()).toList(),
          'pendingRequests': newPendingRequests > 0 ? newPendingRequests : 0,
        });
      }
    } catch (e) {
      throw Exception('Failed to reject passenger: $e');
    }
  }

  // Cancel a ride (driver)
  Future<void> cancelRide(String rideId) async {
    try {
      await _databaseRef.child('rides/$rideId/status').set('cancelled');
    } catch (e) {
      throw Exception('Failed to cancel ride: $e');
    }
  }

  // Delete a ride
  Future<void> deleteRide(String rideId) async {
    try {
      await _databaseRef.child('rides/$rideId').remove();
    } catch (e) {
      throw Exception('Failed to delete ride: $e');
    }
  }

  // Get pending ride requests for a driver
  Future<List<Ride>> getPendingRideRequests(String driverId) async {
    try {
      final driverRides = await getRidesByDriverId(driverId);
      return driverRides.where((ride) {
        return ride.passengers.any((p) => p.status == 'pending');
      }).toList();
    } catch (e) {
      print('Error getting pending requests: $e');
      return [];
    }
  }

  // Get accepted rides where user is passenger
  Future<List<Ride>> getAcceptedRidesForPassenger(String passengerId) async {
    final allRides = await getAllRides();
    return allRides.where((ride) {
      return ride.passengers.any((p) => p.userId == passengerId && p.status == 'accepted');
    }).toList();
  }

  // Get rides near a location (within radius in km)
  Future<List<Ride>> getRidesNearLocation(double latitude, double longitude, double radiusKm) async {
    final allRides = await getAllRides();
    final nearbyRides = <Ride>[];

    for (final ride in allRides) {
      if (ride.pickupLatitude != null && ride.pickupLongitude != null &&
          ride.availableSeats > 0 && ride.isActive) {

        final distance = _calculateDistance(
          latitude, longitude,
          ride.pickupLatitude!, ride.pickupLongitude!,
        );

        if (distance <= radiusKm) {
          nearbyRides.add(ride);
        }
      }
    }

    // Sort by distance
    nearbyRides.sort((a, b) {
      final distanceA = _calculateDistance(
        latitude, longitude,
        a.pickupLatitude!, a.pickupLongitude!,
      );
      final distanceB = _calculateDistance(
        latitude, longitude,
        b.pickupLatitude!, b.pickupLongitude!,
      );
      return distanceA.compareTo(distanceB);
    });

    return nearbyRides;
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Stream of rides (real-time updates)
  Stream<List<Ride>> streamAllRides() {
    return _databaseRef.child('rides').onValue.map((event) {
      List<Ride> rides = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> ridesMap = event.snapshot.value as Map;
        ridesMap.forEach((key, value) {
          Map<String, dynamic> rideData = Map<String, dynamic>.from(value);
          rides.add(Ride.fromJson(rideData, key.toString()));
        });
      }
      return rides;
    });
  }

  // Stream rides by driver (real-time)
  Stream<List<Ride>> streamRidesByDriver(String driverId) {
    return _databaseRef.child('rides').onValue.map((event) {
      List<Ride> rides = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> ridesMap = event.snapshot.value as Map;
        ridesMap.forEach((key, value) {
          Map<String, dynamic> rideData = Map<String, dynamic>.from(value);
          if (rideData['driverId'] == driverId) {
            rides.add(Ride.fromJson(rideData, key.toString()));
          }
        });
      }
      return rides;
    });
  }

  // Stream rides near a location (real-time)
  Stream<List<Ride>> streamRidesNearLocation(double latitude, double longitude, double radiusKm) {
    return _databaseRef.child('rides').onValue.map((event) {
      final List<Ride> nearbyRides = [];

      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> ridesMap = event.snapshot.value as Map;

        ridesMap.forEach((key, value) {
          final Map<String, dynamic> rideData = Map<String, dynamic>.from(value);
          final ride = Ride.fromJson(rideData, key.toString());

          if (ride.pickupLatitude != null && ride.pickupLongitude != null &&
              ride.availableSeats > 0 && ride.isActive) {

            final distance = _calculateDistance(
              latitude, longitude,
              ride.pickupLatitude!, ride.pickupLongitude!,
            );

            if (distance <= radiusKm) {
              nearbyRides.add(ride);
            }
          }
        });

        // Sort by distance
        nearbyRides.sort((a, b) {
          final distanceA = _calculateDistance(
            latitude, longitude,
            a.pickupLatitude!, a.pickupLongitude!,
          );
          final distanceB = _calculateDistance(
            latitude, longitude,
            b.pickupLatitude!, b.pickupLongitude!,
          );
          return distanceA.compareTo(distanceB);
        });
      }

      return nearbyRides;
    });
  }
}