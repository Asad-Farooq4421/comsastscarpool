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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ride = ModalRoute.of(context)!.settings.arguments as Ride;
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
              '${pendingPassengers.length} pending',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                  onPressed: () {},
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
                  onPressed: ride.availableSeats > 0 
                      ? () => _handleRequest(passenger.userId, true)
                      : null, // Disable if no seats left
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(ride.availableSeats > 0 ? 'Accept' : 'Full'),
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
                  onPressed: () => _handleRequest(passenger.userId, false),
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

  void _handleRequest(String passengerId, bool accept) {
    // 1. Logic to update global dummy data and local state
    final rideIndex = dummyRides.indexWhere((r) => r.rideId == ride.rideId);
    
    if (rideIndex != -1) {
      setState(() {
        List<PassengerInfo> updatedPassengers = List.from(ride.passengers);
        int passengerIndex = updatedPassengers.indexWhere((p) => p.userId == passengerId);
        
        if (passengerIndex != -1) {
          if (accept && ride.availableSeats > 0) {
            // ACCEPT LOGIC
            // Update passenger status
            updatedPassengers[passengerIndex] = updatedPassengers[passengerIndex].copyWith(status: 'accepted');
            
            // Decrease available seats globally and locally
            int newAvailableSeats = ride.availableSeats - 1;
            
            ride = ride.copyWith(
              availableSeats: newAvailableSeats,
              passengers: updatedPassengers,
            );
            
            // Persist to dummyRides
            dummyRides[rideIndex] = ride;
          } else {
            // DECLINE LOGIC
            updatedPassengers[passengerIndex] = updatedPassengers[passengerIndex].copyWith(status: 'declined');
            
            ride = ride.copyWith(passengers: updatedPassengers);
            dummyRides[rideIndex] = ride;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Passenger Accepted! Seats decreased.' : 'Request Declined'),
          backgroundColor: accept ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
