import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../data/dummy_rides.dart';
import '../../data/dummy_users.dart';
import '../../models/ride_model.dart';

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

  // Validation methods for each step
  bool _isStep1Valid() {
    if (formData['from']!.trim().isEmpty) {
      _showErrorSnackbar('Please enter your starting location');
      return false;
    }
    if (formData['to']!.trim().isEmpty) {
      _showErrorSnackbar('Please enter your destination');
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

  void _saveAndPostRide() {
    final currentUserEmail = getCurrentUserId();
    final currentUserName = getCurrentUserName();
    final currentUserData = getCurrentUser();

    if (currentUserEmail.isEmpty) {
      _showErrorSnackbar('User not logged in');
      return;
    }

    final newRide = Ride(
      rideId: DateTime.now().millisecondsSinceEpoch.toString(),
      driverId: currentUserEmail,
      driverName: currentUserName,
      driverPhoto: '',
      driverRating: double.parse(currentUserData?['driverRating'] ?? '0.0'),
      from: formData['from']!.trim(),
      destination: formData['to']!.trim(),
      date: formData['date']!.trim(),
      time: formData['time']!.trim(),
      totalSeats: int.parse(formData['seats']!),
      availableSeats: int.parse(formData['seats']!),
      price: int.parse(formData['price']!),
      status: 'scheduled',
      notes: formData['notes']!.trim(),
      pendingRequests: 0,
      passengers: [],
    );

    addNewRide(newRide);

    // Show success screen instead of direct pop
    setState(() {
      currentStep = 5;  // Go to success screen
    });

    // Auto navigate back to driver home after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Reset form data
        setState(() {
          currentStep = 1;
          formData.updateAll((key, value) => '');
        });
        // Go back with refresh flag
        Navigator.pop(context, true);
      }
    });
  }

  void nextStep() {
    // Validate current step before proceeding
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
      // FINAL STEP: Save the ride
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
    // Success Screen (Step 5)
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

    // Main Form Screen (Steps 1-4)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
        children: [
          // Header
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

          // Progress Bar
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

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildStepContent(),
            ),
          ),

          // Next Button
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
          'Enter your starting point and destination',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'From *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Starting location',
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
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
          onChanged: (value) => formData['from'] = value,
        ),
        const SizedBox(height: 20),

        Text(
          'To *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Destination',
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: const Icon(Icons.location_on, color: Colors.green),
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
          onChanged: (value) => formData['to'] = value,
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

        // Date picker
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

        // Time picker with validation
        Text(
          'Time *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // Check if date is today
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
              // Validate time if date is today
              if (isToday) {
                final now = TimeOfDay.now();
                final selectedMinutes = pickedTime.hour * 60 + pickedTime.minute;
                final currentMinutes = now.hour * 60 + now.minute;

                if (selectedMinutes < currentMinutes) {
                  _showErrorSnackbar('Please select a future time (current time: ${_formatTimeOfDay(now)})');
                  return;
                }
              }

              setState(() {
                final hour = pickedTime.hourOfPeriod;
                final minute = pickedTime.minute.toString().padLeft(2, '0');
                final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
                formData['time'] = '$hour:$minute $period';
              });
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

        // Seats dropdown
        Text(
          'Available Seats *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: formData['seats']!.isEmpty ? null : formData['seats'],
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
          },
        ),
        const SizedBox(height: 20),

        // Price input
        Text(
          'Price per Seat *',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
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
        const SizedBox(height: 8),
        Text(
          'Suggested: Rs. 100 - Rs. 300 per seat',
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

String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}