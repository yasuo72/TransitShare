import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NavigationStateService {
  static const String _lastScreenKey = 'last_screen';
  static const String _appStateKey = 'app_state';
  static const String _userSessionKey = 'user_session';
  static const String _locationSharingStateKey = 'location_sharing_state';
  static const String _mapStateKey = 'map_state';
  static const String _lastActiveTimeKey = 'last_active_time';

  // Save last visited screen
  static Future<void> saveLastScreen(String screenName, {Map<String, dynamic>? arguments}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final screenData = {
        'screen': screenName,
        'arguments': arguments,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_lastScreenKey, json.encode(screenData));
    } catch (e) {
      print('Error saving last screen: $e');
    }
  }

  // Get last visited screen
  static Future<Map<String, dynamic>?> getLastScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final screenDataString = prefs.getString(_lastScreenKey);
      if (screenDataString != null) {
        final screenData = json.decode(screenDataString);
        
        // Check if the saved screen is not too old (e.g., 7 days)
        final timestamp = DateTime.parse(screenData['timestamp']);
        final now = DateTime.now();
        if (now.difference(timestamp).inDays < 7) {
          return screenData;
        }
      }
      return null;
    } catch (e) {
      print('Error getting last screen: $e');
      return null;
    }
  }

  // Save complete app state
  static Future<void> saveAppState(Map<String, dynamic> state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appState = {
        ...state,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_appStateKey, json.encode(appState));
    } catch (e) {
      print('Error saving app state: $e');
    }
  }

  // Get complete app state
  static Future<Map<String, dynamic>?> getAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appStateString = prefs.getString(_appStateKey);
      if (appStateString != null) {
        return json.decode(appStateString);
      }
      return null;
    } catch (e) {
      print('Error getting app state: $e');
      return null;
    }
  }

  // Save user session data
  static Future<void> saveUserSession({
    required String userId,
    required String userName,
    required String email,
    int? points,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = {
        'userId': userId,
        'userName': userName,
        'email': email,
        'points': points ?? 0,
        'preferences': preferences ?? {},
        'lastLogin': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_userSessionKey, json.encode(sessionData));
    } catch (e) {
      print('Error saving user session: $e');
    }
  }

  // Get user session data
  static Future<Map<String, dynamic>?> getUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionString = prefs.getString(_userSessionKey);
      if (sessionString != null) {
        return json.decode(sessionString);
      }
      return null;
    } catch (e) {
      print('Error getting user session: $e');
      return null;
    }
  }

  // Save location sharing state
  static Future<void> saveLocationSharingState({
    required bool isSharing,
    String? busName,
    String? busType,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationState = {
        'isSharing': isSharing,
        'busName': busName,
        'busType': busType,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_locationSharingStateKey, json.encode(locationState));
    } catch (e) {
      print('Error saving location sharing state: $e');
    }
  }

  // Get location sharing state
  static Future<Map<String, dynamic>?> getLocationSharingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateString = prefs.getString(_locationSharingStateKey);
      if (stateString != null) {
        final state = json.decode(stateString);
        
        // Check if location sharing state is not too old (e.g., 1 hour)
        final timestamp = DateTime.parse(state['timestamp']);
        final now = DateTime.now();
        if (now.difference(timestamp).inHours < 1) {
          return state;
        }
      }
      return null;
    } catch (e) {
      print('Error getting location sharing state: $e');
      return null;
    }
  }

  // Save map state (camera position, zoom level, etc.)
  static Future<void> saveMapState({
    required double latitude,
    required double longitude,
    required double zoom,
    double? bearing,
    double? tilt,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapState = {
        'latitude': latitude,
        'longitude': longitude,
        'zoom': zoom,
        'bearing': bearing ?? 0.0,
        'tilt': tilt ?? 0.0,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_mapStateKey, json.encode(mapState));
    } catch (e) {
      print('Error saving map state: $e');
    }
  }

  // Get map state
  static Future<Map<String, dynamic>?> getMapState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapStateString = prefs.getString(_mapStateKey);
      if (mapStateString != null) {
        return json.decode(mapStateString);
      }
      return null;
    } catch (e) {
      print('Error getting map state: $e');
      return null;
    }
  }

  // Update last active time
  static Future<void> updateLastActiveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastActiveTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error updating last active time: $e');
    }
  }

  // Get last active time
  static Future<DateTime?> getLastActiveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastActiveTimeKey);
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      print('Error getting last active time: $e');
      return null;
    }
  }

  // Check if user session is still valid
  static Future<bool> isSessionValid() async {
    try {
      final session = await getUserSession();
      if (session == null) return false;

      final lastLogin = DateTime.parse(session['lastLogin']);
      final now = DateTime.now();
      
      // Session is valid for 30 days
      return now.difference(lastLogin).inDays < 30;
    } catch (e) {
      print('Error checking session validity: $e');
      return false;
    }
  }

  // Clear all navigation state (for logout)
  static Future<void> clearAllState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_lastScreenKey),
        prefs.remove(_appStateKey),
        prefs.remove(_userSessionKey),
        prefs.remove(_locationSharingStateKey),
        prefs.remove(_mapStateKey),
        prefs.remove(_lastActiveTimeKey),
      ]);
    } catch (e) {
      print('Error clearing navigation state: $e');
    }
  }

  // Clear only session-related data (keep navigation preferences)
  static Future<void> clearSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_userSessionKey),
        prefs.remove(_locationSharingStateKey),
      ]);
    } catch (e) {
      print('Error clearing session data: $e');
    }
  }

  // Save user preferences
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final session = await getUserSession();
      if (session != null) {
        session['preferences'] = preferences;
        await saveUserSession(
          userId: session['userId'],
          userName: session['userName'],
          email: session['email'],
          points: session['points'],
          preferences: preferences,
        );
      }
    } catch (e) {
      print('Error saving user preferences: $e');
    }
  }

  // Get user preferences
  static Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final session = await getUserSession();
      if (session != null && session['preferences'] != null) {
        return Map<String, dynamic>.from(session['preferences']);
      }
      return {};
    } catch (e) {
      print('Error getting user preferences: $e');
      return {};
    }
  }
}
