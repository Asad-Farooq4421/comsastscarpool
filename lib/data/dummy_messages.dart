import '../models/message_model.dart';

List<MessageModel> dummyMessages = [
  MessageModel(
    id: 'm1',
    chatId: 'chat1',
    senderId: 'user1',
    text: 'Hey, are you coming?',
    timestamp: '10:25 AM',
    isRead: true,
    isMe: false,
  ),
  MessageModel(
    id: 'm2',
    chatId: 'chat1',
    senderId: 'user1',
    text: 'Okay, see you at 5pm',
    timestamp: '10:30 AM',
    isRead: false,
    isMe: false,
  ),
  MessageModel(
    id: 'm3',
    chatId: 'chat2',
    senderId: 'user2',
    text: 'How much for the ride?',
    timestamp: '9:45 AM',
    isRead: true,
    isMe: false,
  ),
  MessageModel(
    id: 'm4',
    chatId: 'chat3',
    senderId: 'user3',
    text: 'I\'m at the gate',
    timestamp: '8:20 AM',
    isRead: false,
    isMe: false,
  ),
];
