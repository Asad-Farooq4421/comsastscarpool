import 'package:flutter/foundation.dart' show kIsWeb;

class MapService {
  static String getApiKey() {
    // You can store your API key in a config file
    // Don't hardcode in production! Use environment variables
    return 'AIzaSyBHMz2ya8SWcRLceJBGGSItVZ_GHzl6elI';
  }

  static bool isWeb() => kIsWeb;

  static bool isMobile() => !kIsWeb;
}