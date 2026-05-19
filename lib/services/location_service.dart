import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Check if location services are enabled
  Future<bool> isLocationServicesEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permissions
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermission.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermission.deniedForever;
    }

    return permission;
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    // Check if services are enabled
    bool serviceEnabled = await isLocationServicesEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check permissions
    LocationPermission permission = await requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Convert Position to LatLng (for Google Maps)
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  // Calculate distance between two locations (in meters)
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude, start.longitude,
      end.latitude, end.longitude,
    );
  }

  // Calculate distance in kilometers
  double calculateDistanceInKm(LatLng start, LatLng end) {
    double meters = calculateDistance(start, end);
    return meters / 1000;
  }

  // Calculate estimated fuel cost (example: Rs. 20 per km)
  int calculateFuelCost(LatLng start, LatLng end) {
    double km = calculateDistanceInKm(start, end);
    double costPerKm = 20.0; // Adjust based on fuel price
    return (km * costPerKm).round();
  }

  // Suggest ride fare (fuel cost + profit)
  int suggestRideFare(LatLng start, LatLng end, int availableSeats) {
    int fuelCost = calculateFuelCost(start, end);
    // Add 20% profit margin, divided by available seats
    int totalFare = (fuelCost * 1.2).round();
    return totalFare ~/ availableSeats;
  }

  // Get address from coordinates (Reverse Geocoding) - FIXED
  Future<String?> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Build address string
        List<String> addressParts = [];

        if (place.name != null && place.name!.isNotEmpty) addressParts.add(place.name!);
        if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) addressParts.add(place.subThoroughfare!);
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) addressParts.add(place.thoroughfare!);
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add(place.administrativeArea!);
        if (place.postalCode != null && place.postalCode!.isNotEmpty) addressParts.add(place.postalCode!);
        if (place.country != null && place.country!.isNotEmpty) addressParts.add(place.country!);

        return addressParts.join(', ');
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  // Get coordinates from address (Forward Geocoding) - FIXED
  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  // Listen to location updates (for live tracking)
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }
}