import 'package:flutter/material.dart';
import '../../data/dummy_rides.dart';
import '../../models/ride_model.dart';
import '../../data/dummy_users.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {

  List<Map<String, dynamic>> myRequests = [];

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  void loadRequests() {
    final currentUser = getCurrentUser();
    final userId = currentUser?['email'];

    List<Map<String, dynamic>> temp = [];

    for (var ride in dummyRides) {
      for (var passenger in ride.passengers) {
        if (passenger.userId == userId) {
          temp.add({
            "ride": ride,
            "request": passenger,
          });
        }
      }
    }

    setState(() {
      myRequests = temp;
    });
  }

  // void cancelRequest(Ride ride, PassengerInfo request) {
  //   setState(() {
  //     ride.passengers.removeWhere((p) => p.userId == request.userId);
  //     ride.availableSeats = (ride.availableSeats ?? 0) + 1;
  //   });
  //
  //   loadRequests();
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Request cancelled")),
  //   );
  // }

  //.................................................
  void cancelRequest(Ride ride, PassengerInfo request) {
    final rideIndex = dummyRides.indexWhere((r) => r.rideId == ride.rideId);

    if (rideIndex != -1) {
      final currentRide = dummyRides[rideIndex];

      // ✅ Explicit type declaration
      List<PassengerInfo> updatedPassengers = List.from(currentRide.passengers);
      updatedPassengers.removeWhere((p) => p.userId == request.userId);

      final updatedRide = currentRide.copyWith(
        passengers: updatedPassengers,
        pendingRequests: currentRide.pendingRequests - 1,
      );

      dummyRides[rideIndex] = updatedRide;

      loadRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request cancelled")),
      );
    }
  }
  Color getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Requests")),

      body: myRequests.isEmpty
          ? const Center(child: Text("No requests yet"))
          : ListView.builder(
        itemCount: myRequests.length,
        itemBuilder: (context, index) {
          final ride = myRequests[index]["ride"] as Ride;
          final request = myRequests[index]["request"] as PassengerInfo;

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Driver
                  Text("Driver: ${ride.driverName}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 6),

                  // Route
                  Text("${ride.from} → ${ride.destination}"),

                  const SizedBox(height: 6),

                  // Status
                  Row(
                    children: [
                      const Text("Status: "),
                      Text(
                        request.status,
                        style: TextStyle(
                          color: getStatusColor(request.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Cancel Button
                  if (request.status == "pending")
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            cancelRequest(ride, request),
                        child: const Text(
                          "Cancel Request",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}