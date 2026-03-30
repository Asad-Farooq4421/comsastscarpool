import '../models/chat_model.dart';

final List<ChatModel> dummyChats = [
  ChatModel(
    id: 'chat1',
    userId: 'user1',
    userName: 'Ahmad Raza',
    userPhoto: 'https://i.pravatar.cc/150?img=1',
    lastMessage: 'Okay, see you at 5pm',
    timestamp: '10:30 AM',
    unread: 2,
    rideId: 'ride1',
  ),
  ChatModel(
    id: 'chat2',
    userId: 'user2',
    userName: 'Sara Khan',
    userPhoto: 'https://i.pravatar.cc/150?img=2',
    lastMessage: 'How much for the ride?',
    timestamp: '9:45 AM',
    unread: 0,
    rideId: 'ride2',
  ),
  ChatModel(
    id: 'chat3',
    userId: 'user3',
    userName: 'Bilal Ahmed',
    userPhoto: 'https://i.pravatar.cc/150?img=3',
    lastMessage: 'I\'m at the gate',
    timestamp: '8:20 AM',
    unread: 1,
    rideId: 'ride3',
  ),
  ChatModel(
    id: 'chat4',
    userId: 'user4',
    userName: 'Fatima Ali',
    userPhoto: 'https://i.pravatar.cc/150?img=4',
    lastMessage: 'Thanks for the ride!',
    timestamp: 'Yesterday',
    unread: 0,
    rideId: 'ride1',
  ),
];