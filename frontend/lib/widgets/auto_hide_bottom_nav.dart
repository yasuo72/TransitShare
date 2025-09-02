import 'dart:async';
import 'package:flutter/material.dart';

class AutoHideBottomNav extends StatefulWidget {
  static void show() => _AutoHideBottomNavState._showAll();
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AutoHideBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  State<AutoHideBottomNav> createState() => _AutoHideBottomNavState();
}

class _AutoHideBottomNavState extends State<AutoHideBottomNav> {
  static final Set<_AutoHideBottomNavState> _instances = {};

  bool _visible = true;
  Timer? _timer;

  @override
  void initState() {
    _instances.add(this);

    super.initState();
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _onUserInteraction() {
    if (!_visible && mounted) setState(() => _visible = true);
    _restartTimer();
  }

  void _showBar() {
    if (mounted) setState(() => _visible = true);
    _restartTimer();
  }

  static void _showAll() {
    for (final inst in _instances) {
      inst._showBar();
    }
  }

  @override
  void dispose() {
    _instances.remove(this);

    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bar = BottomNavigationBar(
      backgroundColor: const Color(0xFF001021),
      selectedItemColor: const Color(0xFF19C6FF),
      unselectedItemColor: Colors.white54,
      currentIndex: widget.currentIndex,
      onTap: (i) {
        widget.onTap(i);
        _onUserInteraction();
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), label: 'Rewards'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );

    return Listener(
      onPointerDown: (_) => _onUserInteraction(),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: _visible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _visible ? 1 : 0,
          child: bar,
        ),
      ),
    );
  }
}
