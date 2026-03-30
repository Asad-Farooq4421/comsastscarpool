import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/ride_requests.dart';
import '../../models/request_model.dart';
import '../../models/ride_model.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../widgets/app_bottom_nav.dart';

class RideDetailsScreen extends StatefulWidget {
  final Ride ride;

  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  RideRequest? myRequest;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadRequest();

    // Auto refresh every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _loadRequest();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 🔍 Find user's request
  void _loadRequest() {
    final matches = rideRequests.where(
          (req) =>
      req.ride == widget.ride &&
          req.passengerName == currentUser,
    );

    setState(() {
      myRequest = matches.isNotEmpty ? matches.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;

    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
      ),

      appBar: AppBar(
        title: const Text("Ride Details"),
      ),

      body: Column(
        children: [
          _header(ride),
          Expanded(child: _details(context, ride)),
        ],
      ),
    );
  }

  // HEADER
  Widget _header(Ride ride) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF90A4AE), Color(0xFF66BB6A)],
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.location_on, size: 40, color: Colors.blue),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ride.time,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DETAILS
  Widget _details(BuildContext context, Ride ride) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _routeSection(ride),
          const SizedBox(height: 20),
          _infoRow(ride),
          const Divider(height: 30),
          _driverSection(ride),

          // 🔥 STATUS BAR
          if (myRequest != null) ...[
            const SizedBox(height: 20),
            _statusWidget(myRequest!),
          ],

          const Spacer(),
          _button(context, ride),
        ],
      ),
    );
  }

  // ROUTE
  Widget _routeSection(Ride ride) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.blue),
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.grey.shade300,
                ),
              ),
              const Icon(Icons.location_on,
                  size: 18, color: Colors.green),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _locationTile("From", ride.from),
                _locationTile("To", ride.destination),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyLarge),
      ],
    );
  }

  // INFO
  Widget _infoRow(Ride ride) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(ride.date, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        Row(
          children: [
            Icon(Icons.attach_money,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              "Rs. ${ride.price}/seat",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // DRIVER
  Widget _driverSection(Ride ride) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Driver", style: AppTextStyles.heading3),
            Text("View Profile",
                style: TextStyle(color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const CircleAvatar(radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ride.driverName,
                      style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    "${ride.availableSeats ?? 0} seats available",
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STATUS UI
  Widget _statusWidget(RideRequest request) {
    Color color;

    switch (request.status) {
      case "accepted":
        color = Colors.green;
        break;
      case "rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: color),
          const SizedBox(width: 8),
          Text(
            "Request ${request.status}",
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  // BUTTON
  Widget _button(BuildContext context, Ride ride) {
    final isRequested = myRequest != null;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
        isRequested ? Colors.red : AppColors.secondary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        if (isRequested) {
          _cancelRequest(context);
        } else {
          _requestRide(context, ride);
        }
      },
      child: Text(
        isRequested ? "Cancel Request" : "Request Ride",
        style: AppTextStyles.button,
      ),
    );
  }

  //  REQUEST
  void _requestRide(BuildContext context, Ride ride) {
    if ((ride.availableSeats ?? 0) <= 0) {
      _showSnack("No seats available");
      return;
    }

    final request = RideRequest(
      ride: ride,
      passengerName: currentUser,
      status: "pending",
    );

    rideRequests.add(request);
    ride.availableSeats = (ride.availableSeats ?? 1) - 1;

    setState(() {
      myRequest = request;
    });

    _showSnack("Request sent");
  }

  // CANCEL
  void _cancelRequest(BuildContext context) {
    rideRequests.removeWhere(
          (req) =>
      req.ride == widget.ride &&
          req.passengerName == currentUser,
    );

    widget.ride.availableSeats =
        (widget.ride.availableSeats ?? 0) + 1;

    setState(() {
      myRequest = null;
    });

    _showSnack("Request cancelled");
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}