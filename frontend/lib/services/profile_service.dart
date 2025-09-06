import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ProfileService {
  static const String baseUrl = 'https://transitshare-production.up.railway.app/api/profile';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get user profile
  static Future<User?> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        print('Failed to get profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<User?> updateProfile({
    String? name,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      
      if (name != null) body['name'] = name;
      if (profile != null) body['profile'] = profile;
      if (preferences != null) body['preferences'] = preferences;

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        print('Failed to update profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  // Update profile picture
  static Future<bool> updateProfilePicture(String avatarUrl) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/avatar'),
        headers: headers,
        body: json.encode({'avatar': avatarUrl}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile picture: $e');
      return false;
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>?> getUserStatistics() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/statistics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to get statistics: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting statistics: $e');
      return null;
    }
  }

  // Change password
  static Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/password'),
        headers: headers,
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Delete account
  static Future<bool> deleteAccount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(baseUrl),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
}
