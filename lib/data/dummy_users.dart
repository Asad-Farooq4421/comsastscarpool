final List<Map<String, dynamic>> dummyUsers = [
  // ==================== DEFAULT TEST USERS ====================
  {
    'email': 'student@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'John Doe',
    'photo': 'https://i.pravatar.cc/150?img=5',  // ✅ ADDED
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
    'photo': 'https://i.pravatar.cc/150?img=1',  // ✅ ADDED
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
    'photo': 'https://i.pravatar.cc/150?img=2',  // ✅ ADDED
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
  {
    'email': 'fatima@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'Fatima Khan',
    'photo': 'https://i.pravatar.cc/150?img=4',  // ✅ ADDED
    'university': 'COMSATS Islamabad',
    'phone': '+92 300 5551111',
    'bio': 'BS Economics student, need daily ride to campus',
    'isDriver': false,
    'ridesAsDriver': '0',
    'driverRating': '0.0',
    'earnings': '0',
    'vehicleType': '',
    'vehicleModel': '',
    'vehicleColor': '',
    'vehiclePlate': '',
    'vehicleSeats': '',
    'ridesAsPassenger': '12',
    'passengerRating': '4.9',
    'savedRoutes': '4',
  },
  {
    'email': 'ahmed@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'Ahmed Raza',
    'photo': 'https://i.pravatar.cc/150?img=10',  // ✅ ADDED
    'university': 'COMSATS Islamabad',
    'phone': '+92 300 5552222',
    'bio': 'Electrical Engineering, have a car, can give rides',
    'isDriver': true,
    'ridesAsDriver': '25',
    'driverRating': '4.8',
    'earnings': '7500',
    'vehicleType': 'Car',
    'vehicleModel': 'Toyota Yaris',
    'vehicleColor': 'Silver',
    'vehiclePlate': 'RZA-7890',
    'vehicleSeats': '4',
    'ridesAsPassenger': '2',
    'passengerRating': '4.5',
    'savedRoutes': '1',
  },
  {
    'email': 'zainab@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'Zainab Ali',
    'photo': 'https://i.pravatar.cc/150?img=6',  // ✅ ADDED
    'university': 'COMSATS Islamabad',
    'phone': '+92 300 5553333',
    'bio': 'Psychology student, prefer female driver only',
    'isDriver': false,
    'ridesAsDriver': '0',
    'driverRating': '0.0',
    'earnings': '0',
    'vehicleType': '',
    'vehicleModel': '',
    'vehicleColor': '',
    'vehiclePlate': '',
    'vehicleSeats': '',
    'ridesAsPassenger': '15',
    'passengerRating': '4.9',
    'savedRoutes': '5',
  },
  {
    'email': 'bilal@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'Bilal Ahmed',
    'photo': 'https://i.pravatar.cc/150?img=3',  // ✅ ADDED
    'university': 'COMSATS Islamabad',
    'phone': '+92 300 5554444',
    'bio': 'Have a bike, can take 1 passenger',
    'isDriver': true,
    'ridesAsDriver': '30',
    'driverRating': '4.7',
    'earnings': '4500',
    'vehicleType': 'Bike',
    'vehicleModel': 'Honda 125',
    'vehicleColor': 'Red',
    'vehiclePlate': 'BIL-1234',
    'vehicleSeats': '1',
    'ridesAsPassenger': '0',
    'passengerRating': '0.0',
    'savedRoutes': '0',
  },
];

// ==================== CURRENT USER TRACKING ====================

// Track the currently logged-in user's INDEX
int _currentUserIndex = -1;  // -1 means no user logged in

// Get current user's INDEX
int getCurrentUserIndex() {
  return _currentUserIndex;
}

// Get current user's FULL DATA
Map<String, dynamic>? getCurrentUser() {
  if (_currentUserIndex >= 0 && _currentUserIndex < dummyUsers.length) {
    return dummyUsers[_currentUserIndex];
  }
  return null;
}

// Set current user by INDEX (call this on login)
void setCurrentUserIndex(int index) {
  if (index >= 0 && index < dummyUsers.length) {
    _currentUserIndex = index;
    print('✅ Current user set to: ${dummyUsers[index]['name']} (Index: $index)');
  } else {
    print('❌ Invalid index: $index');
  }
}

// Set current user by EMAIL (alternative method)
void setCurrentUserByEmail(String email) {
  int index = dummyUsers.indexWhere((user) => user['email'] == email);
  if (index != -1) {
    _currentUserIndex = index;
    print('✅ Current user set to: ${dummyUsers[index]['name']} (Email: $email)');
  } else {
    print('❌ User not found with email: $email');
  }
}

// Clear current user (call this on logout)
void clearCurrentUser() {
  _currentUserIndex = -1;
  print('🔓 Current user cleared (logged out)');
}

// Check if a user is logged in
bool isUserLoggedIn() {
  return _currentUserIndex != -1;
}

// Update current user's data
void updateCurrentUser(Map<String, dynamic> updatedData) {
  if (_currentUserIndex != -1) {
    dummyUsers[_currentUserIndex] = {...dummyUsers[_currentUserIndex], ...updatedData};
    print('✅ Updated current user: ${dummyUsers[_currentUserIndex]['name']}');
  } else {
    print('❌ No user is currently logged in');
  }
}

// Add a new user and optionally set as current user
void addUserAndSetCurrent(Map<String, dynamic> newUser, {bool setAsCurrent = true}) {
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

  if (setAsCurrent) {
    _currentUserIndex = dummyUsers.length - 1;
    print('✅ New user added and set as current: ${completeUser['name']}');
  }
  print('📊 Total users now: ${dummyUsers.length}');
}

// ==================== EXISTING FUNCTIONS (keep as is) ====================

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

// ==================== HELPER FUNCTIONS FOR STATS ====================

// Increment rides given (for driver)
void incrementRidesGiven() {
  final currentUser = getCurrentUser();
  if (currentUser != null) {
    int currentRides = int.parse(currentUser['ridesAsDriver'] ?? '0');
    updateCurrentUser({'ridesAsDriver': (currentRides + 1).toString()});
  }
}

// Increment rides taken (for passenger)
void incrementRidesTaken() {
  final currentUser = getCurrentUser();
  if (currentUser != null) {
    int currentRides = int.parse(currentUser['ridesAsPassenger'] ?? '0');
    updateCurrentUser({'ridesAsPassenger': (currentRides + 1).toString()});
  }
}

// Update driver rating
void updateDriverRating(double newRating) {
  updateCurrentUser({'driverRating': newRating.toString()});
}

// Update passenger rating
void updatePassengerRating(double newRating) {
  updateCurrentUser({'passengerRating': newRating.toString()});
}

// Add earnings (for driver)
void addEarnings(int amount) {
  final currentUser = getCurrentUser();
  if (currentUser != null) {
    int currentEarnings = int.parse(currentUser['earnings'] ?? '0');
    updateCurrentUser({'earnings': (currentEarnings + amount).toString()});
  }
}

// Add saved route (for passenger)
void addSavedRoute() {
  final currentUser = getCurrentUser();
  if (currentUser != null) {
    int currentRoutes = int.parse(currentUser['savedRoutes'] ?? '0');
    updateCurrentUser({'savedRoutes': (currentRoutes + 1).toString()});
  }
}

String getCurrentUserId() {
  final user = getCurrentUser();
  return user?['email'] ?? '';
}

// Get current user's name
String getCurrentUserName() {
  final user = getCurrentUser();
  return user?['name'] ?? 'Guest';
}

// Get current user's role (driver/passenger)
bool isCurrentUserDriver() {
  final user = getCurrentUser();
  return user?['isDriver'] ?? false;
}