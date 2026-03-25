final List<Map<String, dynamic>> dummyUsers = [
  {
    'email': 'student@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'John Doe',
    'university': 'COMSATS Islamabad',
  },
  {
    'email': 'ali@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'Ali Khan',
    'university': 'COMSATS Islamabad',
  },
  {
    'email': 'sara@isbstudent.comsats.edu.pk',
    'password': '123456',
    'name': 'Sara Ahmed',
    'university': 'COMSATS Islamabad',
  },
];
void addUser(Map<String, dynamic> newUser) {
  dummyUsers.add(newUser);
  print('User added: ${newUser['email']}');
  print('Total users: ${dummyUsers.length}');
}

// Helper function to check if user exists
bool userExists(String email) {
  return dummyUsers.any((user) => user['email'] == email);
}