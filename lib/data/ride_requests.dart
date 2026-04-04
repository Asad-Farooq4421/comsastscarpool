import '../models/request_model.dart';
import 'dummy_users.dart';

List<RideRequest> rideRequests = [
  RideRequest(
    rideId: '1',
    userId: 'ahmed@isbstudent.comsats.edu.pk',
    passengerName: 'Ahmed Raza',
    status: 'pending',
  ),
  RideRequest(
    rideId: '1',
    userId: 'fatima@isbstudent.comsats.edu.pk',
    passengerName: 'Fatima Khan',
    status: 'pending',
  ),
  RideRequest(
    rideId: '5',
    userId: 'zainab@isbstudent.comsats.edu.pk',
    passengerName: 'Zainab Ali',
    status: 'pending',
  ),
  RideRequest(
    rideId: '5',
    userId: 'student@isbstudent.comsats.edu.pk',
    passengerName: 'John Doe',
    status: 'pending',
  ),
];

// current user
final currentUser = getCurrentUser();