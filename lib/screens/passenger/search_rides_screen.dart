import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/user_model.dart';
import '../../models/ride_model.dart';
import '../../data/dummy_rides.dart';
import '../../widgets/role_toggle.dart';
import '../../widgets/ride_card.dart';
import '../../utils/routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  UserRole selectedRole = UserRole.passenger;

  final TextEditingController destinationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<Ride> filteredRides = [];
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Pre-load some rides so screen isn't empty initially
    filteredRides = List.from(dummyRides);
  }

  void searchRides() {
    final destination = destinationController.text.toLowerCase().trim();
    final date = dateController.text.trim();

    setState(() {
      hasSearched = true;
      filteredRides = dummyRides.where((ride) {
        final matchDestination = ride.destination.toLowerCase().contains(destination);
        final matchDate = date.isEmpty || ride.date == date;
        return matchDestination && matchDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🏷️ Header with Gradient (Consistent with Driver)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find a Ride',
                            style: AppTextStyles.heading2.copyWith(color: Colors.white),
                          ),
                          Text(
                            'Where are we heading?',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          const Icon(Icons.notifications_none, color: Colors.white, size: 32),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '3',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 🔘 Role Toggle
                  Center(
                    child: RoleToggle(
                      selectedRole: selectedRole,
                      onChanged: (role) {
                        if (role == UserRole.driver) {
                          Navigator.pushReplacementNamed(context, AppRoutes.driverHome);
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 📊 Passenger Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('8', 'Rides Taken'),
                      _buildStatItem('4.9', 'Rating'),
                      _buildStatItem('Rs. 1200', 'Saved'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔍 Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Search Rides', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  _buildSearchField(
                    controller: destinationController,
                    hint: 'Where to?',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildSearchField(
                    controller: dateController,
                    hint: 'When? (Optional)',
                    icon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: searchRides,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Search Rides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 🚗 Ride List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSearched ? 'Search Results' : 'Recommended Rides',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  filteredRides.isEmpty
                      ? const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('No rides found for your criteria.'),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: filteredRides.length,
                          itemBuilder: (context, index) {
                            return RideCard(filteredRides[index]);
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Rides'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 2) Navigator.pushNamed(context, AppRoutes.chatList);
          if (index == 3) Navigator.pushNamed(context, AppRoutes.profile);
        },
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
