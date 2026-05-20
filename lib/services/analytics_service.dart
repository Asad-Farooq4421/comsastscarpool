import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ==================== SCREEN TRACKING ====================

  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ==================== USER JOURNEY EVENTS ====================

  static Future<void> logUserLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logUserSignup(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> logUserLogout() async {
    await _analytics.logEvent(name: 'user_logout');
  }

  static Future<void> logProfileUpdate({String? fieldUpdated}) async {
    await _analytics.logEvent(
      name: 'profile_update',
      parameters: fieldUpdated != null ? {'field_updated': fieldUpdated} : null,
    );
  }

  // ==================== ROLE SWITCHING EVENTS ====================

  static Future<void> logRoleSwitch(String role) async {
    await _analytics.logEvent(
      name: 'role_switch',
      parameters: {'role': role},
    );
  }

  static Future<void> logBecameDriver({required bool hasVehicle}) async {
    await _analytics.logEvent(
      name: 'became_driver',
      parameters: {'has_vehicle': hasVehicle},
    );
  }

  // ==================== LOGOUT ====================

  static Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  // ==================== RIDE RELATED EVENTS ====================

  static Future<void> logRidePosted({
    required double price,
    required int seats,
    required String destination,
  }) async {
    await _analytics.logEvent(
      name: 'ride_posted',
      parameters: {
        'price': price,
        'seats': seats,
        'destination': destination,
      },
    );
  }

  static Future<void> logRideSearched({
    required String from,
    required String to,
    required String date,
  }) async {
    await _analytics.logEvent(
      name: 'ride_searched',
      parameters: {
        'from': from,
        'to': to,
        'date': date,
      },
    );
  }

  static Future<void> logRideRequested({
    required String rideId,
    required String driverId,
  }) async {
    await _analytics.logEvent(
      name: 'ride_requested',
      parameters: {
        'ride_id': rideId,
        'driver_id': driverId,
      },
    );
  }

  static Future<void> logRideAccepted({
    required String rideId,
    required String passengerId,
  }) async {
    await _analytics.logEvent(
      name: 'ride_accepted',
      parameters: {
        'ride_id': rideId,
        'passenger_id': passengerId,
      },
    );
  }

  static Future<void> logRideDeclined({
    required String rideId,
  }) async {
    await _analytics.logEvent(
      name: 'ride_declined',
      parameters: {'ride_id': rideId},
    );
  }

  static Future<void> logRideCancelled({
    required String role,
  }) async {
    await _analytics.logEvent(
      name: 'ride_cancelled',
      parameters: {'role': role},
    );
  }

  static Future<void> logRideCompleted({
    required String rideId,
    required double rating,
    int? duration,
  }) async {
    await _analytics.logEvent(
      name: 'ride_completed',
      parameters: {
        'ride_id': rideId,
        'rating': rating,
        if (duration != null) 'duration_minutes': duration,
      },
    );
  }

  // ==================== ENGAGEMENT EVENTS ====================

  static Future<void> logChatStarted({
    required String rideId,
  }) async {
    await _analytics.logEvent(
      name: 'chat_started',
      parameters: {'ride_id': rideId},
    );
  }

  static Future<void> logMessageSent({
    required String chatId,
  }) async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {'chat_id': chatId},
    );
  }

  static Future<void> logRatingGiven({
    required double rating,
    required String role,
  }) async {
    await _analytics.logEvent(
      name: 'rating_given',
      parameters: {
        'rating': rating,
        'role': role,
      },
    );
  }

  static Future<void> logSettingsUpdated({
    required String settingName,
  }) async {
    await _analytics.logEvent(
      name: 'settings_updated',
      parameters: {'setting_name': settingName},
    );
  }

  // ==================== USER PROPERTIES ====================

  static Future<void> setUserRole(String role) async {
    await _analytics.setUserProperty(name: 'user_role', value: role);
  }

  static Future<void> setUserId(String uid) async {
    await _analytics.setUserId(id: uid);
  }
}