import 'package:mapbox_gl/mapbox_gl.dart';

class BusStop {
  final String name;
  final String time;
  final LatLng coordinates;
  final String? eta;

  BusStop({
    required this.name,
    required this.time,
    required this.coordinates,
    this.eta,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
      'eta': eta,
    };
  }

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      name: json['name'],
      time: json['time'],
      coordinates: LatLng(
        json['coordinates']['latitude'],
        json['coordinates']['longitude'],
      ),
      eta: json['eta'],
    );
  }
}

class BusRoute {
  final String routeId;
  final String routeName;
  final String city;
  final List<BusStop> stops;
  final List<LatLng> routePath;
  final String color;
  final bool isActive;

  BusRoute({
    required this.routeId,
    required this.routeName,
    required this.city,
    required this.stops,
    required this.routePath,
    this.color = '#19C6FF',
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'city': city,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'routePath': routePath.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
      'color': color,
      'isActive': isActive,
    };
  }

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      routeId: json['routeId'],
      routeName: json['routeName'],
      city: json['city'],
      stops: (json['stops'] as List)
          .map((stop) => BusStop.fromJson(stop))
          .toList(),
      routePath: (json['routePath'] as List)
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList(),
      color: json['color'] ?? '#19C6FF',
      isActive: json['isActive'] ?? true,
    );
  }

  BusStop? findStopByName(String name) {
    try {
      return stops.firstWhere(
        (stop) => stop.name.toLowerCase().contains(name.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  List<BusStop> getUpcomingStops(String currentStopName) {
    final currentIndex = stops.indexWhere(
      (stop) => stop.name.toLowerCase() == currentStopName.toLowerCase(),
    );
    
    if (currentIndex == -1 || currentIndex >= stops.length - 1) {
      return [];
    }
    
    return stops.sublist(currentIndex + 1);
  }
}
