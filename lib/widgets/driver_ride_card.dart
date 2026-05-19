import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/ride_service.dart';

class DriverRideCard extends StatefulWidget {
  final Ride ride;
  final VoidCallback onViewRequests;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DriverRideCard({
    super.key,
    required this.ride,
    required this.onViewRequests,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<DriverRideCard> createState() => _DriverRideCardState();
}

class _DriverRideCardState extends State<DriverRideCard> {
  final RideService _rideService = RideService();
  int _pendingRequestsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequestsCount();
  }

  Future<void> _loadPendingRequestsCount() async {
    try {
      final ride = await _rideService.getRideById(widget.ride.rideId);
      if (ride != null) {
        final pendingCount = ride.passengers.where((p) => p.status == 'pending').length;
        setState(() {
          _pendingRequestsCount = pendingCount;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading pending requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _pendingRequestsCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildBadge(
                    _getStatusText(widget.ride.status),
                    _getStatusColor(widget.ride.status).withOpacity(0.1),
                    _getStatusColor(widget.ride.status),
                  ),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 8),
                    _buildBadge(
                      '$pendingCount New ${pendingCount == 1 ? 'Request' : 'Requests'}',
                      Colors.orange.withOpacity(0.1),
                      Colors.orange,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.radio_button_checked, size: 16, color: Colors.blue),
                  Container(
                    width: 2,
                    height: 24,
                    color: Colors.grey.shade300,
                  ),
                  const Icon(Icons.location_on, size: 16, color: Colors.green),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.ride.from,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.ride.destination,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconText(Icons.access_time, widget.ride.time),
              _buildIconText(Icons.people_outline, '${widget.ride.filledSeats}/${widget.ride.totalSeats} filled'),
              Text(
                'Rs. ${widget.ride.price}/seat',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // "View Requests" button - ALWAYS VISIBLE
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.onViewRequests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: pendingCount > 0
                      ? Text('View Requests ($pendingCount)')
                      : const Text('View Requests'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.green;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}