import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/navigation_state_service.dart';
import '../models/user_model.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/location_sharing_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  User? _user;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Try auto-login first
      final user = await AuthService.autoLogin();
      
      if (user != null) {
        setState(() {
          _user = user;
        });

        // Get last visited screen for navigation restoration
        final lastScreen = await NavigationStateService.getLastScreen();
        if (lastScreen != null) {
          setState(() {
            _initialRoute = lastScreen['screen'];
          });
        } else {
          // Default to home screen if no last screen saved
          setState(() {
            _initialRoute = '/home';
          });
        }
      } else {
        // User not logged in, clear any stale state
        await NavigationStateService.clearSessionData();
        setState(() {
          _initialRoute = '/login';
        });
      }
    } catch (e) {
      print('Error initializing app: $e');
      setState(() {
        _initialRoute = '/login';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF1A1A2E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19C6FF)),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading TransitShare...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Restoring your session',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If user is not logged in, show login screen
    if (_user == null) {
      return const LoginScreen();
    }

    // User is logged in, navigate to appropriate screen
    return _getInitialScreen();
  }

  Widget _getInitialScreen() {
    // Save current navigation state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationStateService.updateLastActiveTime();
    });

    switch (_initialRoute) {
      case '/location_sharing':
        return const LocationSharingScreen();
      case '/home':
      default:
        return const HomeScreen();
    }
  }
}
