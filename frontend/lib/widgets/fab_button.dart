import 'package:flutter/material.dart';

class FabButton extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onPressed;

  const FabButton({super.key, required this.icon, required this.colors, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(color: colors.last.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
          ],
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
