import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/google_place_service.dart';
import '../../services/location_service.dart';


class LocationPickerScreen extends StatefulWidget {
  final String title;
  final LatLng? initialLocation;
  final Function(LatLng, String) onLocationSelected;

  const LocationPickerScreen({
    Key? key,
    required this.title,
    this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<PlaceSuggestion> _suggestions = [];
  final LocationService _locationService = LocationService();

  Timer? _debounceTimer;

  static const LatLng _defaultLocation = LatLng(33.7189, 73.0585);

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? _defaultLocation;
    _getAddressFromLocation(_selectedLocation!);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromLocation(LatLng location) async {
    setState(() => _isLoading = true);

    try {
      final address = await GooglePlacesService.instance.getAddressFromCoordinates(location);
      print('📍 Got address: $address'); // Debug
      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Address error: $e');
      setState(() {
        _selectedAddress = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty || query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await GooglePlacesService.instance.getAutocomplete(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('❌ Search error: $e');
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    setState(() {
      _isSearching = true;
      _suggestions = [];
      _searchController.clear();
    });

    try {
      final details = await GooglePlacesService.instance.getPlaceDetails(suggestion.placeId);

      if (details != null && mounted) {
        final location = details.latLng;

        await _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: location, zoom: 17),
          ),
        );

        setState(() {
          _selectedLocation = location;
          _selectedAddress = details.formattedAddress;
          _isSearching = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 ${details.name}'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isSearching = false);
      }
    } catch (e) {
      print('❌ Selection error: $e');
      setState(() => _isSearching = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    final newLocation = position.target;
    if (_selectedLocation != newLocation) {
      _selectedLocation = newLocation;
      _getAddressFromLocation(newLocation);
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null && _selectedAddress.isNotEmpty) {
      print('✅ Confirming location: $_selectedAddress'); // Debug
      widget.onLocationSelected(_selectedLocation!, _selectedAddress);
      Navigator.pop(context);
    }
  }

  void _centerOnCurrentLocation() async {
    setState(() => _isLoading = true);

    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      final latLng = LatLng(position.latitude, position.longitude);
      await _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 17),
        ),
      );
      setState(() {
        _selectedLocation = latLng;
        _isLoading = false;
      });
      _getAddressFromLocation(latLng);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get your location. Please enable GPS.')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Search Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location (e.g., COMSATS, F-10, Centaurus)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _suggestions = []);
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),

                  // Search suggestions
                  if (_suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.green),
                            title: Text(
                              suggestion.mainText,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              suggestion.secondaryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Google Map
          Positioned(
            top: _suggestions.isNotEmpty ? 200 : 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation ?? _defaultLocation,
                zoom: 15,
              ),
              onCameraMove: _onCameraMove,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              markers: _selectedLocation != null
                  ? {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selectedLocation!,
                  infoWindow: InfoWindow(
                    title: widget.title,
                    snippet: _selectedAddress,
                  ),
                ),
              }
                  : {},
            ),
          ),

          // Center pin indicator
          IgnorePointer(
            child: Center(
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading || _isSearching)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Bottom card with address
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Selected Location',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedAddress.isEmpty ? 'Move map to select location' : _selectedAddress,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _centerOnCurrentLocation,
                            icon: const Icon(Icons.my_location),
                            label: const Text('My Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _confirmLocation,
                            icon: const Icon(Icons.check),
                            label: const Text('Confirm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}