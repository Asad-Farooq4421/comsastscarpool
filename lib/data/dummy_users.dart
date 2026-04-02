final List<Map<String, dynamic>> dummyUsers = [
  {
    'email': 'student@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'John Doe',
    'university': 'COMSATS Islamabad',
    'phone': '+92 300 1234567',
    'bio': 'Computer Science student, looking for ride buddies!',
    'isDriver': false,
    'ridesAsDriver': '0',
    'driverRating': '0.0',
    'earnings': '0',
    'vehicleType': '',
    'vehicleModel': '',
    'vehicleColor': '',
    'vehiclePlate': '',
    'vehicleSeats': '',
    'ridesAsPassenger': '5',
    'passengerRating': '4.8',
    'savedRoutes': '2',
  },
  {
    'email': 'ali@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'Ali Khan',
    'university': 'COMSATS Islamabad',
    'phone': '+92 300 7654321',
    'bio': 'Senior student, available for rides daily',
    'isDriver': true,
    'ridesAsDriver': '12',
    'driverRating': '4.9',
    'earnings': '3500',
    'vehicleType': 'Car',
    'vehicleModel': 'Honda Civic',
    'vehicleColor': 'Black',
    'vehiclePlate': 'LEH-5678',
    'vehicleSeats': '4',
    'ridesAsPassenger': '3',
    'passengerRating': '4.5',
    'savedRoutes': '1',
  },
  {
    'email': 'sara@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'Sara Ahmed',
    'university': 'COMSATS Islamabad',
    'phone': '+92 300 9876543',
    'bio': 'Freshman, looking for safe rides',
    'isDriver': false,
    'ridesAsDriver': '0',
    'driverRating': '0.0',
    'earnings': '0',
    'vehicleType': '',
    'vehicleModel': '',
    'vehicleColor': '',
    'vehiclePlate': '',
    'vehicleSeats': '',
    'ridesAsPassenger': '8',
    'passengerRating': '4.7',
    'savedRoutes': '3',
  },
];

void addUser(Map<String, dynamic> newUser) {
  final completeUser = {
    'email': newUser['email'],
    'password': newUser['password'],
    'name': newUser['name'],
    'university': newUser['university'] ?? 'COMSATS Islamabad',
    'phone': newUser['phone'] ?? '',
    'bio': newUser['bio'] ?? '',
    'isDriver': false,
    'ridesAsDriver': '0',
    'driverRating': '0.0',
    'earnings': '0',
    'vehicleType': '',
    'vehicleModel': '',
    'vehicleColor': '',
    'vehiclePlate': '',
    'vehicleSeats': '',
    'ridesAsPassenger': '0',
    'passengerRating': '0.0',
    'savedRoutes': '0',
  };

  dummyUsers.add(completeUser);
}

bool userExists(String email) {
  return dummyUsers.any((user) => user['email'] == email);
}

Map<String, dynamic>? getUserByEmail(String email) {
  try {
    return dummyUsers.firstWhere((user) => user['email'] == email);
  } catch (e) {
    return null;
  }
}