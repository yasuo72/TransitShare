import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_state_service.dart';
import '../models/user_model.dart';
import '../widgets/gradient_button.dart';

class LocationSharingScreen extends StatefulWidget {
  const LocationSharingScreen({super.key});

  @override
  State<LocationSharingScreen> createState() => _LocationSharingScreenState();
}

class _LocationSharingScreenState extends State<LocationSharingScreen> {
  final _busNameController = TextEditingController();
  MapboxMapController? _mapController;
  bool _isSharing = false;
  List<LocationShare> _nearbyUsers = [];
  List<Symbol> _userMarkers = [];
  User? _currentUser;
  bool _isConnected = false;
  int _onlineUsersCount = 0;
  Timer? _connectionTimer;
  Line? _routeLine;
  Map<String, dynamic>? _locationHistory;
  bool _showRouteTrail = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initializeLocationService();
    _setupNotifications();
    _saveNavigationState();
    _restoreLocationSharingState();
  }

  void _saveNavigationState() {
    // Save that user is on location sharing screen
    NavigationStateService.saveLastScreen('/location_sharing');
    NavigationStateService.updateLastActiveTime();
  }

  Future<void> _restoreLocationSharingState() async {
    // Restore location sharing state if user was sharing before
    final locationState = await NavigationStateService.getLocationSharingState();
    if (locationState != null && locationState['isSharing'] == true) {
      setState(() {
        _busNameController.text = locationState['busName'] ?? '';
        _isSharing = locationState['isSharing'] ?? false;
      });
      
      // Show restoration message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restored previous location sharing session'),
            backgroundColor: Color(0xFF26C281),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _busNameController.dispose();
    _connectionTimer?.cancel();
    LocationService.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    _currentUser = await AuthService.getStoredUser();
    setState(() {});
  }

  Future<void> _initializeLocationService() async {
    await LocationService.initSocket();
    
    // Listen for location updates from other users
    LocationService.listenForLocationUpdates((locationShare) {
      _addUserMarker(locationShare);
    });

    // Listen for nearby buses updates
    LocationService.listenForNearbyBuses((buses) {
      _updateNearbyBusList(buses);
    });

    // Listen for location history updates
    LocationService.listenForLocationHistory((history) {
      setState(() {
        _locationHistory = history;
      });
    });

    // Listen for route visualization updates
    LocationService.listenForRouteVisualization((route) {
      _drawRouteOnMap(route);
    });

    // Request nearby buses periodically
    _requestNearbyBusesTimer();
  }

  void _setupNotifications() {
    LocationService.setOnBusApproachingCallback((data) {
      if (mounted) {
        _showBusApproachingNotification(data);
      }
    });

    // Monitor connection status
    _connectionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _isConnected = LocationService.isConnected();
          _onlineUsersCount = _nearbyUsers.length;
        });
      }
    });
  }

  void _showBusApproachingNotification(Map<String, dynamic> data) {
    final busName = data['busName'];
    final distance = data['distance'];
    final eta = data['eta'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF26C281),
        content: Row(
          children: [
            const Icon(Icons.directions_bus, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🚌 $busName approaching! ${distance.toStringAsFixed(1)}km away ${eta != null ? "• ETA: ${eta}min" : ""}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Center map on approaching bus
          },
        ),
      ),
    );
  }

  void _updateNearbyBusList(List<Map<String, dynamic>> buses) {
    setState(() {
      _nearbyUsers = buses.map((bus) {
        return LocationShare(
          userId: bus['userId'],
          latitude: bus['latitude'],
          longitude: bus['longitude'],
          busName: bus['busName'],
          timestamp: DateTime.parse(bus['timestamp']),
          busType: bus['busType'] ?? 'regular',
          speed: (bus['speed'] ?? 0.0).toDouble(),
          userName: bus['userName'],
        );
      }).toList();
    });
  }

  void _requestNearbyBusesTimer() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        LocationService.requestNearbyBuses(position.latitude, position.longitude);
      }
    });
  }

  Future<void> _toggleLocationSharing() async {
    if (!_isSharing) {
      if (_busNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter bus name')),
        );
        return;
      }

      final success = await LocationService.startLocationSharing(
        _busNameController.text.trim(),
      );

      if (success) {
        setState(() {
          _isSharing = true;
        });
        
        // Save location sharing state
        await NavigationStateService.saveLocationSharingState(
          isSharing: true,
          busName: _busNameController.text.trim(),
          busType: 'regular',
        );
        
        // Start requesting location history updates
        if (_currentUser != null) {
          Timer.periodic(const Duration(seconds: 15), (timer) {
            if (!mounted || !_isSharing) {
              timer.cancel();
              return;
            }
            LocationService.requestLocationHistory(_currentUser!.id);
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Started sharing location')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start location sharing')),
        );
      }
    } else {
      await LocationService.stopLocationSharing();
      
      // Clear route visualization
      if (_routeLine != null && _mapController != null) {
        await _mapController!.removeLine(_routeLine!);
        _routeLine = null;
      }
      
      // Clear location sharing state
      await NavigationStateService.saveLocationSharingState(
        isSharing: false,
        busName: null,
        busType: null,
      );
      
      setState(() {
        _isSharing = false;
        _showRouteTrail = false;
        _locationHistory = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stopped sharing location')),
      );
    }
  }

  Future<void> _addUserMarker(LocationShare locationShare) async {
    if (_mapController == null) return;

    // Remove existing marker for this user
    _userMarkers.removeWhere((marker) {
      _mapController!.removeSymbol(marker);
      return true;
    });

    // Get appropriate bus icon based on bus type
    String iconImage = _getBusIcon(locationShare.busType);
    
    // Add new marker with custom bus icon
    final symbol = await _mapController!.addSymbol(
      SymbolOptions(
        geometry: LatLng(locationShare.latitude, locationShare.longitude),
        iconImage: iconImage,
        iconSize: 1.5,
        textField: '${locationShare.busName}\n${locationShare.speed.toInt()} km/h',
        textSize: 11,
        textColor: '#FFFFFF',
        textHaloColor: '#000000',
        textHaloWidth: 1.0,
        textOffset: const Offset(0, -3),
        textAnchor: 'top',
      ),
    );

    _userMarkers.add(symbol);
    
    setState(() {
      _nearbyUsers.removeWhere((user) => user.userId == locationShare.userId);
      _nearbyUsers.add(locationShare);
    });
  }

  String _getBusIcon(String busType) {
    switch (busType) {
      case 'express':
        return 'bus-15'; // Express bus icon
      case 'local':
        return 'bus-15'; // Local bus icon
      case 'school':
        return 'school-15'; // School bus icon
      default:
        return 'bus-15'; // Regular bus icon
    }
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
        title: Row(
          children: [
            const Text('Live Location Sharing', style: TextStyle(color: Colors.white)),
            const Spacer(),
            _buildConnectionStatus(),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_currentUser != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101426),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF19C6FF).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF19C6FF),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser!.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${_currentUser!.points} points',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Bus Name Input
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF101426),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF19C6FF).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _busNameController,
                    style: const TextStyle(color: Colors.white),
                    enabled: !_isSharing,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.directions_bus, color: Colors.white54),
                      hintText: 'Enter Bus Name/Number (e.g., 3C, BUS-101)',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Share Button
                GradientButton(
                  text: _isSharing ? 'Stop Sharing Location' : 'Start Sharing Location',
                  colors: _isSharing 
                    ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A52)]
                    : [const Color(0xFF19C6FF), const Color(0xFF1E88E5)],
                  onPressed: _toggleLocationSharing,
                ),
                
                if (_isSharing) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF26C281).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF26C281)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF26C281), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sharing location for ${LocationService.currentBusName}',
                                style: const TextStyle(color: Color(0xFF26C281), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (_locationHistory != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Distance', '${_locationHistory!['totalDistance']?.toStringAsFixed(1) ?? '0'} km'),
                              _buildStatItem('Duration', '${(_locationHistory!['duration'] ?? 0).toInt()} min'),
                              _buildStatItem('Avg Speed', '${_locationHistory!['averageSpeed']?.toStringAsFixed(1) ?? '0'} km/h'),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _toggleRouteVisualization,
                                icon: Icon(_showRouteTrail ? Icons.visibility_off : Icons.route),
                                label: Text(_showRouteTrail ? 'Hide Route' : 'Show Route'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF19C6FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF19C6FF).withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MapboxMap(
                  styleString: MapboxStyles.DARK,
                  myLocationEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _centerOnCurrentLocation();
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(22.3072, 73.1812), // Vadodara center
                    zoom: 12,
                  ),
                ),
              ),
            ),
          ),
          
          // Nearby Users List
          if (_nearbyUsers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nearby Users',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _nearbyUsers.length,
                      itemBuilder: (context, index) {
                        final user = _nearbyUsers[index];
                        final busColor = _getBusColor(user.busType);
                        final distance = _calculateDistance(user.latitude, user.longitude);
                        
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101426),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: busColor.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: busColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_bus, color: busColor, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                user.busName,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${user.speed.toInt()} km/h',
                                style: TextStyle(color: busColor, fontSize: 10, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${distance.toStringAsFixed(1)} km',
                                style: const TextStyle(color: Colors.white54, fontSize: 9),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _centerOnCurrentLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14,
        ),
      );
    }
  }

  double _calculateDistance(double lat, double lng) {
    // Simple distance calculation - in a real app, use Geolocator.distanceBetween
    // For now, return a mock distance based on coordinates difference
    const double vadodaraLat = 22.3072;
    const double vadodaraLng = 73.1812;
    
    double deltaLat = (lat - vadodaraLat).abs();
    double deltaLng = (lng - vadodaraLng).abs();
    
    // Rough conversion to kilometers (1 degree ≈ 111 km)
    return ((deltaLat + deltaLng) * 111).clamp(0.1, 50.0);
  }

  Future<void> _drawRouteOnMap(Map<String, dynamic> routeData) async {
    if (_mapController == null || routeData['route'] == null) return;

    // Remove existing route line
    if (_routeLine != null) {
      await _mapController!.removeLine(_routeLine!);
    }

    final List<dynamic> routePoints = routeData['route'];
    if (routePoints.length < 2) return;

    // Convert route points to LatLng
    final List<LatLng> coordinates = routePoints.map((point) {
      return LatLng(point['latitude'], point['longitude']);
    }).toList();

    // Add route line to map
    _routeLine = await _mapController!.addLine(
      LineOptions(
        geometry: coordinates,
        lineColor: '#${_getBusColor(routeData['busType'] ?? 'regular').value.toRadixString(16).substring(2)}',
        lineWidth: 4.0,
        lineOpacity: 0.8,
      ),
    );

    setState(() {
      _showRouteTrail = true;
    });
  }

  void _toggleRouteVisualization() {
    if (_currentUser != null) {
      if (_showRouteTrail) {
        // Hide route
        if (_routeLine != null && _mapController != null) {
          _mapController!.removeLine(_routeLine!);
          _routeLine = null;
        }
        setState(() {
          _showRouteTrail = false;
        });
      } else {
        // Show route
        LocationService.requestRouteVisualization(_currentUser!.id);
      }
    }
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isConnected ? const Color(0xFF26C281) : const Color(0xFFFF6B6B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isConnected ? Icons.wifi : Icons.wifi_off,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            _isConnected ? '$_onlineUsersCount online' : 'Offline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF26C281),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
