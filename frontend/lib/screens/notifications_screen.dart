import 'package:flutter/material.dart';
import '../widgets/auto_hide_bottom_nav.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'icon': Icons.directions_bus,
        'title': 'Bus 42 has arrived',
        'subtitle': 'Your tracked bus just reached your stop',
        'time': '2m ago',
      },
      {
        'icon': Icons.card_giftcard,
        'title': 'Weekly Goal Achieved',
        'subtitle': 'You earned 50 bonus points',
        'time': '1h ago',
      },
      {
        'icon': Icons.security,
        'title': 'Password Changed',
        'subtitle': 'Your password was changed successfully',
        'time': '1d ago',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF000817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000817),
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: AutoHideBottomNav.show,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final n = notifications[idx];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF001021),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF19C6FF).withOpacity(0.2),
                    child: Icon(n['icon'] as IconData, color: const Color(0xFF19C6FF), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(n['subtitle'] as String, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(n['time'] as String, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
