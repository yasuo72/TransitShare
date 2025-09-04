import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/user_model.dart';
import 'auth_service.dart';

class LocationService {
  static IO.Socket? _socket;
  static StreamSubscription<Position>? _positionStream;
  static String? _currentBusName;
  static User? _currentUser;
  static String? _currentUserId;
  static double? _currentSpeed;
  
  // Initialize socket connection
  static Future<void> initSocket() async {
    _socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    
    _socket!.connect();
    
    _socket!.onConnect((_) {
      print('Connected to server');
      _joinUser();
    });
    
    _socket!.onDisconnect((_) {
      print('Disconnected from server');
    });

    // Listen for user online/offline events
    _socket!.on('userOnline', (data) {
      print('User ${data['userName']} came online');
    });

    _socket!.on('userOffline', (data) {
      print('User ${data['userName']} went offline');
    });

    // Listen for bus approaching notifications
    _socket!.on('busApproaching', (data) {
      _onBusApproaching?.call(data);
    });
  }

  static Function(Map<String, dynamic>)? _onBusApproaching;

  static void setOnBusApproachingCallback(Function(Map<String, dynamic>) callback) {
    _onBusApproaching = callback;
  }

  static void _joinUser() async {
    if (_currentUser != null && _socket != null) {
      _socket!.emit('userJoin', {
        'userId': _currentUser!.id,
        'userName': _currentUser!.name,
      });
    }
  }

  // Start sharing location
  static Future<bool> startLocationSharing(String busName) async {
    _currentBusName = busName;
    
    // Get current user
    _currentUser = await AuthService.getStoredUser();
    if (_currentUser == null) {
      return false;
    }
    _currentUserId = _currentUser!.id;

    _currentBusName = busName;

    // Initialize socket if not connected
    if (_socket == null) {
      await initSocket();
    }

    // Start location stream
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _currentSpeed = position.speed;
      shareLocation(position.latitude, position.longitude, busName);
    });

    return true;
  }

  // Stop sharing location
  static Future<void> stopLocationSharing() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _currentBusName = null;
  }

  // Share location via socket
  static void shareLocation(double latitude, double longitude, String busName) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('shareLocation', {
        'userId': _currentUserId,
        'latitude': latitude,
        'longitude': longitude,
        'busName': busName,
        'timestamp': DateTime.now().toIso8601String(),
        'busType': _getBusType(busName),
        'speed': _currentSpeed ?? 0.0,
      });
    }
  }

  static String _getBusType(String busName) {
    final name = busName.toLowerCase();
    if (name.contains('express') || name.contains('ac')) {
      return 'express';
    } else if (name.contains('local') || name.contains('city')) {
      return 'local';
    } else if (name.contains('school')) {
      return 'school';
    }
    return 'regular';
  }

  // Listen for location updates from other users
  static void listenForLocationUpdates(Function(LocationShare) onLocationUpdate) {
    _socket?.on('locationUpdate', (data) {
      try {
        final locationShare = LocationShare.fromJson(data);
        onLocationUpdate(locationShare);
      } catch (e) {
        print('Error parsing location update: $e');
      }
    });
  }

  // Request nearby buses
  static void requestNearbyBuses(double latitude, double longitude) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('getNearbyBuses', {
        'latitude': latitude,
        'longitude': longitude,
      });
    }
  }

  // Listen for nearby buses updates
  static void listenForNearbyBuses(Function(List<Map<String, dynamic>>) onNearbyBuses) {
    _socket?.on('nearbyBusesUpdate', (data) {
      try {
        final List<Map<String, dynamic>> buses = List<Map<String, dynamic>>.from(data);
        onNearbyBuses(buses);
      } catch (e) {
        print('Error parsing nearby buses: $e');
      }
    });
  }

  // Request location history
  static void requestLocationHistory(String userId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('getLocationHistory', {'userId': userId});
    }
  }

  // Listen for location history updates
  static void listenForLocationHistory(Function(Map<String, dynamic>) onLocationHistory) {
    _socket?.on('locationHistoryUpdate', (data) {
      try {
        onLocationHistory(Map<String, dynamic>.from(data));
      } catch (e) {
        print('Error parsing location history: $e');
      }
    });
  }

  // Request route visualization
  static void requestRouteVisualization(String userId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('getRouteVisualization', {'userId': userId});
    }
  }

  // Listen for route visualization updates
  static void listenForRouteVisualization(Function(Map<String, dynamic>) onRouteVisualization) {
    _socket?.on('routeVisualizationUpdate', (data) {
      try {
        onRouteVisualization(Map<String, dynamic>.from(data));
      } catch (e) {
        print('Error parsing route visualization: $e');
      }
    });
  }

  // Get current location once
  static Future<Position?> getCurrentLocation() async {
    try {
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Check if location sharing is active
  static bool get isSharing => _positionStream != null;
  
  // Get current bus name
  static String? get currentBusName => _currentBusName;

  // Check if socket is connected
  static bool isConnected() {
    return _socket?.connected ?? false;
  }

  // Dispose resources
  static void dispose() {
    _positionStream?.cancel();
    _socket?.dispose();
    _socket = null;
  }
}
