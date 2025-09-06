import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../models/bus_route.dart';
import '../models/user_model.dart';
import '../services/bus_route_service.dart';
import '../services/directions_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class TrackVehicleScreen extends StatefulWidget {
  const TrackVehicleScreen({super.key});

  @override
  State<TrackVehicleScreen> createState() => _TrackVehicleScreenState();
}

class _TrackVehicleScreenState extends State<TrackVehicleScreen> {
  final _searchController = TextEditingController();
  MapboxMapController? _mapController;
  Symbol? _userSymbol;
  final LatLng _center = const LatLng(22.3072, 73.1812); // Vadodara center
  final BusRouteService _routeService = BusRouteService();
  BusRoute? _selectedRoute;
  List<Symbol> _stopSymbols = [];
  Line? _routeLine;
  bool _isSearching = false;
  List<BusRoute> _searchResults = [];
  
  // Real-time location sharing
  io.Socket? _socket;
  List<LocationShare> _nearbyBuses = [];
  Map<String, Symbol> _busMarkers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _searchController.addListener(_onSearchChanged);
    _connectToSocket();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  void _connectToSocket() {
    _socket = io.io('http://192.168.1.9:5000', <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
    });
    
    _socket!.connect();
    
    _socket!.on('connect', (_) {
      print('🔌 Track Vehicle: Connected to socket server');
      // Don't join as user, just request nearby buses directly
      _requestNearbyBuses();
    });
    
    _socket!.on('locationUpdate', (data) {
      print('📍 Track Vehicle: Received location update: $data');
      _handleLocationUpdate(data);
    });
    
    _socket!.on('nearbyBusesUpdate', (data) {
      print('🚌 Track Vehicle: Received nearby buses: $data');
      _handleNearbyBuses(data);
    });
  }

  void _requestNearbyBuses() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('getNearbyBuses', {
        'latitude': _center.latitude,
        'longitude': _center.longitude,
      });
      
      // Set up periodic requests for live updates
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_socket != null && _socket!.connected && mounted) {
          _socket!.emit('getNearbyBuses', {
            'latitude': _center.latitude,
            'longitude': _center.longitude,
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _handleLocationUpdate(dynamic data) async {
    if (_mapController == null || !mounted) return;
    
    final locationShare = LocationShare.fromJson(data);
    await _addBusMarker(locationShare);
  }

  void _handleNearbyBuses(dynamic data) {
    if (!mounted) return;
    
    final List<dynamic> busesData = data is List ? data : [];
    final buses = busesData.map((bus) => LocationShare.fromJson(bus)).toList();
    
    setState(() {
      _nearbyBuses = buses;
    });
    
    // Add markers for all nearby buses
    for (final bus in buses) {
      _addBusMarker(bus);
    }
  }

  Future<void> _addBusMarker(LocationShare locationShare) async {
    if (_mapController == null) return;
    
    try {
      // Remove existing marker for this user
      if (_busMarkers.containsKey(locationShare.userId)) {
        await _mapController!.removeSymbol(_busMarkers[locationShare.userId]!);
      }
      
      // Add new marker
      final symbol = await _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(locationShare.latitude, locationShare.longitude),
          iconImage: 'bus-15',
          iconSize: 2.0,
          textField: locationShare.busName,
          textSize: 12,
          textColor: '#FFFFFF',
          textHaloColor: '#000000',
          textHaloWidth: 2.0,
          textOffset: const Offset(0, 2.5),
          textAnchor: 'top',
        ),
      );
      
      _busMarkers[locationShare.userId] = symbol;
      
      // Update nearby buses list
      setState(() {
        _nearbyBuses.removeWhere((bus) => bus.userId == locationShare.userId);
        _nearbyBuses.add(locationShare);
      });
      
    } catch (e) {
      print('❌ Error adding bus marker: $e');
    }
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

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });
    
    // Get routes with real path data
    final allRoutes = await _routeService.getAllRoutes();
    final filteredRoutes = allRoutes.where((route) {
      return route.routeId.toLowerCase().contains(query.toLowerCase()) ||
          route.routeName.toLowerCase().contains(query.toLowerCase()) ||
          route.stops.any((stop) => stop.name.toLowerCase().contains(query.toLowerCase()));
    }).toList();
    
    setState(() {
      _searchResults = filteredRoutes;
    });
  }

  Future<void> _selectRoute(BusRoute route) async {
    setState(() {
      _selectedRoute = route;
      _isSearching = false;
      _searchController.text = route.routeId;
    });

    await _displayRouteOnMap(route);
  }

  Future<void> _displayRouteOnMap(BusRoute route) async {
    if (_mapController == null) return;

    // Clear existing route visualization
    await _clearRouteVisualization();

    // Get real route path if empty
    List<LatLng> routePath = route.routePath;
    if (routePath.isEmpty && route.stops.length >= 2) {
      final waypoints = route.stops.map((stop) => stop.coordinates).toList();
      routePath = await DirectionsService.getRoute(waypoints);
    }

    // Add route line with real path
    if (routePath.isNotEmpty) {
      _routeLine = await _mapController!.addLine(
        LineOptions(
          geometry: routePath,
          lineColor: route.color,
          lineWidth: 4.0,
          lineOpacity: 0.8,
        ),
      );
    }

    // Add stop markers
    for (int i = 0; i < route.stops.length; i++) {
      final stop = route.stops[i];
      final symbol = await _mapController!.addSymbol(
        SymbolOptions(
          geometry: stop.coordinates,
          iconImage: 'marker-15',
          iconSize: 0.8,
          textField: '${i + 1}',
          textSize: 12,
          textColor: '#FFFFFF',
          textOffset: const Offset(0, -2),
        ),
      );
      _stopSymbols.add(symbol);
    }

    // Fit camera to route bounds
    final pathForBounds = routePath.isNotEmpty ? routePath : route.stops.map((s) => s.coordinates).toList();
    if (pathForBounds.isNotEmpty) {
      final bounds = _calculateRouteBounds(pathForBounds);
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, left: 50, top: 50, right: 50, bottom: 50),
      );
    }
  }

  LatLngBounds _calculateRouteBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _clearRouteVisualization() async {
    if (_mapController == null) return;

    // Remove route line
    if (_routeLine != null) {
      await _mapController!.removeLine(_routeLine!);
      _routeLine = null;
    }

    // Remove stop symbols
    for (final symbol in _stopSymbols) {
      await _mapController!.removeSymbol(symbol);
    }
    _stopSymbols.clear();
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
            if (_isSearching) _buildSearchResults(),
            const SizedBox(height: 16),
            _buildMapPlaceholder(),
            const SizedBox(height: 8),
            Text(
              _selectedRoute != null 
                ? 'Showing Route ${_selectedRoute!.routeId}' 
                : 'Search for a bus route (3C or 3D)',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (_selectedRoute != null) _buildBusInfoCard(),
            if (_selectedRoute != null) const SizedBox(height: 16),
            if (_selectedRoute != null) Row(
              children: [
                Expanded(child: _smallAction('Share ETA', Icons.share, () {})),
                const SizedBox(width: 12),
                Expanded(child: _smallAction('Set Reminder', Icons.schedule, () {})),
              ],
            ),
            const SizedBox(height: 16),
            _buildNearbyBusesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF101426),
        border: Border.all(color: const Color(0xFF19C6FF).withOpacity(0.3)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final route = _searchResults[index];
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(int.parse(route.color.replaceFirst('#', '0xFF'))),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  route.routeId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(
              route.routeName,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            subtitle: Text(
              '${route.stops.length} stops • ${route.city}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            onTap: () => _selectRoute(route),
          );
        },
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
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          hintText: 'Enter Bus ID or Route Number (3C, 3D)',
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedRoute = null;
                      _isSearching = false;
                      _searchResults = [];
                    });
                    _clearRouteVisualization();
                  },
                )
              : null,
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
            children: [
              Expanded(
                child: Text(
                  'Bus ${_selectedRoute?.routeId ?? 'BUS-2834'}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              Text('3 min', style: TextStyle(color: Color(0xFF19C6FF), fontWeight: FontWeight.w600)),
              SizedBox(width: 4),
              Text('ETA', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _selectedRoute?.routeName ?? 'Route 42 • Airport Express',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
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

  Widget _buildNearbyBusesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_bus, color: Color(0xFF19C6FF), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Live Buses Nearby',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF19C6FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_nearbyBuses.length}',
                style: const TextStyle(color: Color(0xFF19C6FF), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_nearbyBuses.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF101426),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF19C6FF).withOpacity(0.3)),
            ),
            child: const Center(
              child: Text(
                'No buses sharing location nearby',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nearbyBuses.length,
            itemBuilder: (context, index) {
              final bus = _nearbyBuses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF101426),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getBusColor(bus.busType).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getBusColor(bus.busType).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.directions_bus,
                        color: _getBusColor(bus.busType),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bus.busName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${bus.userName} • ${bus.speed.toStringAsFixed(1)} km/h',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getBusColor(bus.busType).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bus.busType.toUpperCase(),
                        style: TextStyle(
                          color: _getBusColor(bus.busType),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Color _getBusColor(String busType) {
    switch (busType) {
      case 'express':
        return const Color(0xFFFF6B35); // Orange for express
      case 'local':
        return const Color(0xFF19C6FF); // Blue for local
      case 'school':
        return const Color(0xFFFFD700); // Gold for school
      default:
        return const Color(0xFF26C281); // Green for regular
    }
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
