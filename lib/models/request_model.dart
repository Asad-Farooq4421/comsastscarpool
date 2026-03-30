import 'ride_model.dart';

class RideRequest {
  final Ride ride;
  final String passengerName;
  String status; // pending / accepted / rejected

  RideRequest({
    required this.ride,
    required this.passengerName,
    this.status = "pending",
  });
}