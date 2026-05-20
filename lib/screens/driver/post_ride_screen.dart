import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../services/ride_service.dart';
import '../../services/user_service.dart';
import '../../services/location_service.dart';
import '../../services/gemini_service.dart';
import '../../models/ride_model.dart';
import 'location_picker_screen.dart';

class PostRideScreen extends StatefulWidget {
  const PostRideScreen({super.key});

  @override
  State<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends State<PostRideScreen> {
  int currentStep = 1;

  final Map<String, String> formData = {
    'from': '',
    'to': '',
    'date': '',
    'time': '',
    'seats': '',
    'price': '',
    'notes': '',
  };

  // Location coordinates (for map)
  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;

  final RideService _rideService = RideService();
  final UserService _userService = UserService();
  final LocationService _locationService = LocationService();

  bool _isPosting = false;
  bool _isGettingAIPrice = false;
  String? _priceSuggestionMessage;
  String? _currentUserId;
  String? _currentUserName;
  double _driverRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid;
        _currentUserName = currentUser.displayName ?? 'Driver';
      });

      final userProfile = await _userService.getUserProfile(_currentUserId!);
      setState(() {
        _driverRating = userProfile?.driverRating ?? 0.0;
      });
    }
  }

  // AI Price Suggestion Method with auto-set option
  Future<void> _getAIPriceSuggestion({bool autoSet = false}) async {
    if (formData['from']!.isEmpty || formData['to']!.isEmpty) {
      if (!autoSet) {
        _showErrorSnackbar('Please select pickup and dropoff locations first');
      }
      return;
    }

    if (formData['seats']!.isEmpty) {
      if (!autoSet) {
        _showErrorSnackbar('Please select number of seats first');
      }
      return;
    }

    // Don't auto-suggest if price already set by user (not empty and not default)
    if (autoSet && formData['price']!.isNotEmpty && formData['price'] != '0') {
      return;
    }

    setState(() {
      _isGettingAIPrice = true;
    });

    // Calculate distance
    double distanceKm = 0;
    if (_pickupLatLng != null && _dropoffLatLng != null) {
      distanceKm = _locationService.calculateDistanceInKm(
        _pickupLatLng!,
        _dropoffLatLng!,
      );
    }

    // Get area names
    final pickupArea = formData['from']!.split(',').first;
    final dropoffArea = formData['to']!.split(',').first;
    final seats = int.tryParse(formData['seats']!) ?? 1;
    final timeOfDay = formData['time']!.isEmpty ? '12:00 PM' : formData['time']!;
    final date = formData['date']!.isEmpty ? DateTime.now().toIso8601String().split('T')[0] : formData['date']!;

    final price = await GeminiService().predictPrice(
      distanceKm: distanceKm,
      pickupArea: pickupArea,
      dropoffArea: dropoffArea,
      availableSeats: seats,
      timeOfDay: timeOfDay,
      date: date,
    );

    setState(() {
      _isGettingAIPrice = false;
    });

    if (price > 0) {
      setState(() {
        formData['price'] = price.toString();
        _priceSuggestionMessage = '🤖 AI suggested: Rs. $price per seat (${distanceKm.toStringAsFixed(1)} km)';
      });

      if (!autoSet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🤖 AI suggested price: Rs. $price per seat'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() {
        _priceSuggestionMessage = null;
      });
      if (!autoSet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI temporarily unavailable. Using default pricing.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      // Fallback to default calculation
      final fallbackPrice = (distanceKm * 18).round().clamp(100, 300);
      setState(() {
        formData['price'] = fallbackPrice.toString();
      });
    }
  }

  Future<void> _selectPickupLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          title: 'Select Pickup Location',
          initialLocation: _pickupLatLng,
          onLocationSelected: (location, address) {
            print('📍 Pickup selected: $address');
            setState(() {
              _pickupLatLng = location;
              formData['from'] = address;
              // Auto-suggest price when location changes and seats are selected
              if (formData['seats']!.isNotEmpty && formData['to']!.isNotEmpty) {
                _getAIPriceSuggestion(autoSet: true);
              }
            });
          },
        ),
      ),
    );
  }

  Future<void> _selectDropoffLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          title: 'Select Dropoff Location',
          initialLocation: _dropoffLatLng,
          onLocationSelected: (location, address) {
            print('📍 Dropoff selected: $address');
            setState(() {
              _dropoffLatLng = location;
              formData['to'] = address;
              // Auto-suggest price when location changes and seats are selected
              if (formData['seats']!.isNotEmpty && formData['from']!.isNotEmpty) {
                _getAIPriceSuggestion(autoSet: true);
              }
            });
          },
        ),
      ),
    );
  }

  bool _isStep1Valid() {
    if (formData['from']!.trim().isEmpty) {
      _showErrorSnackbar('Please select pickup location');
      return false;
    }
    if (formData['to']!.trim().isEmpty) {
      _showErrorSnackbar('Please select dropoff location');
      return false;
    }
    if (_pickupLatLng == null) {
      _showErrorSnackbar('Invalid pickup location');
      return false;
    }
    if (_dropoffLatLng == null) {
      _showErrorSnackbar('Invalid dropoff location');
      return false;
    }
    return true;
  }

  bool _isStep2Valid() {
    if (formData['date']!.trim().isEmpty) {
      _showErrorSnackbar('Please select a date');
      return false;
    }
    if (formData['time']!.trim().isEmpty) {
      _showErrorSnackbar('Please select a time');
      return false;
    }
    return true;
  }

  bool _isStep3Valid() {
    if (formData['seats']!.trim().isEmpty) {
      _showErrorSnackbar('Please select number of seats');
      return false;
    }
    if (formData['price']!.trim().isEmpty) {
      _showErrorSnackbar('Please enter price per seat');
      return false;
    }
    int? price = int.tryParse(formData['price']!);
    if (price == null || price <= 0) {
      _showErrorSnackbar('Please enter a valid price (greater than 0)');
      return false;
    }
    return true;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveAndPostRide() async {
    if (_currentUserId == null || _currentUserName == null) {
      _showErrorSnackbar('User not logged in');
      return;
    }

    if (_pickupLatLng == null) {
      _showErrorSnackbar('Invalid pickup location');
      return;
    }

    if (_dropoffLatLng == null) {
      _showErrorSnackbar('Invalid dropoff location');
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final seats = int.parse(formData['seats']!);
      final price = int.parse(formData['price']!);

      print('=== SAVING RIDE ===');
      print('From address: ${formData['from']}');
      print('To address: ${formData['to']}');
      print('Pickup coords: ${_pickupLatLng!.latitude}, ${_pickupLatLng!.longitude}');
      print('Dropoff coords: ${_dropoffLatLng!.latitude}, ${_dropoffLatLng!.longitude}');

      final newRide = Ride(
        rideId: '',
        driverId: _currentUserId!,
        driverName: _currentUserName!,
        driverPhoto: '',
        driverRating: _driverRating,
        from: formData['from']!.trim(),
        destination: formData['to']!.trim(),
        date: formData['date']!.trim(),
        time: formData['time']!.trim(),
        totalSeats: seats,
        availableSeats: seats,
        price: price,
        status: 'scheduled',
        notes: formData['notes']!.trim(),
        pendingRequests: 0,
        passengers: [],
        pickupLatitude: _pickupLatLng!.latitude,
        pickupLongitude: _pickupLatLng!.longitude,
        dropoffLatitude: _dropoffLatLng!.latitude,
        dropoffLongitude: _dropoffLatLng!.longitude,
        pickupAddress: formData['from']!.trim(),
        dropoffAddress: formData['to']!.trim(),
      );

      await _rideService.createRide(newRide);

      print('✅ Ride posted successfully!');

      setState(() {
        currentStep = 5;
        _isPosting = false;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            currentStep = 1;
            formData.updateAll((key, value) => '');
            _pickupLatLng = null;
            _dropoffLatLng = null;
            _priceSuggestionMessage = null;
          });
          Navigator.pop(context, true);
        }
      });
    } catch (e) {
      print('❌ Error posting ride: $e');
      _showErrorSnackbar('Error posting ride: ${e.toString()}');
      setState(() {
        _isPosting = false;
      });
    }
  }

  void nextStep() {
    bool isValid = false;

    switch (currentStep) {
      case 1:
        isValid = _isStep1Valid();
        break;
      case 2:
        isValid = _isStep2Valid();
        break;
      case 3:
        isValid = _isStep3Valid();
        break;
      case 4:
        isValid = true;
        break;
    }

    if (!isValid) {
      return;
    }

    if (currentStep < 4) {
      setState(() {
        currentStep++;
      });
    } else {
      if (_isStep1Valid() && _isStep2Valid() && _isStep3Valid()) {
        _saveAndPostRide();
      }
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentStep == 5) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 48,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ride Posted!',
                    style: AppTextStyles.heading1.copyWith(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your ride has been posted successfully. Redirecting to dashboard...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please wait...',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: previousStep,
                  child: const Icon(Icons.arrow_back, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post a Ride',
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        'Step $currentStep of 4',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: currentStep / 4,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.primary,
                minHeight: 8,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildStepContent(),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: CustomButton(
              text: currentStep == 4 ? 'Post Ride' : 'Continue',
              onPressed: nextStep,
              isLoading: _isPosting && currentStep == 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where are you going?',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          'Select your starting point and destination on the map',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Pickup Location *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectPickupLocation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.map, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formData['from']!.isEmpty
                        ? 'Tap to select pickup location on map'
                        : formData['from']!,
                    style: TextStyle(
                      color: formData['from']!.isEmpty ? Colors.grey : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Dropoff Location *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDropoffLocation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formData['to']!.isEmpty
                        ? 'Tap to select dropoff location on map'
                        : formData['to']!,
                    style: TextStyle(
                      color: formData['to']!.isEmpty ? Colors.grey : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (_pickupLatLng != null && _dropoffLatLng != null)
          Container(
            height: 150,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _pickupLatLng!,
                  zoom: 12,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: _pickupLatLng!,
                    infoWindow: const InfoWindow(title: 'Pickup'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('dropoff'),
                    position: _dropoffLatLng!,
                    infoWindow: const InfoWindow(title: 'Dropoff'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When?',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your departure date and time',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Date *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (pickedDate != null) {
              setState(() {
                formData['date'] = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
              });
              // Auto-suggest price when date changes and other fields are filled
              if (formData['seats']!.isNotEmpty &&
                  formData['from']!.isNotEmpty &&
                  formData['to']!.isNotEmpty) {
                _getAIPriceSuggestion(autoSet: true);
              }
            }
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  formData['date']!.isEmpty ? 'Select date' : formData['date']!,
                  style: TextStyle(
                    color: formData['date']!.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Time *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = DateTime.tryParse(formData['date']!);
            final isToday = selectedDate != null &&
                selectedDate.year == DateTime.now().year &&
                selectedDate.month == DateTime.now().month &&
                selectedDate.day == DateTime.now().day;

            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null) {
              if (isToday) {
                final now = TimeOfDay.now();
                final selectedMinutes = pickedTime.hour * 60 + pickedTime.minute;
                final currentMinutes = now.hour * 60 + now.minute;

                if (selectedMinutes < currentMinutes) {
                  _showErrorSnackbar('Please select a future time');
                  return;
                }
              }

              setState(() {
                final hour = pickedTime.hourOfPeriod;
                final minute = pickedTime.minute.toString().padLeft(2, '0');
                final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
                formData['time'] = '$hour:$minute $period';
              });

              // Auto-suggest price when time changes and other fields are filled
              if (formData['seats']!.isNotEmpty &&
                  formData['from']!.isNotEmpty &&
                  formData['to']!.isNotEmpty) {
                _getAIPriceSuggestion(autoSet: true);
              }
            }
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  formData['time']!.isEmpty ? 'Select time' : formData['time']!,
                  style: TextStyle(
                    color: formData['time']!.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seats & Fare',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          'How many seats and what\'s the price?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Available Seats *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: formData['seats']!.isEmpty ? null : formData['seats'],
          hint: Text('How many seats?', style: AppTextStyles.inputHint),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            prefixIcon: const Icon(Icons.people, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          items: ['1', '2', '3', '4'].map((seats) {
            return DropdownMenuItem(
              value: seats,
              child: Text('$seats Seat${seats != '1' ? 's' : ''}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              formData['seats'] = value!;
            });
            // Auto-suggest price when seats are selected and locations exist
            if (formData['from']!.isNotEmpty && formData['to']!.isNotEmpty) {
              _getAIPriceSuggestion(autoSet: true);
            }
          },
        ),
        const SizedBox(height: 20),

        Text(
          'Price per Seat *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: formData['price'])
                  ..selection = TextSelection.collapsed(offset: formData['price']!.length),
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  hintStyle: AppTextStyles.inputHint,
                  prefixIcon: const Icon(Icons.currency_rupee, color: Colors.grey),
                  suffixText: 'PKR',
                  suffixStyle: AppTextStyles.bodyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) => formData['price'] = value,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: _isGettingAIPrice ? 'Thinking...' : '🤖 AI Suggest',
                onPressed: () => _getAIPriceSuggestion(autoSet: false),
                isLoading: _isGettingAIPrice,
                backgroundColor: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_priceSuggestionMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              _priceSuggestionMessage!,
              style: AppTextStyles.caption.copyWith(
                color: Colors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          Text(
            '💡 Price will be auto-suggested when you select seats',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          'Any special instructions or preferences?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Notes (Optional)',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'e.g., Can pick up near Starbucks, No smoking please, etc.',
            hintStyle: AppTextStyles.inputHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) => formData['notes'] = value,
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ride Summary',
                style: AppTextStyles.heading3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Route:', '${formData['from']} → ${formData['to']}'),
              const SizedBox(height: 8),
              _buildSummaryRow('Date & Time:', '${formData['date']} at ${formData['time']}'),
              const SizedBox(height: 8),
              _buildSummaryRow('Seats:', '${formData['seats']} available'),
              const SizedBox(height: 8),
              _buildSummaryRow('Price:', 'Rs. ${formData['price']}/seat', isPrice: true),
              if (_priceSuggestionMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.purple.shade400,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please review all details before posting your ride',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isPrice ? FontWeight.w600 : FontWeight.normal,
            color: isPrice ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}