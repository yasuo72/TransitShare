import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070024), Color(0xFF140039)],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo box with glow
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A2CF0), Color(0xFF19C6FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF19C6FF).withOpacity(0.7),
                    blurRadius: 30,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: const Icon(Icons.compare_arrows, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 32),
            Text(
              'TransitShare',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF50C9FF),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Earn points when you share,\nsave time when you track.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            GradientButton(
              text: 'Get Started',
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Colors.black54),
                backgroundColor: const Color(0xFF060811),
              ),
              onPressed: () {},
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
