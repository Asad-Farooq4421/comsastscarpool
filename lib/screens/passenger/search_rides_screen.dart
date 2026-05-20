import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../services/user_service.dart';
import '../../services/ride_service.dart';
import '../../services/location_service.dart';
import '../../services/google_place_service.dart';
import '../../models/ride_model.dart';
import '../../widgets/role_toggle.dart';
import '../../widgets/ride_card.dart';
import 'ride_details_screen.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onNavigateToProfile;

  const SearchScreen({
    super.key,
    required this.onSwitch,
    required this.onNavigateToProfile,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  UserRole selectedRole = UserRole.passenger;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<Ride> _allRides = [];
  List<Ride> filteredRides = [];
  bool hasSearched = false;
  bool isDriverUser = false;
  bool _hasShownDriverPopup = false;
  bool _isLoading = true;
  bool _isSearchingNearby = false;

  // Location variables for nearby rides
  LatLng? _currentLocation;
  String _currentLocationName = 'Fetching location...';
  double _nearbyRadius = 5.0;
  bool _isNearbyMode = false;

  final RideService _rideService = RideService();
  final UserService _userService = UserService();
  final LocationService _locationService = LocationService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRides();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _getLocationName();
    } else {
      setState(() {
        _currentLocationName = 'Location unavailable';
      });
    }
  }

  Future<void> _getLocationName() async {
    if (_currentLocation == null) return;

    try {
      final address = await GooglePlacesService.instance.getAddressFromCoordinates(_currentLocation!);
      if (mounted) {
        String shortName = address.split(',').first;
        if (shortName.length > 25) {
          shortName = shortName.substring(0, 25) + '...';
        }
        setState(() {
          _currentLocationName = shortName;
        });
      }
    } catch (e) {
      setState(() {
        _currentLocationName = 'Your Location';
      });
    }
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userProfile = await _userService.getUserProfile(currentUser.uid);
      setState(() {
        _currentUserId = currentUser.uid;
        isDriverUser = userProfile?.isDriver ?? false;
      });
    }
  }

  Future<void> _loadRides() async {
    setState(() {
      _isLoading = true;
    });

    final rides = await _rideService.getAvailableRides();

    setState(() {
      _allRides = rides;
      _isLoading = false;
    });

    if (hasSearched) {
      if (_isNearbyMode) {
        _performNearbySearch();
      } else {
        searchRides();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  void _showDriverModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.directions_car, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Become a Driver?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To start offering rides as a driver, you need to provide:'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Vehicle type (Car/Bike)'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Vehicle model'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Color & License plate'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Number of seats'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'You can edit these details anytime from your profile.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Yes, Continue'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _hasShownDriverPopup = true;
        ProfileScreen.shouldSwitchToDriver = true;
        widget.onNavigateToProfile();
      }
    });
  }

  // Nearby Rides Function
  Future<void> _searchNearbyRides() async {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Getting your location...')),
      );
      await _getCurrentLocation();
      return;
    }

    final radius = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find Rides Near You'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How far do you want to search?'),
                const SizedBox(height: 16),
                Slider(
                  value: _nearbyRadius,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '${_nearbyRadius.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setStateDialog(() {
                      _nearbyRadius = value;
                    });
                  },
                ),
                Text(
                  '${_nearbyRadius.toStringAsFixed(1)} km radius',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rides starting within this distance',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _nearbyRadius),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Search Nearby'),
          ),
        ],
      ),
    );

    if (radius != null && mounted) {
      setState(() {
        _nearbyRadius = radius;
        _isNearbyMode = true;
        _isSearchingNearby = true;
        hasSearched = true;
      });
      _performNearbySearch();
    }
  }

  void _performNearbySearch() {
    if (_currentLocation == null) return;

    final now = DateTime.now();
    final nearbyRides = <Ride>[];

    for (var ride in _allRides) {
      if (ride.pickupLatitude != null && ride.pickupLongitude != null) {
        final distance = _locationService.calculateDistanceInKm(
          _currentLocation!,
          LatLng(ride.pickupLatitude!, ride.pickupLongitude!),
        );

        // Check if ride is within radius, has seats, not user's own ride, and is future ride
        if (distance <= _nearbyRadius &&
            ride.availableSeats > 0 &&
            (_currentUserId == null || ride.driverId != _currentUserId) &&
            _isFutureRide(ride)) {
          nearbyRides.add(ride);
        }
      }
    }

    // Sort by distance
    nearbyRides.sort((a, b) {
      final distanceA = _locationService.calculateDistanceInKm(
        _currentLocation!,
        LatLng(a.pickupLatitude!, a.pickupLongitude!),
      );
      final distanceB = _locationService.calculateDistanceInKm(
        _currentLocation!,
        LatLng(b.pickupLatitude!, b.pickupLongitude!),
      );
      return distanceA.compareTo(distanceB);
    });

    setState(() {
      filteredRides = nearbyRides;
      _isSearchingNearby = false;
    });

    if (nearbyRides.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No rides found within ${_nearbyRadius.toStringAsFixed(1)} km'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void searchRides() {
    setState(() {
      _isNearbyMode = false;
    });

    final from = fromController.text.toLowerCase().trim();
    final to = toController.text.toLowerCase().trim();
    final date = dateController.text.trim();
    final now = DateTime.now();

    setState(() {
      hasSearched = true;

      filteredRides = _allRides.where((ride) {
        final matchFrom = from.isEmpty || ride.from.toLowerCase().contains(from);
        final matchTo = to.isEmpty || ride.destination.toLowerCase().contains(to);
        final matchDate = date.isEmpty || ride.date == date;
        final hasSeats = ride.availableSeats > 0;
        final notMyRide = _currentUserId == null || ride.driverId != _currentUserId;
        final isFutureRide = _isFutureRide(ride);

        return matchFrom && matchTo && matchDate && hasSeats && notMyRide && isFutureRide;
      }).toList();
    });
  }

  bool _isFutureRide(Ride ride) {
    final now = DateTime.now();
    try {
      final rideDate = DateTime.parse(ride.date);
      final timeParts = ride.time.split(' ');
      final hm = timeParts[0].split(':');
      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);

      if (timeParts[1] == "PM" && hour != 12) {
        hour += 12;
      } else if (timeParts[1] == "AM" && hour == 12) {
        hour = 0;
      }

      final rideDateTime = DateTime(
        rideDate.year,
        rideDate.month,
        rideDate.day,
        hour,
        minute,
      );

      return rideDateTime.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  void _clearFilters() {
    fromController.clear();
    toController.clear();
    dateController.clear();
    setState(() {
      _isNearbyMode = false;
      hasSearched = false;
      filteredRides = [];
    });
  }

  Future<void> _refreshRides() async {
    await _loadRides();
    if (hasSearched) {
      if (_isNearbyMode) {
        _performNearbySearch();
      } else {
        searchRides();
      }
    }
  }

  String? _getDistanceText(Ride ride) {
    if (_currentLocation == null || ride.pickupLatitude == null) return null;

    final distance = _locationService.calculateDistanceInKm(
      _currentLocation!,
      LatLng(ride.pickupLatitude!, ride.pickupLongitude!),
    );

    if (distance < 1) {
      return '${(distance * 1000).toInt()} m away';
    }
    return '${distance.toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshRides,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchForm(),
              _buildRideList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                    _isNearbyMode ? 'Nearby Rides' : 'Passenger Dashboard',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ),
                  if (_isNearbyMode && _currentLocation != null)
                    Text(
                      'Within ${_nearbyRadius.toStringAsFixed(1)} km of your location',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    )
                  else
                    Text(
                      'Find and book rides',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: RoleToggle(
              selectedRole: selectedRole,
              onChanged: (role) {
                if (role == UserRole.driver) {
                  if (isDriverUser) {
                    widget.onSwitch();
                  } else {
                    if (!_hasShownDriverPopup) {
                      _showDriverModeDialog();
                    } else {
                      widget.onNavigateToProfile();
                    }
                  }
                } else {
                  setState(() {
                    selectedRole = UserRole.passenger;
                    _isNearbyMode = false;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Nearby Rides Button (NEW)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSearchingNearby ? null : _searchNearbyRides,
              icon: _isSearchingNearby
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.my_location),
              label: Text(_isNearbyMode ? 'Nearby Mode ON' : 'Find Rides Near Me'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _isNearbyMode ? Colors.green : AppColors.primary,
                side: BorderSide(color: _isNearbyMode ? Colors.green : AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          if (_isNearbyMode)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.close),
                label: const Text('Exit Nearby Mode'),
              ),
            ),

          if (!_isNearbyMode) ...[
            const SizedBox(height: 12),
            _inputField(
              controller: fromController,
              hint: "From",
              icon: Icons.circle,
            ),
            const SizedBox(height: 10),
            _inputField(
              controller: toController,
              hint: "To",
              icon: Icons.location_on,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    dateController.text = pickedDate.toIso8601String().split('T')[0];
                  });
                }
              },
              child: AbsorbPointer(
                child: _inputField(
                  controller: dateController,
                  hint: "Select Date",
                  icon: Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: searchRides,
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text("Search Rides", style: AppTextStyles.button),
            ),
          ],
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: AppTextStyles.inputHint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRideList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasSearched)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isNearbyMode ? 'Rides Near You' : 'Available Rides',
                    style: AppTextStyles.heading3,
                  ),
                  if (_isNearbyMode)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_nearbyRadius.toStringAsFixed(0)} km',
                        style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading || _isSearchingNearby
                  ? const Center(child: CircularProgressIndicator())
                  : !hasSearched
                  ? const Center(
                child: Text("Search for rides to see results"),
              )
                  : filteredRides.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isNearbyMode ? Icons.location_off : Icons.search_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isNearbyMode
                          ? 'No rides found within ${_nearbyRadius.toStringAsFixed(1)} km'
                          : 'No rides found',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    if (_isNearbyMode)
                      TextButton(
                        onPressed: _searchNearbyRides,
                        child: const Text('Try increasing radius'),
                      ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredRides.length,
                itemBuilder: (context, index) {
                  final ride = filteredRides[index];
                  final distanceText = _isNearbyMode ? _getDistanceText(ride) : null;
                  return RideCard(
                    ride: ride,
                    distanceText: distanceText,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RideDetailsScreen(ride: ride),
                        ),
                      );
                      if (result == true) {
                        await _refreshRides();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}