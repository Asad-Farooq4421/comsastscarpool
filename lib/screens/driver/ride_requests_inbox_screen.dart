import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../data/ride_requests.dart';
import '../../models/request_model.dart';
import '../../models/ride_model.dart';
import '../../data/dummy_users.dart';
import '../../data/dummy_rides.dart';
import '../../data/dummy_chats.dart';
import '../../utils/routes.dart';
import '../../models/chat_model.dart';

class RideRequestsInboxScreen extends StatefulWidget {
  const RideRequestsInboxScreen({super.key});

  @override
  State<RideRequestsInboxScreen> createState() => _RideRequestsInboxScreenState();
}

class _RideRequestsInboxScreenState extends State<RideRequestsInboxScreen>
    with SingleTickerProviderStateMixin {

  late Ride ride;
  late TabController _tabController;
  int currentPendingCount = 0;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      ride = ModalRoute.of(context)!.settings.arguments as Ride;
      currentPendingCount = ride.pendingRequests;
      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter passengers by status
    final pendingRequests = rideRequests
        .where((r) => r.rideId == ride.rideId && r.status == 'pending')
        .toList();

    final acceptedPassengers =
    ride.passengers.where((p) => p.status == 'accepted').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Ride Requests'),
            Text(
                '${pendingRequests.length} pending • ${acceptedPassengers.length} accepted',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Column(
        children: [
          // 📍 Ride Info Header
          _buildRideInfoHeader(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending Tab
                pendingRequests.isEmpty
                    ? const Center(child: Text('No pending requests'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = pendingRequests[index];
                    final userData = dummyUsers.firstWhere(
                          (u) => u['email'] == request.userId, // ✅ FIX (use email, NOT name)
                      orElse: () => dummyUsers[0],
                    );
                    return _buildPendingRequestCard(request, userData);
                  },
                ),

                // Accepted Tab
                acceptedPassengers.isEmpty
                    ? const Center(child: Text('No accepted passengers yet'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: acceptedPassengers.length,
                  itemBuilder: (context, index) {
                    final passengerInfo = acceptedPassengers[index];
                    final userData = dummyUsers.firstWhere(
                          (u) => u['email'] == passengerInfo.userId,
                      orElse: () => dummyUsers[0],
                    );
                    return _buildAcceptedPassengerCard(passengerInfo, userData);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📍 Ride Info Header
  Widget _buildRideInfoHeader() {
    return Container(
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
    );
  }

  // 📝 Pending Request Card (with Accept/Decline buttons)
  Widget _buildPendingRequestCard(RideRequest request, Map<String, dynamic> userData) {
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
                  request.passengerName[0],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.passengerName,
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
                      'Requested just now',
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
                      ? () => _handleRequest(request, true)
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
                  onPressed: () => _handleRequest(request, false),
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Accepted Passenger Card (with Chat button)
  Widget _buildAcceptedPassengerCard(PassengerInfo passenger, Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
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
                radius: 28,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                child: Text(
                  passenger.name[0],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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
                    const SizedBox(height: 4),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          userData['phone'] ?? 'No phone',
                          style: AppTextStyles.caption.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showPassengerProfile(userData),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _startChat(passenger, userData),
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleRequest(RideRequest request, bool accept) {
    final rideIndex = dummyRides.indexWhere((r) => r.rideId == ride.rideId);
    final requestIndex = rideRequests.indexWhere(
          (r) => r.rideId == ride.rideId && r.userId == request.userId,
    );

    if (rideIndex == -1 || requestIndex == -1) return;

    setState(() {
      Ride currentRide = dummyRides[rideIndex];

      if (accept && currentRide.availableSeats > 0) {
        // ✅ Update request status
        rideRequests[requestIndex] =
            rideRequests[requestIndex].copyWith(status: "accepted");

        // ✅ Add to passengers (FIXED HERE)
        List<PassengerInfo> updatedPassengers = List.from(currentRide.passengers);

        if (!currentRide.passengers.any((p) => p.userId == request.userId)) {
          updatedPassengers.add(
            PassengerInfo(
              userId: request.userId,
              name: request.passengerName,
              status: "accepted",
            ),
          );
        }

        currentRide = currentRide.copyWith(
          passengers: updatedPassengers,
          availableSeats: currentRide.availableSeats - 1,
          pendingRequests: currentRide.pendingRequests - 1,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passenger Accepted!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (!accept) {
        // ❌ Reject
        rideRequests[requestIndex] =
            rideRequests[requestIndex].copyWith(status: "rejected");

        currentRide = currentRide.copyWith(
          pendingRequests: currentRide.pendingRequests - 1,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request Declined'),
            backgroundColor: Colors.red,
          ),
        );
      }

      dummyRides[rideIndex] = currentRide;
      ride = currentRide;
      currentPendingCount = ride.pendingRequests;
    });
  }
  //
  // void _startChat(PassengerInfo passenger, Map<String, dynamic> userData) {
  //   final currentDriverId = getCurrentUserId();  // Driver ka email
  //   final passengerEmail = userData['email'];     // Passenger ka email
  //   final passengerName = userData['name'];
  //
  //   print('🔍 Opening chat - Driver: $currentDriverId, Passenger: $passengerEmail, Ride: ${ride.rideId}');
  //
  //   if (currentDriverId.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please login to chat")),
  //     );
  //     return;
  //   }
  //
  //   // 🔍 Find existing chat (driver + passenger + same ride)
  //   ChatModel? existingChat;
  //
  //   for (var chat in dummyChats) {
  //     print('📋 Checking chat: ${chat.id}, Participants: ${chat.participants}, RideId: ${chat.rideId}');
  //
  //     if (chat.participants.contains(currentDriverId) &&
  //         chat.participants.contains(passengerEmail) &&
  //         chat.rideId == ride.rideId) {
  //       existingChat = chat;
  //       print('✅ Found existing chat: ${chat.id}');
  //       break;
  //     }
  //   }
  //
  //   // 🆕 Create new chat if not found
  //   if (existingChat == null) {
  //     print('🆕 No existing chat found, creating new one...');
  //
  //     // Check again by participants only
  //     for (var chat in dummyChats) {
  //       if (chat.participants.contains(currentDriverId) &&
  //           chat.participants.contains(passengerEmail)) {
  //         existingChat = chat;
  //         print('✅ Found existing chat by participants only: ${chat.id}');
  //         break;
  //       }
  //     }
  //
  //     if (existingChat == null) {
  //       // Create new chat with unreadCounts map
  //       final newChat = ChatModel(
  //         id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
  //         participants: [currentDriverId, passengerEmail],
  //         rideId: ride.rideId,
  //         lastMessage: '',
  //         lastMessageTime: '',
  //         unreadCounts: {
  //           currentDriverId: 0,
  //           passengerEmail: 0,
  //         },
  //       );
  //
  //       dummyChats.add(newChat);
  //       existingChat = newChat;
  //       print('✅ Created new chat: ${newChat.id}');
  //     }
  //   }
  //
  //   // 🚀 Navigate to chat
  //   if (existingChat != null) {
  //     Navigator.pushNamed(
  //       context,
  //       AppRoutes.individualChat,
  //       arguments: existingChat.id,
  //     );
  //   }
  // }

  void _startChat(PassengerInfo passenger, Map<String, dynamic> userData) {
    final currentDriverId = getCurrentUserId();
    final passengerEmail = userData['email'];

    if (currentDriverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to chat")),
      );
      return;
    }

    // 🔍 Find existing chat
    ChatModel? existingChat;

    for (var chat in dummyChats) {
      if (chat.participants.contains(currentDriverId) &&
          chat.participants.contains(passengerEmail) &&
          chat.rideId == ride.rideId) {
        existingChat = chat;
        break;
      }
    }

    // If no chat found, find by participants only
    if (existingChat == null) {
      for (var chat in dummyChats) {
        if (chat.participants.contains(currentDriverId) &&
            chat.participants.contains(passengerEmail)) {
          existingChat = chat;
          break;
        }
      }
    }

    // If still no chat, create a new one
    if (existingChat == null) {
      final newChat = ChatModel(
        id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
        participants: [currentDriverId, passengerEmail],
        rideId: ride.rideId,
        lastMessage: '',
        lastMessageTime: '',
        unreadCounts: {
          currentDriverId: 0,
          passengerEmail: 0,
        },
      );

      // ✅ Use addNewChat function
      addNewChat(newChat);
      existingChat = newChat;
    }

    // ✅ Navigate with chat ID (String)
    if (existingChat != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.individualChat,
        arguments: existingChat.id,  // ← String, not object
      );
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
            const SizedBox(height: 8),
            Text('📚 ${userData['bio'] ?? 'No bio added'}'),
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