import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/text_styles.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';
import '../../widgets/custom_button.dart';

class EditRideScreen extends StatefulWidget {
  final Ride? ride;

  const EditRideScreen({super.key, this.ride});

  @override
  State<EditRideScreen> createState() => _EditRideScreenState();
}

class _EditRideScreenState extends State<EditRideScreen> {
  late Ride _ride;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInitialized = false;

  final RideService _rideService = RideService();

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // First try to get ride from constructor parameter
      if (widget.ride != null) {
        _ride = widget.ride!;
      } else {
        // Fall back to route arguments
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Ride) {
          _ride = args;
        }
      }

      if (_ride.rideId.isNotEmpty) {
        // Initialize controllers with existing ride data
        _fromController.text = _ride.from;
        _destinationController.text = _ride.destination;
        _dateController.text = _ride.date;
        _timeController.text = _ride.time;
        _seatsController.text = _ride.availableSeats.toString();
        _priceController.text = _ride.price.toString();
        _notesController.text = _ride.notes;

        _isInitialized = true;
      }
    }
  }


  @override
  void dispose() {
    _fromController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Wrapper for save button (returns void, calls async)
  void _onSavePressed() {
    _saveChanges();
  }

  // Wrapper for cancel button (returns void, calls async)
  void _onCancelPressed() {
    _showCancelConfirmation();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final updatedRide = _ride.copyWith(
        from: _fromController.text,
        destination: _destinationController.text,
        date: _dateController.text,
        time: _timeController.text,
        availableSeats: int.parse(_seatsController.text),
        price: int.parse(_priceController.text),
        notes: _notesController.text,
      );

      await _rideService.updateRide(updatedRide);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
              Navigator.pop(context);
              _cancelRide();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel Ride'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRide() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _rideService.deleteRide(_ride.rideId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride cancelled successfully'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              _buildTextField(_fromController, 'Starting location', Icons.location_on, Colors.blue),

              const SizedBox(height: 20),

              _buildLabel('Destination *'),
              _buildTextField(_destinationController, 'Where to?', Icons.location_on, Colors.green),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Date *'),
                        GestureDetector(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dateController.text = pickedDate.toIso8601String().split('T')[0];
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: _buildTextField(_dateController, 'YYYY-MM-DD', Icons.calendar_today, Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Time *'),
                        _buildTextField(_timeController, 'HH:MM AM/PM', Icons.access_time, Colors.grey),
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
                        _buildTextField(_seatsController, 'Count', Icons.people, Colors.grey, isNumber: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Price per Seat *'),
                        _buildTextField(_priceController, 'PKR', Icons.attach_money, Colors.grey, isNumber: true),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildLabel('Notes (Optional)'),
              TextFormField(
                controller: _notesController,
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

              // Save button using wrapper
              CustomButton(
                text: 'Save Changes',
                onPressed: _isLoading ? () {} : _onSavePressed,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 12),

              // Cancel button using wrapper
              CustomButton(
                text: 'Cancel Ride',
                onPressed: _isLoading ? () {} : _onCancelPressed,
                isOutlined: true,
                backgroundColor: Colors.red,
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