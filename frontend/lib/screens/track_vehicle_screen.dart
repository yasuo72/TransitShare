import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class TrackVehicleScreen extends StatefulWidget {
  const TrackVehicleScreen({super.key});

  @override
  State<TrackVehicleScreen> createState() => _TrackVehicleScreenState();
}

class _TrackVehicleScreenState extends State<TrackVehicleScreen> {
  final _searchController = TextEditingController();
  MapboxMapController? _mapController;
  Symbol? _userSymbol;
  final LatLng _center = const LatLng(28.6139, 77.2090);

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      _goToCurrentUserLocation();
    }
  }

  Future<void> _goToCurrentUserLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final userLatLng = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 14),
      );
      if (_mapController != null) {
        if (_userSymbol == null) {
          _userSymbol = await _mapController!.addSymbol(
            SymbolOptions(
              geometry: userLatLng,
              iconImage: 'marker-15',
              iconSize: 1.5,
            ),
          );
        } else {
          await _mapController!.updateSymbol(_userSymbol!, SymbolOptions(geometry: userLatLng));
        }
      }
    } catch (_) {}
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
        title: const Text('Track Vehicle', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildMapPlaceholder(),
            const SizedBox(height: 8),
            const Text('Tracking Bus BUS-2834', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 16),
            _buildBusInfoCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _smallAction('Share ETA', Icons.share, () {})),
                const SizedBox(width: 12),
                Expanded(child: _smallAction('Set Reminder', Icons.schedule, () {})),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF101426),
        boxShadow: [
          BoxShadow(color: const Color(0xFF19C6FF).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.white54),
          hintText: 'Enter Bus ID or Route Number',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        children: [
          MapboxMap(
            styleString: MapboxStyles.DARK,
            myLocationEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _goToCurrentUserLocation();
            },
            initialCameraPosition: CameraPosition(target: _center, zoom: 11),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'trackZoomIn',
                  mini: true,
                  onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'trackZoomOut',
                  mini: true,
                  onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusInfoCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF001021),
        border: Border.all(color: const Color(0xFF19C6FF), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text('Bus BUS-2834', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              Text('3 min', style: TextStyle(color: Color(0xFF19C6FF), fontWeight: FontWeight.w600)),
              SizedBox(width: 4),
              Text('ETA', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 2),
          const Text('Route 42 • Airport Express', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip('0.8 km', 'Distance'),
              const SizedBox(width: 12),
              _infoChip('Available', 'Status', bg: const Color(0xFF26C281)),
            ],
          ),
          const SizedBox(height: 12),
          GradientButton(
            text: 'Thank Driver',
            colors: const [Color(0xFFBB5AF8), Color(0xFF7A2CF0)],
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String value, String label, {Color bg = const Color(0xFF19C6FF)}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: bg, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _smallAction(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF101426),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF19C6FF), size: 20),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
