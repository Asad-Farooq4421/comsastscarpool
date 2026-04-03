import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/ride_model.dart';
import '../../data/dummy_users.dart';
import '../../data/dummy_rides.dart';

class RideRequestsInboxScreen extends StatefulWidget {
  const RideRequestsInboxScreen({super.key});

  @override
  State<RideRequestsInboxScreen> createState() => _RideRequestsInboxScreenState();
}

class _RideRequestsInboxScreenState extends State<RideRequestsInboxScreen> {
  late Ride ride;
  int currentPendingCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ride = ModalRoute.of(context)!.settings.arguments as Ride;
    currentPendingCount = ride.pendingRequests;
  }

  @override
  Widget build(BuildContext context) {
    // Filter pending passengers from the ride model
    final pendingPassengers = ride.passengers.where((p) => p.status == 'pending').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Ride Requests'),
            Text(
              '$currentPendingCount pending',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // Return true to refresh
        ),
      ),
      body: Column(
        children: [
          // 📍 Ride Info Header
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.radio_button_checked, size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ride.from,
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Container(width: 2, height: 16, color: Colors.grey.shade300),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ride.destination,
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${ride.date} • ${ride.time}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      '${ride.availableSeats} seats left',
                      style: AppTextStyles.caption.copyWith(
                        color: ride.availableSeats == 0 ? Colors.red : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pending Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 🧾 Request List
          Expanded(
            child: pendingPassengers.isEmpty
                ? const Center(child: Text('No pending requests'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: pendingPassengers.length,
              itemBuilder: (context, index) {
                final passengerInfo = pendingPassengers[index];
                final userData = dummyUsers.firstWhere(
                      (u) => u['name'] == passengerInfo.name,
                  orElse: () => dummyUsers[0],
                );

                return _buildRequestCard(passengerInfo, userData);
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Rides'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildRequestCard(PassengerInfo passenger, Map<String, dynamic> userData) {
    final bool isSeatsAvailable = ride.availableSeats > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  passenger.name[0],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passenger.name,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${userData['passengerRating']} • ${userData['ridesAsPassenger']} rides',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    Text(
                      'Requested 1 hour ago',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _showPassengerProfile(userData),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: (isSeatsAvailable && currentPendingCount > 0)
                      ? () => _handleRequest(passenger, true)
                      : null,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(!isSeatsAvailable ? 'Full' : 'Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: IconButton(
                  onPressed: () => _handleRequest(passenger, false),
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleRequest(PassengerInfo passenger, bool accept) {
    final rideIndex = dummyRides.indexWhere((r) => r.rideId == ride.rideId);

    if (rideIndex != -1) {
      setState(() {
        // Get current ride from dummyRides
        Ride currentRide = dummyRides[rideIndex];

        // Update passengers list
        List<PassengerInfo> updatedPassengers = List.from(currentRide.passengers);
        int passengerIndex = updatedPassengers.indexWhere((p) => p.userId == passenger.userId);

        if (passengerIndex != -1) {
          if (accept && currentRide.availableSeats > 0) {
            // ACCEPT LOGIC
            updatedPassengers[passengerIndex] = updatedPassengers[passengerIndex].copyWith(
                status: 'accepted'
            );

            // Update ride with new values
            currentRide = currentRide.copyWith(
              availableSeats: currentRide.availableSeats - 1,
              passengers: updatedPassengers,
              pendingRequests: currentRide.pendingRequests - 1,
            );

            // Persist to dummyRides
            dummyRides[rideIndex] = currentRide;

            // Update local state
            ride = currentRide;
            currentPendingCount = ride.pendingRequests;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Passenger Accepted! Seats decreased.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (!accept) {
            // DECLINE LOGIC
            updatedPassengers[passengerIndex] = updatedPassengers[passengerIndex].copyWith(
                status: 'declined'
            );

            // Update ride with new values (seats unchanged)
            currentRide = currentRide.copyWith(
              passengers: updatedPassengers,
              pendingRequests: currentRide.pendingRequests - 1,
            );

            // Persist to dummyRides
            dummyRides[rideIndex] = currentRide;

            // Update local state
            ride = currentRide;
            currentPendingCount = ride.pendingRequests;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request Declined'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      });

      // If no pending requests left, go back after 1 second
      if (currentPendingCount == 0) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    }
  }

  void _showPassengerProfile(Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(userData['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📞 ${userData['phone']}'),
            const SizedBox(height: 8),
            Text('⭐ Rating: ${userData['passengerRating']}'),
            const SizedBox(height: 8),
            Text('🚗 Rides taken: ${userData['ridesAsPassenger']}'),
            const SizedBox(height: 8),
            Text('📧 ${userData['email']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
