
class RideRequest {
  final String rideId;
  final String userId;
  final String passengerName;
  String status; // pending / accepted / rejected

  RideRequest({
    required this.rideId,
    required this.userId,
    required this.passengerName,
    this.status = "pending",
  });

  RideRequest copyWith({
    String? rideId,
    String? userId,
    String? passengerName,
    String? status,
  }) {
    return RideRequest(
      rideId: rideId ?? this.rideId,
      userId: userId ?? this.userId,
      passengerName: passengerName ?? this.passengerName,
      status: status ?? this.status,
    );
  }
}
