import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String _apiKey;

  GooglePlacesService({required String apiKey}) : _apiKey = apiKey;

  static GooglePlacesService? _instance;
  static GooglePlacesService get instance {
    if (_instance == null) {
      throw Exception('GooglePlacesService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static void initialize(String apiKey) {
    _instance = GooglePlacesService(apiKey: apiKey);
  }

  // Autocomplete - Get location suggestions as user types
  Future<List<PlaceSuggestion>> getAutocomplete(String input) async {
    if (input.isEmpty || input.length < 2) {
      return [];
    }

    try {
      final url = Uri.parse(
          '$_baseUrl/autocomplete/json?input=$input&key=$_apiKey&components=country:pk&types=establishment'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List? ?? [];

          return predictions.map((prediction) {
            return PlaceSuggestion(
              placeId: prediction['place_id'],
              description: prediction['description'],
              mainText: prediction['structured_formatting']['main_text'],
              secondaryText: prediction['structured_formatting']['secondary_text'] ?? '',
            );
          }).toList();
        } else {
          print('API Status: ${data['status']} - ${data['error_message']}');
          return [];
        }
      }
    } catch (e) {
      print('Autocomplete error: $e');
    }

    return [];
  }

  // Get detailed place information including coordinates
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/details/json?place_id=$placeId&key=$_apiKey&fields=geometry,formatted_address,name,vicinity'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];

          return PlaceDetails(
            placeId: placeId,
            name: result['name'] ?? '',
            formattedAddress: result['formatted_address'] ?? result['vicinity'] ?? '',
            latitude: location['lat'],
            longitude: location['lng'],
          );
        }
      }
    } catch (e) {
      print('Place details error: $e');
    }

    return null;
  }

  // Get address from coordinates (Reverse Geocoding)
  Future<String> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${coordinates.latitude},${coordinates.longitude}&key=$_apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          // Get the most specific address
          String address = data['results'][0]['formatted_address'];

          // Remove "Pakistan" if present to make it cleaner
          if (address.contains(', Pakistan')) {
            address = address.replaceAll(', Pakistan', '');
          }

          return address;
        }
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }

    // Fallback to coordinates
    return '${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}';
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  LatLng get latLng => LatLng(latitude, longitude);
}