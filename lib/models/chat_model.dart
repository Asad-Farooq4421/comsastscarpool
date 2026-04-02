class ChatModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final String lastMessage;
  final String timestamp;
  final int unread;
  final String rideId;

  ChatModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.lastMessage,
    required this.timestamp,
    required this.unread,
    required this.rideId,
  });

  ChatModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhoto,
    String? lastMessage,
    String? timestamp,
    int? unread,
    String? rideId,
  }) {
    return ChatModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unread: unread ?? this.unread,
      rideId: rideId ?? this.rideId,
    );
  }
}