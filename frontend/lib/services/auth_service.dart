import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'navigation_state_service.dart';

class AuthService {
  static const String baseUrl = 'https://transitshare-production.up.railway.app/api/auth';

  // Login user
  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);

        // Store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        // Save user session and navigation state
        await NavigationStateService.saveUserSession(
          userId: user.id,
          userName: user.name,
          email: user.email,
          points: user.points,
        );

        // Update last active time
        await NavigationStateService.updateLastActiveTime();

        return user;
      } else {
        print('Login failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Register user
  static Future<User?> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);

        // Store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        // Save user session and navigation state
        await NavigationStateService.saveUserSession(
          userId: user.id,
          userName: user.name,
          email: user.email,
          points: user.points,
        );

        // Update last active time
        await NavigationStateService.updateLastActiveTime();

        return user;
      } else {
        print('Registration failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Get stored user with session validation
  static Future<User?> getStoredUser() async {
    try {
      // Check if session is still valid
      final isValid = await NavigationStateService.isSessionValid();
      if (!isValid) {
        await logout();
        return null;
      }

      // Get user session from navigation state service
      final sessionData = await NavigationStateService.getUserSession();
      if (sessionData != null) {
        return User(
          id: sessionData['userId'],
          name: sessionData['userName'],
          email: sessionData['email'],
          points: sessionData['points'] ?? 0,
          walletBalance: 0.0,
        );
      }

      return null;
    } catch (e) {
      print('Error getting stored user: $e');
      return null;
    }
  }

  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Auto-login with stored credentials
  static Future<User?> autoLogin() async {
    try {
      final token = await getStoredToken();
      if (token == null) return null;

      // Validate session
      final isValid = await NavigationStateService.isSessionValid();
      if (!isValid) {
        await logout();
        return null;
      }

      // Get stored user data
      final user = await getStoredUser();
      if (user != null) {
        // Update last active time
        await NavigationStateService.updateLastActiveTime();
        return user;
      }

      return null;
    } catch (e) {
      print('Auto-login error: $e');
      return null;
    }
  }

  // Logout and clear all state
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      // Clear all navigation and session state
      await NavigationStateService.clearAllState();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    if (token == null) return false;

    return await NavigationStateService.isSessionValid();
  }
}
