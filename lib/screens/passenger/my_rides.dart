import 'package:flutter/material.dart';
import '../../data/dummy_users.dart';
import '../../models/ride_model.dart';


class MyRidesScreen extends StatefulWidget {

  final List<Ride> allRides;

  const MyRidesScreen({super.key, required this.allRides});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  bool showUpcoming = true;

  // ✅ FILTER USING NAME ONLY
  List<Ride> get userRides {
    final user = getCurrentUser();
    if (user == null) return [];

    String name = user['name'];
    bool isDriver = user['isDriver'] ?? false;

    return widget.allRides.where((ride) {
      bool isRideDriver = isDriver && ride.driverName == name;

      bool isPassenger = ride.passengers.any(
            (p) => p.name == name,
      );

      return isRideDriver || isPassenger;
    }).toList();
  }

  List<Ride> get upcomingRides =>
      userRides.where((r) => r.isActive).toList();

  List<Ride> get historyRides =>
      userRides.where((r) => !r.isActive).toList();

  @override
  Widget build(BuildContext context) {
    final rides = showUpcoming ? upcomingRides : historyRides;

    return Scaffold(

      body: Column(

        children: [

          _header(),
          _tabs(),
          Expanded(
            child: rides.isEmpty
                ? const Center(child: Text("No rides found"))
                : ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                return RideCard(ride: rides[index]);
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
          _tabButton("History", false),
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

  const RideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // ✅ fixed
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusChip(ride.isActive ? "Upcoming" : "Completed"),
                Text(ride.date, style: const TextStyle(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 10),

            // DRIVER
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(ride.driverPhoto),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.driverName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text("Driver"),
                  ],
                )
              ],
            ),

            const SizedBox(height: 12),

            // ROUTE
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

            // TIME + PRICE
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
                Text(
                  "Rs. ${ride.price}",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}