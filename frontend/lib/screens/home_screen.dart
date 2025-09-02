import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/fab_button.dart';
import '../widgets/auto_hide_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MapboxMapController? _mapController;
  Symbol? _userSymbol;
  final LatLng _center = const LatLng(28.6139, 77.2090); // Centered on Delhi
  io.Socket? socket;
  final Map<String, Symbol> _symbols = {};
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        _goToCurrentUserLocation();
        _connectToSocket();
      }
    } else if (status.isGranted) {
      _goToCurrentUserLocation();
      _connectToSocket();
    }
  }

  void _goToCurrentUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (_mapController != null) {
        final userLatLng = LatLng(position.latitude, position.longitude);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(userLatLng, 14.0),
        );
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
    } catch (e) {
      debugPrint('Error getting location: $e');
      // Handle location service errors, e.g., disabled location
    }
  }

  void _connectToSocket() {
    // TODO: Replace YOUR_COMPUTER_IP with your actual local IP address
    socket = io.io('http://192.168.28.224:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();

    socket!.on('connect', (_) => debugPrint('connected to socket server'));

    socket!.on('locationUpdate', (data) {
      _updateMarker(data);
    });
  }

  void _updateMarker(dynamic data) async {
    if (_mapController == null || !mounted) return;

    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < const Duration(seconds: 2)) {
      return;
    }
    _lastUpdateTime = now;

    final busId = data['busId'];
    final lat = data['lat'];
    final lng = data['lng'];
    final newPosition = LatLng(lat, lng);

    if (_symbols.containsKey(busId)) {
      final symbol = _symbols[busId]!;
      await _mapController!.updateSymbol(
        symbol,
        SymbolOptions(geometry: newPosition),
      );
    } else {
      final newSymbol = await _mapController!.addSymbol(
        SymbolOptions(
          geometry: newPosition,
          iconImage: 'bus-15', // Standard Maki icon for a bus
          textField: 'Bus $busId',
          textOffset: const Offset(0, 2.0),
          textColor: '#FFFFFF',
          textSize: 12,
        ),
      );
      if (mounted) {
        setState(() {
          _symbols[busId] = newSymbol;
        });
      }
    }
    _mapController!.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  @override
  void dispose() {
    socket?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000817),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: AutoHideBottomNav.show,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildMap(context),
              const SizedBox(height: 12),
              _buildNearbyListTitle(),
              Expanded(child: _buildNearbyList()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFabs(),
      bottomNavigationBar: AutoHideBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.pushReplacementNamed(context, '/rewards');
          } else if (i == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF001021),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF19C6FF),
            child: Text('AC', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rohit ',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                      )),
              Text('250 points',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                  )),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white70),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search,
              color: Colors.white54,
              size: MediaQuery.of(context).size.width * 0.05),
          hintText: 'Enter Bus ID or Route Number',
          hintStyle: TextStyle(
              color: Colors.white54,
              fontSize: MediaQuery.of(context).size.width * 0.04),
          filled: true,
          fillColor: const Color(0xFF001021),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: const Color(0xFF19C6FF).withAlpha(51),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF19C6FF)),
          ),
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: Stack(
            children: [
              MapboxMap(
                styleString: MapboxStyles.DARK,
                myLocationEnabled: false,
                onMapCreated: (MapboxMapController controller) {
                  _mapController = controller;
                  _goToCurrentUserLocation();
                },
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        _mapController?.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        _mapController?.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
                      },
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'fullscreenHome',
                  mini: true,
                  onPressed: () {
                    Navigator.pushNamed(context, '/map_full');
                  },
                  child: const Icon(Icons.fullscreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyListTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('Nearby Buses',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.width * 0.05)),
      ),
    );
  }

  Widget _buildNearbyList() {
    final dummy = [
      {
        'route': 'Route 42',
        'status': 'Available',
        'eta': '3 min',
        'distance': '0.8 km',
        'busId': 'BUS-2834'
      },
      {
        'route': 'Route 15',
        'status': 'Full',
        'eta': '7 min',
        'distance': '1.2 km',
        'busId': 'BUS-1923'
      },
    ];
    return ListView.separated(
      itemCount: dummy.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final item = dummy[idx];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF001021),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item['route']!,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04)),
                        const SizedBox(width: 6),
                        _buildStatusChip(item['status']!),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Bus ID: ${item['busId']}',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.03)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item['eta']!,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.04)),
                  const SizedBox(height: 4),
                  Text(item['distance']!,
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: MediaQuery.of(context).size.width * 0.03)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    if (status == 'Available') {
      bg = const Color(0xFF26C281);
    } else if (status == 'Full') {
      bg = const Color(0xFFFFB300);
    } else {
      bg = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02,
          vertical: MediaQuery.of(context).size.width * 0.005),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status,
          style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.025)),
    );
  }

  Widget _buildFabs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FabButton(
          icon: Icons.search,
          colors: const [Color(0xFF19C6FF), Color(0xFF00B4FF)],
          onPressed: () {
            Navigator.pushNamed(context, '/track');
          },
        ),
        const SizedBox(height: 16),
        FabButton(
          icon: Icons.directions_bus,
          colors: const [Color(0xFF7A2CF0), Color(0xFF9B3BFF)],
          onPressed: () {
            Navigator.pushNamed(context, '/share');
          },
        ),
      ],
    );
  }
}
