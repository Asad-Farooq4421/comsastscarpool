import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/ride_model.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../services/ride_service.dart';
import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import '../chat/individual_chat_screen.dart';

class RideDetailsScreen extends StatefulWidget {
  final Ride ride;
  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  Timer? _timer;
  Ride? _currentRide;
  String? _requestStatus;
  bool _isLoading = true;

  final RideService _rideService = RideService();
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();

  String? _currentUserId;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadRideData();
    _startAutoRefresh();
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userProfile = await _userService.getUserProfile(currentUser.uid);
      setState(() {
        _currentUserId = currentUser.uid;
        _currentUserName = userProfile?.name ?? currentUser.displayName ?? 'User';
      });
    }
  }

  Future<void> _loadRideData() async {
    final updatedRide = await _rideService.getRideById(widget.ride.rideId);
    if (updatedRide != null) {
      setState(() {
        _currentRide = updatedRide;
        _requestStatus = _getMyRequestStatus(updatedRide);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fixed: Use a simple loop instead of firstWhere with orElse
  String? _getMyRequestStatus(Ride ride) {
    if (_currentUserId == null) return null;

    for (var passenger in ride.passengers) {
      if (passenger.userId == _currentUserId) {
        return passenger.status;
      }
    }
    return null;
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _loadRideData();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _requestRide() async {
    if (_currentUserId == null || _currentUserName == null) {
      _showSnack("Please login to request a ride");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _rideService.requestToJoinRide(
        widget.ride.rideId,
        _currentUserId!,
        _currentUserName!,
      );

      await _loadRideData();
      _showSnack("Request sent successfully");
    } catch (e) {
      _showSnack("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelRequest() async {
    if (_currentRide == null || _currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Remove user from passengers list
      final updatedPassengers = _currentRide!.passengers
          .where((p) => p.userId != _currentUserId)
          .toList();

      final newAvailableSeats = _currentRide!.availableSeats + 1;

      await _rideService.updateRide(
        _currentRide!.copyWith(
          passengers: updatedPassengers,
          availableSeats: newAvailableSeats,
        ),
      );

      await _loadRideData();
      _showSnack("Request cancelled");
    } catch (e) {
      _showSnack("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openChat() async {
    if (_currentUserId == null) {
      _showSnack("Please login to chat");
      return;
    }

    try {
      final chatId = await _chatService.getOrCreateChat(
        widget.ride.rideId,
        widget.ride.driverId,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IndividualChatScreen(
              chatId: chatId,
              rideId: widget.ride.rideId,
              otherUserName: widget.ride.driverName,
            ),
          ),
        );
      }
    } catch (e) {
      _showSnack("Error opening chat: ${e.toString()}");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _showDriverProfile() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    widget.ride.driverName[0],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.ride.driverName,
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      widget.ride.driverRating.toString(),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _infoRowDialog("Seats", "${_currentRide?.availableSeats ?? widget.ride.availableSeats}/${widget.ride.totalSeats}"),
                if (widget.ride.notes.isNotEmpty)
                  _infoRowDialog("Notes", widget.ride.notes),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openChat();
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text("Chat with Driver"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRowDialog(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = _currentRide ?? widget.ride;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Ride Details")),
      body: _isLoading && _currentRide == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _header(ride),
          Expanded(child: _details(context, ride)),
        ],
      ),
    );
  }

  Widget _header(Ride ride) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF90A4AE), Color(0xFF66BB6A)]),
      ),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.location_on, size: 40, color: Colors.blue)),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(ride.time, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context, Ride ride) {
    final isRequested = _requestStatus != null;
    final isAccepted = _requestStatus == 'accepted';

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
          if (_requestStatus != null) ...[
            const SizedBox(height: 20),
            _statusWidget(_requestStatus!),
          ],
          const Spacer(),
          _button(context, ride, isRequested, isAccepted),
        ],
      ),
    );
  }

  Widget _routeSection(Ride ride) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.blue),
              Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
              const Icon(Icons.location_on, size: 18, color: Colors.green),
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

  Widget _infoRow(Ride ride) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(ride.date, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 4),
            Text("Rs. ${ride.price}/seat", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
          ],
        ),
      ],
    );
  }

  Widget _driverSection(Ride ride) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Driver", style: AppTextStyles.heading3),
            GestureDetector(
              onTap: _showDriverProfile,
              child: Text(
                "View Profile",
                style: TextStyle(
                  color: AppColors.secondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                ride.driverName[0].toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ride.driverName, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 4),
                  Text("${ride.availableSeats} seats available", style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusWidget(String status) {
    Color color;
    switch (status) {
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
          Text("Request $status", style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, Ride ride, bool isRequested, bool isAccepted) {
    // Don't show button if already accepted
    if (isAccepted) {
      return Container();
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isRequested ? Colors.red : AppColors.secondary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _isLoading ? null : () {
        if (isRequested) {
          _cancelRequest();
        } else {
          _requestRide();
        }
      },
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : Text(isRequested ? "Cancel Request" : "Request Ride", style: AppTextStyles.button),
    );
  }
}