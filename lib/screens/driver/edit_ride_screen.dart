import 'package:flutter/material.dart';
import '../../constants/text_styles.dart';
import '../../models/ride_model.dart';
import '../../data/dummy_rides.dart';
import '../../widgets/custom_button.dart';

class EditRideScreen extends StatefulWidget {
  const EditRideScreen({super.key});

  @override
  State<EditRideScreen> createState() => _EditRideScreenState();
}

class _EditRideScreenState extends State<EditRideScreen> {
  late Ride ride;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController fromController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController seatsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      ride = ModalRoute.of(context)!.settings.arguments as Ride;
      
      // Step 1: Initialize controllers with existing ride data
      fromController.text = ride.from;
      destinationController.text = ride.destination;
      dateController.text = ride.date;
      timeController.text = ride.time;
      seatsController.text = ride.availableSeats.toString();
      priceController.text = ride.price.toString();
      notesController.text = ride.notes;
      
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    fromController.dispose();
    destinationController.dispose();
    dateController.dispose();
    timeController.dispose();
    seatsController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // Step 2: Save Changes Logic
  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final index = dummyRides.indexWhere((r) => r.rideId == ride.rideId);
      
      if (index != -1) {
        final updatedRide = ride.copyWith(
          from: fromController.text,
          destination: destinationController.text,
          date: dateController.text,
          time: timeController.text,
          availableSeats: int.parse(seatsController.text),
          price: int.parse(priceController.text),
          notes: notesController.text,
        );
        
        setState(() {
          updateRide(updatedRide);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        Navigator.pop(context, true); // Go back with refresh flag
      }
    }
  }

  // Step 3: Cancel Ride Logic
  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _cancelRide();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel Ride'),
          ),
        ],
      ),
    );
  }

  void _cancelRide() {
    setState(() {
      deleteRide(ride.rideId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ride cancelled successfully'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    Navigator.pop(context, true); // Go back with refresh flag
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Ride'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('From *'),
              _buildTextField(fromController, 'Starting location', Icons.location_on, Colors.blue),
              
              const SizedBox(height: 20),
              
              _buildLabel('Destination *'),
              _buildTextField(destinationController, 'Where to?', Icons.location_on, Colors.green),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Date *'),
                        _buildTextField(dateController, 'YYYY-MM-DD', Icons.calendar_today, Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Time *'),
                        _buildTextField(timeController, 'HH:MM AM/PM', Icons.access_time, Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Available Seats *'),
                        _buildTextField(seatsController, 'Count', Icons.people, Colors.grey, isNumber: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Price per Seat *'),
                        _buildTextField(priceController, 'PKR', Icons.attach_money, Colors.grey, isNumber: true),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              _buildLabel('Notes (Optional)'),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Near Starbucks',
                  hintStyle: AppTextStyles.inputHint,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              CustomButton(
                text: 'Save Changes',
                onPressed: _saveChanges,
              ),
              
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _showCancelConfirmation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel Ride', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.inputLabel),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, Color iconColor, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.inputHint,
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
