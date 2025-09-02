import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';
import '../widgets/auto_hide_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000817),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        elevation: 0,
      ),
      bottomNavigationBar: AutoHideBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (i == 1) {
            Navigator.pushReplacementNamed(context, '/rewards');
          }
        },
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: AutoHideBottomNav.show,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _avatar(),
            const SizedBox(height: 12),
            const Text('Alex Chen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            const Text('Route 78 Driver', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.circle, size: 8, color: Color(0xFF26C281)),
                SizedBox(width: 4),
                Text('Active', style: TextStyle(color: Color(0xFF26C281), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),
            _statsRow(),
            const SizedBox(height: 24),
            _walletCard(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent Activity', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            _activityItem(Icons.attach_money, 'Tip received', '+\$2.00', 'From passenger on Route 78', '2h ago', color: const Color(0xFF26C281)),
            const SizedBox(height: 8),
            _activityItem(Icons.location_on, 'Location shared', '+15 pts', '45 minutes on Route 78', '5h ago', color: const Color(0xFF7A2CF0)),
            const SizedBox(height: 24),
            _settingsTile('Settings', Icons.settings),
            const SizedBox(height: 8),
            _settingsTile('Sign Out', Icons.logout, danger: true),
          ],
        ),
      ),
    ),
  );
  }

  Widget _avatar() {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF19C6FF), Color(0xFF7A2CF0)]),
      ),
      child: const Center(
        child: Text('AC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24)),
      ),
    );
  }

  Widget _statsRow() {
    Widget stat(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(value, style: const TextStyle(color: Color(0xFF19C6FF), fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        );

    return Row(
      children: [
        stat('127', 'Rides Shared'),
        stat('250', 'Points Earned'),
        stat('89', 'Tips Received'),
      ],
    );
  }

  Widget _walletCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF001021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF19C6FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.add, color: Colors.white54, size: 18), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _walletStat('Available Balance', '\$12.50', Color(0xFF26C281)),
              ),
              Expanded(
                child: _walletStat('Pending Points', '45 pts', Color(0xFF7A2CF0)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'Withdraw',
                  colors: const [Color(0xFF26C281), Color(0xFF26C281)],
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF19C6FF)),
                  ),
                  child: const Text('Redeem', style: TextStyle(color: Color(0xFF19C6FF))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityItem(IconData icon, String title, String value, String sub, String time, {required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF001021),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              Text(time, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(String title, IconData icon, {bool danger = false}) {
    return ListTile(
      tileColor: danger ? Colors.transparent : const Color(0xFF001021),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(title, style: TextStyle(color: danger ? const Color(0xFFFF4D4F) : Colors.white)),
      leading: Icon(icon, color: danger ? const Color(0xFFFF4D4F) : Colors.white54),
      trailing: danger ? null : const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }
}

class _walletStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _walletStat(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
