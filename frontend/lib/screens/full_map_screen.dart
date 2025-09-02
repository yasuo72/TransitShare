import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  MapboxMapController? _mapController;
  Symbol? _userSymbol;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (await Permission.location.request().isGranted) {
      _goToUser();
    }
  }

  Future<void> _goToUser() async {
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

  Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
    return FloatingActionButton(
      mini: true,
      heroTag: icon.toString(),
      onPressed: onTap,
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MapboxMap(
            styleString: MapboxStyles.DARK,
            myLocationEnabled: false,
            onMapCreated: (c) {
              _mapController = c;
              _goToUser();
            },
            initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 2),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: Column(
              children: [
                _buildZoomButton(Icons.zoom_in, () => _mapController?.animateCamera(CameraUpdate.zoomIn())),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.zoom_out, () => _mapController?.animateCamera(CameraUpdate.zoomOut())),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'back',
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }
}
