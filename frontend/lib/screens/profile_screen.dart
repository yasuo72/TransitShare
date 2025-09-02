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
            _avatar(context),
            const SizedBox(height: 12),
            Text('Alex Chen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.width * 0.05)),
            Text('Route 78 Driver', style: TextStyle(color: Colors.white70, fontSize: MediaQuery.of(context).size.width * 0.035)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFF26C281)),
                SizedBox(width: 4),
                Text('Active', style: TextStyle(color: Color(0xFF26C281), fontSize: MediaQuery.of(context).size.width * 0.035)),
              ],
            ),
            const SizedBox(height: 24),
            _statsRow(context),
            const SizedBox(height: 24),
            _walletCard(context),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent Activity', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
            const SizedBox(height: 12),
            _activityItem(context, Icons.attach_money, 'Tip received', '+\$2.00', 'From passenger on Route 78', '2h ago', color: const Color(0xFF26C281)),
            const SizedBox(height: 8),
            _activityItem(context, Icons.location_on, 'Location shared', '+15 pts', '45 minutes on Route 78', '5h ago', color: const Color(0xFF7A2CF0)),
            const SizedBox(height: 24),
            _settingsTile(context, 'Settings', Icons.settings),
            const SizedBox(height: 8),
            _settingsTile(context, 'Sign Out', Icons.logout, danger: true),
          ],
        ),
      ),
    ),
  );
  }

  Widget _avatar(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.width * 0.25,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF19C6FF), Color(0xFF7A2CF0)]),
      ),
      child: Center(
        child: Text('AC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.width * 0.08)),
      ),
    );
  }

  Widget _statsRow(BuildContext context) {
    Widget stat(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(value, style: TextStyle(color: Color(0xFF19C6FF), fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.width * 0.04)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.03)),
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

  Widget _walletCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF001021),
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
        border: Border.all(color: const Color(0xFF19C6FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.045)),
              const Spacer(),
              IconButton(icon: Icon(Icons.add, color: Colors.white54, size: MediaQuery.of(context).size.width * 0.05), onPressed: () {}),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          Row(
            children: const [
              Expanded(
                child: _WalletStat('Available Balance', '\$12.50', Color(0xFF26C281)),
              ),
              Expanded(
                child: _WalletStat('Pending Points', '45 pts', Color(0xFF7A2CF0)),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'Withdraw',
                  colors: const [Color(0xFF26C281), Color(0xFF26C281)],
                  onPressed: () {},
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF19C6FF)),
                  ),
                  child: Text('Redeem', style: TextStyle(color: Color(0xFF19C6FF), fontSize: MediaQuery.of(context).size.width * 0.035)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityItem(BuildContext context, IconData icon, String title, String value, String sub, String time, {required Color color}) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      decoration: BoxDecoration(
        color: const Color(0xFF001021),
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.025),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: MediaQuery.of(context).size.width * 0.04, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: MediaQuery.of(context).size.width * 0.045)),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.035)),
                Text(sub, style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.03)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.035)),
              Text(time, style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.025)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(BuildContext context, String title, IconData icon, {bool danger = false}) {
    return ListTile(
      tileColor: danger ? Colors.transparent : const Color(0xFF001021),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02)),
      title: Text(title, style: TextStyle(color: danger ? const Color(0xFFFF4D4F) : Colors.white, fontSize: MediaQuery.of(context).size.width * 0.04)),
      leading: Icon(icon, color: danger ? const Color(0xFFFF4D4F) : Colors.white54, size: MediaQuery.of(context).size.width * 0.05),
      trailing: danger ? null : Icon(Icons.chevron_right, color: Colors.white54, size: MediaQuery.of(context).size.width * 0.05),
      onTap: () {},
    );
  }
}

class _WalletStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _WalletStat(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.03)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.04)),
      ],
    );
  }
}
