import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/share_ride_screen.dart';
import 'screens/track_vehicle_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TransitShareApp());
}

class TransitShareApp extends StatelessWidget {
  const TransitShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TransitShare',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/share': (_) => const ShareRideScreen(),
        '/track': (_) => const TrackVehicleScreen(),
        '/rewards': (_) => const RewardsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/notifications': (_) => const NotificationsScreen(),
      },
    );
  }
}
