import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';
import '../widgets/auto_hide_bottom_nav.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  void _handleNav(BuildContext context, int i) {
    if (i == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (i == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000817),
        title: const Text('Rewards', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
      ),
      bottomNavigationBar: AutoHideBottomNav(
        currentIndex: 1,
        onTap: (i) => _handleNav(context, i),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: AutoHideBottomNav.show,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _balanceCard(),
            const SizedBox(height: 16),
            _progressBar('Weekly Goal', 45, 50, color: const Color(0xFF7A2CF0)),
            const SizedBox(height: 12),
            _progressBar('Monthly Challenge', 180, 200),
            const SizedBox(height: 24),
            const Text('Achievements', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _achievementsRow(),
            const SizedBox(height: 24),
            const Text('Weekly Leaderboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _leaderItem(1, 'Sarah M.', 'Route 15 Driver', 485, highlight: false),
            const SizedBox(height: 8),
            _leaderItem(2, 'Mike R.', 'Route 42 Driver', 420, highlight: false),
            const SizedBox(height: 8),
            _leaderItem(3, 'You', 'Route 78 Driver', 250, highlight: true),
            const SizedBox(height: 32),
            GradientButton(text: 'Redeem Points', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF001021),
        border: Border.all(color: const Color(0xFF19C6FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('250 Points', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
          const SizedBox(height: 4),
          const Text('Your current balance', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _stat('+45', 'This Week')),
              Expanded(child: _stat('+12', 'Today')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressBar(String label, int value, int total, {Color color = const Color(0xFF19C6FF)}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text('$value/$total pts', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / total,
            minHeight: 6,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: Colors.white10,
          ),
        ),
      ],
    );
  }

  Widget _achievementsRow() {
    Widget badge(String title, IconData icon, {bool locked = false}) => Container(
          width: 92,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: locked ? Colors.white12 : const Color(0xFF001021),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF19C6FF)),
          ),
          child: Column(
            children: [
              Icon(icon, color: locked ? Colors.white24 : const Color(0xFF19C6FF)),
              const SizedBox(height: 6),
              Text(title, textAlign: TextAlign.center, style: TextStyle(color: locked ? Colors.white24 : Colors.white, fontSize: 11)),
            ],
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        badge('Route Hero', Icons.shield_outlined),
        badge('Night Tracker', Icons.nightlight_outlined),
        badge('Locked', Icons.lock, locked: true),
      ],
    );
  }

  Widget _leaderItem(int rank, String name, String sub, int pts, {bool highlight = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF001021),
        borderRadius: BorderRadius.circular(10),
        border: highlight ? Border.all(color: const Color(0xFF19C6FF)) : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF7A2CF0),
            child: Text(rank.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Text('$pts pts', style: const TextStyle(color: Color(0xFF19C6FF), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _stat extends StatelessWidget {
  final String value;
  final String label;
  const _stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Color(0xFF19C6FF), fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
