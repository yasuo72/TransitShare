import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';

class ShareRideScreen extends StatefulWidget {
  const ShareRideScreen({super.key});

  @override
  State<ShareRideScreen> createState() => _ShareRideScreenState();
}

class _ShareRideScreenState extends State<ShareRideScreen> {
  final _busController = TextEditingController();
  String? _selectedRoute;
  bool _allowTips = true;

  final _dummyRoutes = ['Route 42', 'Route 15', 'Route 7A'];

  @override
  void dispose() {
    _busController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000817),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF19C6FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Share Your Ride', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(colors: [Color(0xFF7A2CF0), Color(0xFF19C6FF)]),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF19C6FF).withOpacity(0.7), blurRadius: 30, spreadRadius: 4),
                ],
              ),
              child: const Icon(Icons.directions_bus, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Start sharing your location to help passengers track your bus',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            _buildLabeled('Bus ID'),
            _buildInputField(_busController, 'Enter Bus ID (e.g., BUS-2834)', icon: Icons.directions_bus),
            const SizedBox(height: 16),
            _buildLabeled('Route Number'),
            _buildRouteDropdown(),
            const SizedBox(height: 24),
            _buildTipsToggle(),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Start Sharing',
              onPressed: () {
                // TODO: call backend and start streaming GPS.
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeled(String label) => Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      );

  Widget _buildInputField(TextEditingController controller, String hint, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF101426),
        boxShadow: [
          BoxShadow(color: const Color(0xFF19C6FF).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildRouteDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF101426),
        boxShadow: [
          BoxShadow(color: const Color(0xFF19C6FF).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF001021),
          value: _selectedRoute,
          iconEnabledColor: Colors.white54,
          hint: const Text('Select Route', style: TextStyle(color: Colors.white54)),
          items: _dummyRoutes
              .map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r, style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedRoute = v),
        ),
      ),
    );
  }

  Widget _buildTipsToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101426),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Allow Tips & Rewards', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Let passengers send you appreciation points', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _allowTips,
            activeColor: const Color(0xFF7A2CF0),
            onChanged: (v) => setState(() => _allowTips = v),
          ),
        ],
      ),
    );
  }
}
