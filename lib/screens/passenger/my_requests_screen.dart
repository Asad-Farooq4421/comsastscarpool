import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';
import '../../services/user_service.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final RideService _rideService = RideService();
  final UserService _userService = UserService();

  List<Ride> _myRequests = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid;
      });
      await _loadRequests();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRequests() async {
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get all rides where user is a passenger (has a request)
      final allRides = await _rideService.getAllRides();

      final userRequests = allRides.where((ride) {
        return ride.passengers.any((passenger) => passenger.userId == _currentUserId);
      }).toList();

      setState(() {
        _myRequests = userRequests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelRequest(Ride ride) async {
    if (_currentUserId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: Text(
          'Are you sure you want to cancel your request for ride from ${ride.from} to ${ride.destination}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Remove user from passengers list
      final updatedPassengers = ride.passengers
          .where((p) => p.userId != _currentUserId)
          .toList();

      final newAvailableSeats = ride.availableSeats + 1;

      await _rideService.updateRide(
        ride.copyWith(
          passengers: updatedPassengers,
          availableSeats: newAvailableSeats,
        ),
      );

      await _loadRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to get passenger status without causing null return issues
  PassengerInfo? _getPassengerStatus(Ride ride) {
    if (_currentUserId == null) return null;

    for (var passenger in ride.passengers) {
      if (passenger.userId == _currentUserId) {
        return passenger;
      }
    }
    return null;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "accepted":
        return "Accepted ✓";
      case "rejected":
        return "Rejected ✗";
      default:
        return "Pending ⏳";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Requests")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myRequests.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.request_page, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No requests yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              "Your ride requests will appear here",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _myRequests.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final ride = _myRequests[index];
          final passenger = _getPassengerStatus(ride);

          if (passenger == null) return const SizedBox.shrink();

          final status = passenger.status;
          final isPendingOrAccepted = status == "pending" || status == "accepted";

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Text(
                          ride.driverName.isNotEmpty ? ride.driverName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.driverName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Driver",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Route
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 10, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ride.from)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Container(
                      width: 2,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ride.destination)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date & Time
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(ride.date),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(ride.time),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price and Seats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs. ${ride.price}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (isPendingOrAccepted) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _cancelRequest(ride),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text("Cancel Request"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}