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
        width: MediaQuery.of(context).size.width * 0.15,
        height: MediaQuery.of(context).size.width * 0.15,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(color: colors.last.withOpacity(0.4), blurRadius: MediaQuery.of(context).size.width * 0.03, offset: Offset(0, MediaQuery.of(context).size.width * 0.01))
          ],
        ),
        child: Icon(icon, color: Colors.white, size: MediaQuery.of(context).size.width * 0.08),
      ),
    );
  }
}
