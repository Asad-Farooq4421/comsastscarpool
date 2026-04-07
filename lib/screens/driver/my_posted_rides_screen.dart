import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/ride_model.dart';
import '../../data/dummy_rides.dart';
import '../../data/dummy_users.dart';
import '../../widgets/custom_button.dart';
import '../../utils/routes.dart';

class MyPostedRidesScreen extends StatefulWidget {
  const MyPostedRidesScreen({super.key});

  @override
  State<MyPostedRidesScreen> createState() => _MyPostedRidesScreenState();
}

class _MyPostedRidesScreenState extends State<MyPostedRidesScreen> {
  List<Ride> myRides = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyRides();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when coming back from edit/post
    _loadMyRides();
  }

  void _loadMyRides() {
    final currentDriverId = getCurrentUserId(); // Returns email of logged-in user

    setState(() {
      myRides = dummyRides.where((ride) =>
      ride.driverId == currentDriverId
      ).toList();
      isLoading = false;
    });
  }

  int get totalEarnings {
    int earnings = 0;
    for (var ride in myRides) {
      earnings += ride.filledSeats * ride.price;
    }
    return earnings;
  }

  double get averageRating {
    if (myRides.isEmpty) return 0;
    double total = 0;
    for (var ride in myRides) {
      total += ride.driverRating;
    }
    return total / myRides.length;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getCurrentUser();
    final driverName = currentUser?['name'] ?? 'Driver';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Posted Rides'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        actions: [
          // Post Ride Button in AppBar
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, AppRoutes.postRide);
              if (result == true) {
                _loadMyRides(); // Refresh list
              }
            },
            tooltip: 'Post New Ride',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myRides.isEmpty
          ? _buildEmptyState(driverName)
          : Column(
        children: [
          // Stats Summary
          _buildStatsSummary(),
          const SizedBox(height: 8),

          // Rides List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myRides.length,
              itemBuilder: (context, index) {
                final ride = myRides[index];
                return _buildRideCard(ride);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.directions_car,
            value: '${myRides.length}',
            label: 'Total Rides',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withAlpha(77),
          ),
          _buildStatItem(
            icon: Icons.star,
            value: averageRating.toStringAsFixed(1),
            label: 'Avg Rating',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withAlpha(77),
          ),
          _buildStatItem(
            icon: Icons.attach_money,
            value: 'Rs. $totalEarnings',
            label: 'Total Earnings',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String driverName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car,
                size: 50,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Posted Rides Yet!',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Hello $driverName, start earning by posting your first ride.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Post Your First Ride',
              onPressed: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.postRide);
                if (result == true) {
                  _loadMyRides();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(Ride ride) {
    final bool hasPendingRequests = ride.pendingRequests > 0;
    final bool isActive = ride.status == 'scheduled' || ride.status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badges Row
          Row(
            children: [
              _buildStatusBadge(ride.status),
              const SizedBox(width: 8),
              if (hasPendingRequests)
                _buildPendingRequestsBadge(ride.pendingRequests),
              const Spacer(),
              if (!isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Route (From → To in single line)
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride.from,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 1,
              height: 16,
              color: Colors.grey.shade300,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride.destination,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details Row: Time | Seats | Price
          Row(
            children: [
              _buildDetailChip(Icons.access_time, ride.time),
              const SizedBox(width: 12),
              _buildDetailChip(
                Icons.people,
                '${ride.filledSeats}/${ride.totalSeats} filled',
              ),
              const SizedBox(width: 12),
              _buildDetailChip(
                Icons.attach_money,
                'Rs. ${ride.price}/seat',
                isHighlighted: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              if (hasPendingRequests)
                Expanded(
                  child: CustomButton(
                    text: 'Requests',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.rideRequests,
                        arguments: ride,
                      ).then((_) => _loadMyRides());
                    },
                    backgroundColor: AppColors.primary,
                  ),
                ),
              if (hasPendingRequests) const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: 'Edit',
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editRide,
                      arguments: ride,
                    ).then((_) => _loadMyRides());
                  },
                  isOutlined: false,  // ✅ Solid button
                  backgroundColor: AppColors.primary,  // ✅ Same as Request button
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () {
                    _showDeleteConfirmation(ride);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'scheduled':
        color = Colors.green;
        text = 'Scheduled';
        break;
      case 'active':
        color = Colors.blue;
        text = 'Active';
        break;
      case 'completed':
        color = Colors.grey;
        text = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPendingRequestsBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count New ${count == 1 ? 'Request' : 'Requests'}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, {bool isHighlighted = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: isHighlighted ? AppColors.primary : Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isHighlighted ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(Ride ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ride'),
        content: const Text('Are you sure you want to delete this ride? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Use store logic to delete
              deleteRide(ride.rideId);
              Navigator.pop(context);
              _loadMyRides();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ride deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}