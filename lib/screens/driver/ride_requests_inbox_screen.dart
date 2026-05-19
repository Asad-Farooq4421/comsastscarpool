import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/request_model.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';
import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import '../../utils/routes.dart';
import '../chat/individual_chat_screen.dart';

class RideRequestsInboxScreen extends StatefulWidget {
  final Ride? ride;  // Add this optional parameter

  const RideRequestsInboxScreen({super.key, this.ride});

  @override
  State<RideRequestsInboxScreen> createState() => _RideRequestsInboxScreenState();
}

class _RideRequestsInboxScreenState extends State<RideRequestsInboxScreen>
    with SingleTickerProviderStateMixin {

  Ride? _ride;
  late TabController _tabController;

  final RideService _rideService = RideService();
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();

  List<RideRequest> _pendingRequests = [];
  List<RideRequest> _acceptedRequests = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_ride != null) return;

    if (widget.ride != null) {
      _ride = widget.ride;
      _loadData();
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Ride) {
      _ride = args;
      _loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get latest ride data
      final updatedRide = await _rideService.getRideById(_ride!.rideId);
      if (updatedRide != null) {
        _ride = updatedRide;
      }

      // Convert passengers to RideRequest objects
      _pendingRequests = [];
      _acceptedRequests = [];

      for (var passenger in _ride!.passengers) {
        final userProfile = await _userService.getUserProfile(passenger.userId);
        final request = RideRequest(
          requestId: '${_ride!.rideId}_${passenger.userId}',
          rideId: _ride!.rideId,
          userId: passenger.userId,
          passengerName: userProfile?.name ?? passenger.name,
          status: passenger.status,
        );

        if (passenger.status == 'pending') {
          _pendingRequests.add(request);
        } else if (passenger.status == 'accepted') {
          _acceptedRequests.add(request);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRequest(RideRequest request, bool accept) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (accept && _ride!.availableSeats > 0) {
        // Update passenger status to accepted
        final updatedPassengers = _ride!.passengers.map((p) {
          if (p.userId == request.userId) {
            return p.copyWith(status: 'accepted');
          }
          return p;
        }).toList();

        final updatedRide = _ride!.copyWith(
          passengers: updatedPassengers,
          availableSeats: _ride!.availableSeats - 1,
          pendingRequests: _ride!.pendingRequests - 1,
        );

        await _rideService.updateRide(updatedRide);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passenger Accepted!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (!accept) {
        // Remove rejected passenger
        final updatedPassengers = _ride!.passengers
            .where((p) => p.userId != request.userId)
            .toList();

        final updatedRide = _ride!.copyWith(
          passengers: updatedPassengers,
          pendingRequests: _ride!.pendingRequests - 1,
        );

        await _rideService.updateRide(updatedRide);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request Declined'),
            backgroundColor: Colors.red,
          ),
        );
      }

      await _loadData();
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

  Future<void> _startChat(RideRequest request) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to chat")),
      );
      return;
    }

    try {
      final chatId = await _chatService.getOrCreateChat(
        _ride!.rideId,
        request.userId,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IndividualChatScreen(
              chatId: chatId,
              rideId: _ride!.rideId,
              otherUserName: request.passengerName,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening chat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showPassengerProfile(RideRequest request) async {
    final userProfile = await _userService.getUserProfile(request.userId);

    if (userProfile == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.passengerName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📞 ${userProfile.phone ?? 'Not provided'}'),
            const SizedBox(height: 8),
            Text('⭐ Rating: ${userProfile.passengerRating}'),
            const SizedBox(height: 8),
            Text('🚗 Rides taken: ${userProfile.ridesAsPassenger}'),
            const SizedBox(height: 8),
            Text('📧 ${userProfile.email}'),
            const SizedBox(height: 8),
            Text('📝 ${userProfile.bio ?? 'No bio added'}'),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Ride Requests'),
            if (!_isLoading)
              Text(
                '${_pendingRequests.length} pending • ${_acceptedRequests.length} accepted',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildRideInfoHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending Tab
                _pendingRequests.isEmpty
                    ? const Center(child: Text('No pending requests'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pendingRequests[index];
                    return _buildPendingRequestCard(request);
                  },
                ),
                // Accepted Tab
                _acceptedRequests.isEmpty
                    ? const Center(child: Text('No accepted passengers yet'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _acceptedRequests.length,
                  itemBuilder: (context, index) {
                    final request = _acceptedRequests[index];
                    return _buildAcceptedPassengerCard(request);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.primary.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radio_button_checked, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _ride!.from,
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
                  _ride!.destination,
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
                '${_ride!.date} • ${_ride!.time}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '${_ride!.availableSeats} seats left',
                style: AppTextStyles.caption.copyWith(
                  color: _ride!.availableSeats == 0 ? Colors.red : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestCard(RideRequest request) {
    final bool isSeatsAvailable = _ride!.availableSeats > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  request.passengerName.isNotEmpty ? request.passengerName[0] : '?',
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
                    Text(
                      'Requested',
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
                  onPressed: () => _showPassengerProfile(request),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Profile'),
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
                  onPressed: (isSeatsAvailable)
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
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.1)),
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

  Widget _buildAcceptedPassengerCard(RideRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                backgroundColor: Colors.green.withOpacity(0.1),
                child: Text(
                  request.passengerName.isNotEmpty ? request.passengerName[0] : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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
                    const SizedBox(height: 4),
                    Text(
                      'Accepted passenger',
                      style: AppTextStyles.caption.copyWith(color: Colors.green),
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
                  onPressed: () => _showPassengerProfile(request),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Profile'),
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
                  onPressed: () => _startChat(request),
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
}