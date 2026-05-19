import 'package:comsastscarpool/services/ride_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/request_model.dart';
import '../models/ride_model.dart';

class RideRequestService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new ride request
  Future<void> createRideRequest(RideRequest request) async {
    try {
      final String requestId = _databaseRef.child('rideRequests').push().key!;
      final updatedRequest = request.copyWith(requestId: requestId);
      await _databaseRef.child('rideRequests/$requestId').set(updatedRequest.toJson());
    } catch (e) {
      throw Exception('Failed to create ride request: $e');
    }
  }

  // Get all ride requests for a specific ride
  Future<List<RideRequest>> getRequestsForRide(String rideId) async {
    try {
      final Query query = _databaseRef
          .child('rideRequests')
          .orderByChild('rideId')
          .equalTo(rideId);

      DatabaseEvent event = await query.once();
      DataSnapshot snapshot = event.snapshot;

      List<RideRequest> requests = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> requestsMap = snapshot.value as Map;
        requestsMap.forEach((key, value) {
          Map<String, dynamic> requestData = Map<String, dynamic>.from(value);
          requests.add(RideRequest.fromJson(requestData, key.toString()));
        });
      }

      return requests;
    } catch (e) {
      print('Error getting ride requests: $e');
      return [];
    }
  }

  // Get pending requests for a driver (based on their rides)
  Future<List<RideRequest>> getPendingRequestsForDriver(String driverId) async {
    try {
      // First get all rides by this driver
      final ridesQuery = _databaseRef
          .child('rides')
          .orderByChild('driverId')
          .equalTo(driverId);

      DatabaseEvent ridesEvent = await ridesQuery.once();
      DataSnapshot ridesSnapshot = ridesEvent.snapshot;

      List<String> rideIds = [];

      if (ridesSnapshot.value != null) {
        Map<dynamic, dynamic> ridesMap = ridesSnapshot.value as Map;
        rideIds = ridesMap.keys.map((key) => key.toString()).toList();
      }

      if (rideIds.isEmpty) return [];

      // Get all ride requests for these rides
      final allRequests = await getAllRideRequests();

      return allRequests.where((request) {
        return rideIds.contains(request.rideId) && request.status == 'pending';
      }).toList();
    } catch (e) {
      print('Error getting pending requests for driver: $e');
      return [];
    }
  }

  // Get user's ride requests (passenger view)
  Future<List<RideRequest>> getUserRideRequests(String userId) async {
    try {
      final Query query = _databaseRef
          .child('rideRequests')
          .orderByChild('userId')
          .equalTo(userId);

      DatabaseEvent event = await query.once();
      DataSnapshot snapshot = event.snapshot;

      List<RideRequest> requests = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> requestsMap = snapshot.value as Map;
        requestsMap.forEach((key, value) {
          Map<String, dynamic> requestData = Map<String, dynamic>.from(value);
          requests.add(RideRequest.fromJson(requestData, key.toString()));
        });
      }

      return requests;
    } catch (e) {
      print('Error getting user requests: $e');
      return [];
    }
  }

  // Get all ride requests
  Future<List<RideRequest>> getAllRideRequests() async {
    try {
      DatabaseEvent event = await _databaseRef.child('rideRequests').once();
      DataSnapshot snapshot = event.snapshot;

      List<RideRequest> requests = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> requestsMap = snapshot.value as Map;
        requestsMap.forEach((key, value) {
          Map<String, dynamic> requestData = Map<String, dynamic>.from(value);
          requests.add(RideRequest.fromJson(requestData, key.toString()));
        });
      }

      return requests;
    } catch (e) {
      print('Error getting all requests: $e');
      return [];
    }
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _databaseRef.child('rideRequests/$requestId/status').set(newStatus);
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  // Accept a ride request
  Future<void> acceptRequest(String requestId) async {
    try {
      // Get the request first
      DatabaseEvent event = await _databaseRef.child('rideRequests/$requestId').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<String, dynamic> requestData = Map<String, dynamic>.from(snapshot.value as Map);
        final rideId = requestData['rideId'];

        // Update request status
        await updateRequestStatus(requestId, 'accepted');

        // Also update the ride's passengers list
        final rideService = RideService();
        final ride = await rideService.getRideById(rideId);

        if (ride != null) {
          final newPassenger = PassengerInfo(
            userId: requestData['userId'],
            name: requestData['passengerName'],
            status: 'accepted',
          );

          final updatedPassengers = List<PassengerInfo>.from(ride.passengers);
          updatedPassengers.add(newPassenger);

          // Decrement available seats
          final newAvailableSeats = ride.availableSeats - 1;

          await _databaseRef.child('rides/$rideId').update({
            'passengers': updatedPassengers.map((p) => p.toJson()).toList(),
            'availableSeats': newAvailableSeats,
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to accept request: $e');
    }
  }

  // Reject a ride request
  Future<void> rejectRequest(String requestId) async {
    try {
      await updateRequestStatus(requestId, 'rejected');
    } catch (e) {
      throw Exception('Failed to reject request: $e');
    }
  }

  // Cancel a request (by passenger)
  Future<void> cancelRequest(String requestId) async {
    try {
      await _databaseRef.child('rideRequests/$requestId').remove();
    } catch (e) {
      throw Exception('Failed to cancel request: $e');
    }
  }

  // Check if user has already requested a specific ride
  Future<bool> hasUserRequestedRide(String userId, String rideId) async {
    try {
      final userRequests = await getUserRideRequests(userId);
      return userRequests.any((request) =>
      request.rideId == rideId && request.status == 'pending'
      );
    } catch (e) {
      print('Error checking user request: $e');
      return false;
    }
  }

  // Stream of requests for a specific ride (real-time)
  Stream<List<RideRequest>> streamRequestsForRide(String rideId) {
    return _databaseRef
        .child('rideRequests')
        .orderByChild('rideId')
        .equalTo(rideId)
        .onValue
        .map((event) {
      List<RideRequest> requests = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> requestsMap = event.snapshot.value as Map;
        requestsMap.forEach((key, value) {
          Map<String, dynamic> requestData = Map<String, dynamic>.from(value);
          requests.add(RideRequest.fromJson(requestData, key.toString()));
        });
      }
      return requests;
    });
  }

  // Stream of pending requests for a driver (real-time)
  Stream<List<RideRequest>> streamPendingRequestsForDriver(String driverId) async* {
    // This is more complex due to needing ride IDs first
    // For real-time, you might want to use a different structure
    yield* _databaseRef.child('rideRequests').onValue.map((event) {
      List<RideRequest> allRequests = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> requestsMap = event.snapshot.value as Map;
        requestsMap.forEach((key, value) {
          Map<String, dynamic> requestData = Map<String, dynamic>.from(value);
          allRequests.add(RideRequest.fromJson(requestData, key.toString()));
        });
      }
      // Filtering will be done in the UI layer with driver's ride IDs
      return allRequests;
    });
  }
}