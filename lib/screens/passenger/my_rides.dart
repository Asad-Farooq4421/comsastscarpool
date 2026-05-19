import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';
import '../../services/user_service.dart';

class MyRidesScreen extends StatefulWidget {
  final List<Ride> allRides;
  final VoidCallback? onRideUpdate;

  const MyRidesScreen({
    super.key,
    required this.allRides,
    this.onRideUpdate,
  });

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  bool showUpcoming = true;
  bool _isLoading = false;
  final RideService _rideService = RideService();
  final UserService _userService = UserService();

  String? _currentUserId;
  bool _isDriver = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userProfile = await _userService.getUserProfile(currentUser.uid);
      setState(() {
        _currentUserId = currentUser.uid;
        _isDriver = userProfile?.isDriver ?? false;
      });
    }
  }

  /// Safe upcoming check (includes today properly)
  bool isUpcomingRide(Ride ride) {
    try {
      final rideDate = DateTime.parse(ride.date);
      final now = DateTime.now();

      // Compare only date (ignore time)
      final today = DateTime(now.year, now.month, now.day);
      final rideDay = DateTime(rideDate.year, rideDate.month, rideDate.day);

      return rideDay.isAfter(today) || rideDay.isAtSameMomentAs(today);
    } catch (e) {
      return false; // fallback if date is invalid
    }
  }

  /// Get current user rides
  List<Ride> get userRides {
    if (_currentUserId == null) return [];

    return widget.allRides.where((ride) {
      // Check if user is the driver
      final isRideDriver = _isDriver && ride.driverId == _currentUserId;

      // Check if user is a passenger
      final isPassenger = ride.passengers.any(
            (p) => p.userId == _currentUserId,
      );

      return isRideDriver || isPassenger;
    }).toList();
  }

  /// Upcoming rides
  List<Ride> get upcomingRides =>
      userRides.where((r) => isUpcomingRide(r)).toList();

  /// History rides
  List<Ride> get historyRides =>
      userRides.where((r) => !isUpcomingRide(r)).toList();

  Future<void> _cancelRide(Ride ride) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: Text(
          'Are you sure you want to cancel your ride from ${ride.from} to ${ride.destination}?',
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

    if (confirm == true && _currentUserId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Remove user from passengers list
        final updatedPassengers = ride.passengers
            .where((p) => p.userId != _currentUserId)
            .toList();

        // Update available seats (add back one seat)
        final newAvailableSeats = ride.availableSeats + 1;

        await _rideService.updateRide(
          ride.copyWith(
            passengers: updatedPassengers,
            availableSeats: newAvailableSeats,
          ),
        );

        widget.onRideUpdate?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride cancelled successfully'),
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
  }

  @override
  Widget build(BuildContext context) {
    final rides = showUpcoming ? upcomingRides : historyRides;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _header(),
          _tabs(),
          Expanded(
            child: rides.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No rides found"),
                  SizedBox(height: 8),
                  Text(
                    "Your rides will appear here",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                return RideCard(
                  ride: rides[index],
                  isUpcoming: isUpcomingRide(rides[index]),
                  currentUserId: _currentUserId,
                  onCancel: () => _cancelRide(rides[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.green],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Rides",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "View your upcoming and past rides",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tabButton("Upcoming (${upcomingRides.length})", true),
          _tabButton("History (${historyRides.length})", false),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool isUpcomingTab) {
    final isSelected = showUpcoming == isUpcomingTab;

    return GestureDetector(
      onTap: () {
        setState(() {
          showUpcoming = isUpcomingTab;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final Ride ride;
  final bool isUpcoming;
  final String? currentUserId;
  final VoidCallback? onCancel;

  const RideCard({
    super.key,
    required this.ride,
    required this.isUpcoming,
    this.currentUserId,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isPassenger = currentUserId != null &&
        ride.passengers.any((p) => p.userId == currentUserId);
    final isDriver = ride.driverId == currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusChip(isUpcoming ? "Upcoming" : "Completed"),
                Text(
                  ride.date,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                CircleAvatar(
                  backgroundImage: ride.driverPhoto.isNotEmpty
                      ? NetworkImage(ride.driverPhoto)
                      : null,
                  child: ride.driverPhoto.isEmpty
                      ? Text(ride.driverName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.driverName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Driver"),
                  ],
                ),
                const Spacer(),
                if (isDriver)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "You are Driver",
                      style: TextStyle(fontSize: 10, color: Colors.orange),
                    ),
                  ),
                if (isPassenger)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Passenger",
                      style: TextStyle(fontSize: 10, color: Colors.green),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.blue),
                const SizedBox(width: 6),
                Expanded(child: Text(ride.from)),
              ],
            ),

            Row(
              children: [
                const SizedBox(width: 6),
                Container(width: 1, height: 20, color: Colors.grey),
              ],
            ),

            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(child: Text(ride.destination)),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 5),
                    Text(ride.time),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Rs. ${ride.price}",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isUpcoming && isPassenger)
                      const SizedBox(width: 16),
                    if (isUpcoming && isPassenger)
                      IconButton(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: text == "Upcoming"
            ? Colors.blue.shade100
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}