import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/dummy_chats.dart';
import '../../models/chat_model.dart';
import '../../models/ride_model.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
// import '../../widgets/app_bottom_nav.dart';
// import '../../data/dummy_rides.dart';
import '../../data/ride_requests.dart';
import '../chat/individual_chat_screen.dart'; // for currentUser

class RideDetailsScreen extends StatefulWidget {
  final Ride ride;
  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  PassengerInfo? myRequest;
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

  // 🔍 Load this user's request from ride.passengers
  void _loadRequest() {
    final match = widget.ride.passengers.firstWhere(
          (p) => p.userId == currentUser?['email'],
      orElse: () => myRequest ?? PassengerInfo(userId: '', name: '', status: ''),
    );

    // Only update if a real match is found
    if (match.userId.isNotEmpty) {
      setState(() {
        myRequest = match;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Ride Details")),
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
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
              child: Text(ride.time, style: const TextStyle(color: Colors.white)),
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
      children: [Text(label, style: AppTextStyles.caption), const SizedBox(height: 2), Text(value, style: AppTextStyles.bodyLarge)],
    );
  }

  // INFO
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

  // DRIVER
  Widget _driverSection(Ride ride) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Driver", style: AppTextStyles.heading3),
          GestureDetector(
            onTap: () {
              _showDriverProfile(context, ride);
            },
            child: Text(
              "View Profile",
              style: TextStyle(
                color: AppColors.secondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(
          children: [
            const CircleAvatar(radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ride.driverName, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 4),
                  Text("${ride.availableSeats ?? 0} seats available", style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STATUS
  Widget _statusWidget(PassengerInfo request) {
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
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [Icon(Icons.info, color: color), const SizedBox(width: 8), Text("Request ${request.status}", style: TextStyle(color: color))],
      ),
    );
  }

  // BUTTON
  Widget _button(BuildContext context, Ride ride) {
    final isRequested = myRequest != null;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isRequested ? Colors.red : AppColors.secondary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        if (isRequested) {
          _cancelRequest();
        } else {
          _requestRide(ride);
        }
      },
      child: Text(isRequested ? "Cancel Request" : "Request Ride", style: AppTextStyles.button),
    );
  }

  void _requestRide(Ride ride) {
    if ((ride.availableSeats ?? 0) <= 0) {
      _showSnack("No seats available");
      return;
    }

    final request = PassengerInfo(
      userId: currentUser?['email'] ?? "",
      name: currentUser?['name'] ?? "Unknown",
      status: "pending",
    );

    setState(() {
      ride.passengers.add(request);
      ride.availableSeats = (ride.availableSeats ?? 1) - 1;
      myRequest = request;
    });

    _showSnack("Request sent");
  }

  void _cancelRequest() {
    setState(() {
      widget.ride.passengers.removeWhere((p) => p.userId == currentUser?['email']);
      widget.ride.availableSeats = (widget.ride.availableSeats ?? 0) + 1;
      myRequest = null;
    });

    _showSnack("Request cancelled");
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

void _showDriverProfile(BuildContext context, Ride ride) {
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
              // Avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  ride.driverName[0],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Name
              Text(
                ride.driverName,
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: 6),

              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    ride.driverRating.toString(),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Info
              _infoRowDialog("Driver ID", ride.driverId),
              _infoRowDialog("Seats", "${ride.availableSeats}/${ride.totalSeats}"),
              if (ride.notes.isNotEmpty)
                _infoRowDialog("Notes", ride.notes),

              const SizedBox(height: 20),

              // Chat Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    _openChat(context, ride);
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text("Chat with Driver"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Close Button
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

// ✅ FIXED: Updated _openChat function to work with new ChatModel
void _openChat(BuildContext context, Ride ride) {
  final currentUserId = currentUser?['email'] ?? "unknown_user";
  final driverId = ride.driverId;

  print('🔍 Opening chat - Current User: $currentUserId, Driver: $driverId, Ride: ${ride.rideId}');

  if (currentUserId == "unknown_user") {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please login to chat")),
    );
    return;
  }

  // 🔍 Find existing chat
  ChatModel? existingChat;

  for (var chat in dummyChats) {
    print('📋 Checking chat: ${chat.id}, Participants: ${chat.participants}, RideId: ${chat.rideId}');

    if (chat.participants.contains(currentUserId) &&
        chat.participants.contains(driverId) &&
        chat.rideId == ride.rideId) {
      existingChat = chat;
      print('✅ Found existing chat: ${chat.id}');
      break;
    }
  }

  // 🆕 Create new chat if not found
  if (existingChat == null) {
    print('🆕 No existing chat found, creating new one...');

    // Check again by participants only
    for (var chat in dummyChats) {
      if (chat.participants.contains(currentUserId) &&
          chat.participants.contains(driverId)) {
        existingChat = chat;
        print('✅ Found existing chat by participants only: ${chat.id}');
        break;
      }
    }

    if (existingChat == null) {
      // ✅ FIXED: Create new chat with unreadCounts map, not unreadCount
      final newChat = ChatModel(
        id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
        participants: [currentUserId, driverId],
        rideId: ride.rideId,
        lastMessage: '',
        lastMessageTime: '',
        unreadCounts: {
          currentUserId: 0,
          driverId: 0,
        },
      );

      addNewChat(newChat);
      existingChat = newChat;
      print('✅ Created new chat: ${newChat.id}');
    }
  }

  // 🚀 Navigate to chat
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const IndividualChatScreen(),
      settings: RouteSettings(arguments: existingChat!.id),
    ),
  );
}