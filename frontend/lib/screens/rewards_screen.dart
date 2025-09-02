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
        title: Text('Rewards', style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.05)),
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
            _balanceCard(context),
            const SizedBox(height: 16),
            _progressBar(context, 'Weekly Goal', 45, 50, color: const Color(0xFF7A2CF0)),
            const SizedBox(height: 12),
            _progressBar(context, 'Monthly Challenge', 180, 200),
            const SizedBox(height: 24),
            Text('Achievements', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.045)),
            const SizedBox(height: 12),
            _achievementsRow(context),
            const SizedBox(height: 24),
            Text('Weekly Leaderboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.045)),
            const SizedBox(height: 12),
            _leaderItem(context, 1, 'Sarah M.', 'Route 15 Driver', 485, highlight: false),
            const SizedBox(height: 8),
            _leaderItem(context, 2, 'Mike R.', 'Route 42 Driver', 420, highlight: false),
            const SizedBox(height: 8),
            _leaderItem(context, 3, 'You', 'Route 78 Driver', 250, highlight: true),
            const SizedBox(height: 32),
            GradientButton(text: 'Redeem Points', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
        color: const Color(0xFF001021),
        border: Border.all(color: const Color(0xFF19C6FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('250 Points', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.width * 0.06)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text('Your current balance', style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.04)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            children: const [
              const Expanded(child: _Stat('+45', 'This Week')),
              const Expanded(child: _Stat('+12', 'Today')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressBar(BuildContext context, String label, int value, int total, {Color color = const Color(0xFF19C6FF)}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.white70, fontSize: MediaQuery.of(context).size.width * 0.035)),
            Text('$value/$total pts', style: TextStyle(color: Colors.white70, fontSize: MediaQuery.of(context).size.width * 0.03)),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.005),
        ClipRRect(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.01),
          child: LinearProgressIndicator(
            value: value / total,
            minHeight: MediaQuery.of(context).size.height * 0.008,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: Colors.white10,
          ),
        ),
      ],
    );
  }

  Widget _achievementsRow(BuildContext context) {
        Widget badge(String title, IconData icon, {bool locked = false}) => Container(
          width: MediaQuery.of(context).size.width * 0.28,
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
          decoration: BoxDecoration(
            color: locked ? Colors.white12 : const Color(0xFF001021),
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
            border: Border.all(color: const Color(0xFF19C6FF)),
          ),
          child: Column(
            children: [
              Icon(icon, color: locked ? Colors.white24 : const Color(0xFF19C6FF), size: MediaQuery.of(context).size.width * 0.08),
              SizedBox(height: MediaQuery.of(context).size.height * 0.0075),
              Text(title, textAlign: TextAlign.center, style: TextStyle(color: locked ? Colors.white24 : Colors.white, fontSize: MediaQuery.of(context).size.width * 0.03)),
            ],
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        badge( 'Route Hero', Icons.shield_outlined),
        badge('Night Tracker', Icons.nightlight_outlined),
        badge('Locked', Icons.lock, locked: true),
      ],
    );
  }

  Widget _leaderItem(BuildContext context, int rank, String name, String sub, int pts, {bool highlight = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF001021),
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.025),
        border: highlight ? Border.all(color: const Color(0xFF19C6FF)) : null,
      ),
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.015, horizontal: MediaQuery.of(context).size.width * 0.03),
      child: Row(
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.04,
            backgroundColor: const Color(0xFF7A2CF0),
            child: Text(rank.toString(), style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.03)),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.04)),
                Text(sub, style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.03)),
              ],
            ),
          ),
          Text('$pts pts', style: TextStyle(color: const Color(0xFF19C6FF), fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.04)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: const Color(0xFF19C6FF), fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.04)),
        SizedBox(height: MediaQuery.of(context).size.height * 0.0025),
        Text(label, style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.035)),
      ],
    );
  }
}
