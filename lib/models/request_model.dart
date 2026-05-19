class RideRequest {
  final String requestId;
  final String rideId;
  final String userId;
  final String passengerName;
  String status;

  RideRequest({
    required this.requestId,
    required this.rideId,
    required this.userId,
    required this.passengerName,
    this.status = "pending",
  });

  factory RideRequest.fromJson(Map<String, dynamic> json, String id) {
    return RideRequest(
      requestId: id,
      rideId: json['rideId'] ?? '',
      userId: json['userId'] ?? '',
      passengerName: json['passengerName'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'userId': userId,
      'passengerName': passengerName,
      'status': status,
    };
  }

  RideRequest copyWith({
    String? requestId,
    String? rideId,
    String? userId,
    String? passengerName,
    String? status,
  }) {
    return RideRequest(
      requestId: requestId ?? this.requestId,
      rideId: rideId ?? this.rideId,
      userId: userId ?? this.userId,
      passengerName: passengerName ?? this.passengerName,
      status: status ?? this.status,
    );
  }
}