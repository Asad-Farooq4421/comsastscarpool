import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Your existing API key (keep this)
  static const String _apiKey = 'AIzaSyCReGJ02_ej2uy69mmywRDVSyU-9IVrark';

  // ✅ CHANGE THIS LINE - Use gemini-2.0-flash
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<int?> suggestPrice({
    required String from,
    required String to,
    required String time,
    required int seats,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      final prompt = """
Suggest a fair price per seat in Pakistani Rupees (PKR) for a university ride-sharing trip.
Trip details:
- From: $from
- To: $to
- Departure time: $time
- Available seats: $seats

Consider student budgets and local fuel prices.

RESPOND WITH ONLY A NUMBER. No text, no symbols.
Example: 150
""";

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.2,
            "maxOutputTokens": 10,
          }
        }),
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final priceText = data['candidates'][0]['content']['parts'][0]['text'].trim();
        print('AI response: $priceText');

        final price = int.tryParse(priceText.replaceAll(RegExp(r'[^0-9]'), ''));
        return price;
      } else {
        print('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}