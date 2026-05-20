import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late GenerativeModel _model;
  bool _isInitialized = false;

  // Initialize with your Gemini API key
  void initialize(String apiKey) {
    // Using Gemini 2.5 Flash - Best for price prediction tasks
    // You can change to 'gemini-2.5-flash-lite' for faster responses
    // or 'gemini-2.5-pro' for more complex reasoning
    const String modelName = 'gemini-2.5-flash';

    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 1,
        topP: 0.8,
        maxOutputTokens: 100,
      ),
    );
    _isInitialized = true;

    print('✅ GeminiService initialized with model: $modelName');
  }

  // Predict ride price based on distance, location, and seats
  Future<int> predictPrice({
    required double distanceKm,
    required String pickupArea,
    required String dropoffArea,
    required int availableSeats,
    required String timeOfDay,
    required String date,
  }) async {
    if (!_isInitialized) {
      throw Exception('GeminiService not initialized. Call initialize() first.');
    }

    // Check if distance is valid
    if (distanceKm <= 0) {
      return 150; // Default price for very short distances
    }

    final prompt = '''
You are a ride-sharing price predictor for Islamabad, Pakistan. 
Predict a fair price per seat for a carpool ride based on these details:

- Distance: ${distanceKm.toStringAsFixed(1)} km
- Pickup area: $pickupArea
- Dropoff area: $dropoffArea  
- Available seats: $availableSeats
- Time: $timeOfDay
- Date: $date

Local pricing context:
- COMSATS to F-10 (8 km): Rs. 150-180
- COMSATS to Blue Area (10 km): Rs. 180-220
- F-10 to Centaurus (5 km): Rs. 100-130
- Fuel price: ~Rs. 280/Litre
- Average car mileage: 12 km/L

Pricing rules:
1. Base rate: Rs. 18-22 per km
2. Add Rs. 10-20 during peak hours (8-10 AM, 5-7 PM)
3. Add Rs. 10-30 if dropoff is in prime location (Blue Area, Centaurus, F-10, F-11, G-11)
4. Slightly reduce price (-Rs. 10-20) for more available seats (3-4 seats)
5. Round to nearest 10 rupees
6. Minimum price: Rs. 100
7. Maximum price: Rs. 500

Return ONLY the number (integer), no explanation, no currency symbol.
Example: 180
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final priceText = response.text?.trim() ?? '';

      // Extract number from response (remove any non-numeric characters)
      final priceMatch = RegExp(r'\d+').firstMatch(priceText);
      final price = priceMatch != null ? int.parse(priceMatch.group(0)!) : 0;

      // Validate price range
      if (price < 50) return 150;
      if (price > 600) return 400;
      return price;
    } catch (e) {
      print('❌ Gemini prediction error: $e');
      // Fallback calculation if Gemini fails
      return _calculateFallbackPrice(distanceKm, availableSeats);
    }
  }

  // Predict price with additional context (more detailed)
  Future<int> predictPriceDetailed({
    required double distanceKm,
    required String pickupAddress,
    required String dropoffAddress,
    required int availableSeats,
    required String timeOfDay,
    required String date,
    required String vehicleType,
  }) async {
    if (!_isInitialized) {
      throw Exception('GeminiService not initialized. Call initialize() first.');
    }

    final prompt = '''
You are a ride-sharing price predictor for Islamabad, Pakistan.

Trip Details:
- Distance: ${distanceKm.toStringAsFixed(1)} km
- Pickup: $pickupAddress
- Dropoff: $dropoffAddress
- Available seats: $availableSeats
- Time: $timeOfDay
- Date: $date
- Vehicle: $vehicleType

Calculate fair price per seat in PKR considering:
1. Base cost: Fuel (Rs. 280/L, 12 km/L = Rs. 23.3 per km)
2. Driver profit: 20-30% margin
3. Peak hour surcharge: +Rs. 20 if 8-10 AM or 5-7 PM
4. Location premium: +Rs. 10-30 for prime areas (Blue Area, Centaurus, F-10, F-11, G-11, DHA, Bahria)
5. Seat adjustment: -Rs. 10 if seats >= 3
6. Weekend adjustment: +Rs. 10-20 on Friday/Saturday if applicable

Return ONLY the final integer price (Rs. 100-500).
Example: 180
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final priceText = response.text?.trim() ?? '';
      final priceMatch = RegExp(r'\d+').firstMatch(priceText);
      final price = priceMatch != null ? int.parse(priceMatch.group(0)!) : 0;

      return price.clamp(100, 500);
    } catch (e) {
      print('❌ Gemini detailed prediction error: $e');
      return _calculateFallbackPrice(distanceKm, availableSeats);
    }
  }

  // Get fare breakdown explanation (optional)
  Future<String> getFareBreakdown({
    required double distanceKm,
    required String pickupArea,
    required String dropoffArea,
    required int availableSeats,
    required String timeOfDay,
  }) async {
    if (!_isInitialized) {
      throw Exception('GeminiService not initialized');
    }

    final prompt = '''
Explain fare breakdown for a ${distanceKm.toStringAsFixed(1)} km ride from $pickupArea to $dropoffArea at $timeOfDay with $availableSeats seats.
Show:
- Base fare (km × Rs. 20)
- Fuel cost calculation
- Peak hour adjustment (if any)
- Per seat price
Keep it short, 2-3 lines only.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Price calculated based on distance and local rates.';
    } catch (e) {
      print('❌ Fare breakdown error: $e');
      return 'Price calculated based on standard rates.';
    }
  }

  // Suggest price based on simple text query (alternative method)
  Future<int> suggestPrice({
    required String from,
    required String to,
    required String time,
    required int seats,
  }) async {
    if (!_isInitialized) {
      throw Exception('GeminiService not initialized');
    }

    final prompt = '''
Suggest fair price per seat (in PKR) for carpool in Islamabad.
Route: $from to $to
Time: $time
Seats: $seats

Rules: Rs 15-20 per km estimated. Add Rs 10-20 for peak hours (8-10 AM, 5-7 PM).
Return ONLY number (100-500).
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final priceText = response.text?.trim() ?? '';
      final priceMatch = RegExp(r'\d+').firstMatch(priceText);
      final price = priceMatch != null ? int.parse(priceMatch.group(0)!) : 150;
      return price.clamp(100, 500);
    } catch (e) {
      print('❌ Suggest price error: $e');
      return 150;
    }
  }

  // Fallback calculation if Gemini fails
  int _calculateFallbackPrice(double distanceKm, int availableSeats) {
    // Base rate: Rs. 18 per km
    double basePrice = distanceKm * 18;

    // Adjust for seats (more seats = slightly lower per seat)
    double seatFactor = availableSeats > 2 ? 0.9 : 1.0;

    int finalPrice = (basePrice * seatFactor).round();

    // Round to nearest 10
    finalPrice = (finalPrice / 10).round() * 10;

    // Clamp between 100 and 500
    if (finalPrice < 100) return 100;
    if (finalPrice > 500) return 500;
    return finalPrice;
  }

  // Check if service is initialized
  bool get isInitialized => _isInitialized;

  // Get current model name
  String get modelName => _isInitialized ? 'gemini-2.5-flash' : 'Not initialized';

  // Test the API connection
  Future<bool> testConnection() async {
    if (!_isInitialized) return false;

    try {
      final response = await _model.generateContent([
        Content.text('Say "OK" if you are working properly.')
      ]);
      print('✅ Gemini test response: ${response.text}');
      return true;
    } catch (e) {
      print('❌ Gemini test failed: $e');
      return false;
    }
  }
}