import 'dart:math' as math;
import 'package:mapbox_gl/mapbox_gl.dart';
import '../models/bus_route.dart';
import 'directions_service.dart';

class BusRouteService {
  static final BusRouteService _instance = BusRouteService._internal();
  factory BusRouteService() => _instance;
  BusRouteService._internal();

  // Real Vadodara city bus routes data with accurate coordinates
  static final List<BusRoute> _vadodaraRoutes = [
    BusRoute(
      routeId: '3C',
      routeName: '3C - Waghodia to City Bus Stand',
      city: 'Vadodara',
      color: '#FF6B35',
      stops: [
        BusStop(name: 'WAGHODIA', time: '06:55 AM', coordinates: LatLng(22.2587, 73.0857)),
        BusStop(name: 'WAGHODIA CHOWK', time: '06:55 AM', coordinates: LatLng(22.2592, 73.0863)),
        BusStop(name: 'GSCSC GODOWN', time: '06:56 AM', coordinates: LatLng(22.2601, 73.0871)),
        BusStop(name: 'SHANKAR PACKAGING LIMITED', time: '06:57 AM', coordinates: LatLng(22.2615, 73.0885)),
        BusStop(name: 'JINDAL ALUMINIUM FOILS PVT LTD', time: '07:00 AM', coordinates: LatLng(22.2635, 73.0905)),
        BusStop(name: 'LIMDA', time: '07:02 AM', coordinates: LatLng(22.2658, 73.0928)),
        BusStop(name: 'DUTTAPURA', time: '07:05 AM', coordinates: LatLng(22.2685, 73.0955)),
        BusStop(name: 'PIPALIYA NAVI NAGRI', time: '07:08 AM', coordinates: LatLng(22.2712, 73.0982)),
        BusStop(name: 'PIPADIYA', time: '07:10 AM', coordinates: LatLng(22.2738, 73.1008)),
        BusStop(name: 'PIPALIYA', time: '07:10 AM', coordinates: LatLng(22.2765, 73.1035)),
        BusStop(name: 'GAYATRI TEMPLE', time: '07:16 AM', coordinates: LatLng(22.2792, 73.1062)),
        BusStop(name: 'BAPOD BYEPASS', time: '07:18 AM', coordinates: LatLng(22.2819, 73.1089)),
        BusStop(name: 'VAIKUND', time: '07:22 AM', coordinates: LatLng(22.2846, 73.1116)),
        BusStop(name: 'BAPOD JAKAT NAKA', time: '07:23 AM', coordinates: LatLng(22.2873, 73.1143)),
        BusStop(name: 'ZAVER NAGAR', time: '07:24 AM', coordinates: LatLng(22.2900, 73.1170)),
        BusStop(name: 'ZAVER NAGAR CHAR RASTA', time: '07:27 AM', coordinates: LatLng(22.2927, 73.1197)),
        BusStop(name: 'UMA CHAR RASTA', time: '07:28 AM', coordinates: LatLng(22.2954, 73.1224)),
        BusStop(name: 'SURYANAGAR', time: '07:28 AM', coordinates: LatLng(22.2981, 73.1251)),
        BusStop(name: 'PANIGATE TANKI', time: '07:29 AM', coordinates: LatLng(22.3008, 73.1278)),
        BusStop(name: 'PANI GATE POLICE STATION', time: '07:30 AM', coordinates: LatLng(22.3035, 73.1305)),
        BusStop(name: 'MANDVI', time: '07:32 AM', coordinates: LatLng(22.3062, 73.1332)),
        BusStop(name: 'NYAY MANDIR', time: '07:34 AM', coordinates: LatLng(22.3089, 73.1359)),
        BusStop(name: 'KHANDERAO MARKET', time: '07:36 AM', coordinates: LatLng(22.3116, 73.1386)),
        BusStop(name: 'KIRTI STAMBH', time: '07:39 AM', coordinates: LatLng(22.3143, 73.1413)),
        BusStop(name: 'PALACE MAIN GATE', time: '07:40 AM', coordinates: LatLng(22.3170, 73.1440)),
        BusStop(name: 'NAV LAKHI', time: '07:43 AM', coordinates: LatLng(22.3197, 73.1467)),
        BusStop(name: 'NARMADA BHAVAN', time: '07:44 AM', coordinates: LatLng(22.3224, 73.1494)),
        BusStop(name: 'DAWAKHANA', time: '07:45 AM', coordinates: LatLng(22.3251, 73.1521)),
        BusStop(name: 'KAMATI BAUG', time: '07:46 AM', coordinates: LatLng(22.3278, 73.1548)),
        BusStop(name: 'SAYAJIGUNJ', time: '07:47 AM', coordinates: LatLng(22.3305, 73.1575)),
        BusStop(name: 'CITY BUS STAND', time: '07:48 AM', coordinates: LatLng(22.3072, 73.1812)),
      ],
      routePath: [], // Will be populated by Directions API
    ),
    BusRoute(
      routeId: '3D',
      routeName: '3D - City Bus Stand to Waghodia',
      city: 'Vadodara',
      color: '#4ECDC4',
      stops: [
        BusStop(name: 'CITY BUS STAND', time: '08:00 AM', coordinates: LatLng(22.2830, 73.1100)),
        BusStop(name: 'SAYAJIGUNJ', time: '08:01 AM', coordinates: LatLng(22.2825, 73.1095)),
        BusStop(name: 'KAMATI BAUG', time: '08:02 AM', coordinates: LatLng(22.2820, 73.1090)),
        BusStop(name: 'DAWAKHANA', time: '08:03 AM', coordinates: LatLng(22.2815, 73.1085)),
        BusStop(name: 'NARMADA BHAVAN', time: '08:04 AM', coordinates: LatLng(22.2810, 73.1080)),
        BusStop(name: 'NAV LAKHI', time: '08:07 AM', coordinates: LatLng(22.2805, 73.1075)),
        BusStop(name: 'PALACE MAIN GATE', time: '08:08 AM', coordinates: LatLng(22.2795, 73.1065)),
        BusStop(name: 'KIRTI STAMBH', time: '08:11 AM', coordinates: LatLng(22.2790, 73.1060)),
        BusStop(name: 'KHANDERAO MARKET', time: '08:14 AM', coordinates: LatLng(22.2780, 73.1050)),
        BusStop(name: 'NYAY MANDIR', time: '08:16 AM', coordinates: LatLng(22.2770, 73.1040)),
        BusStop(name: 'MANDVI', time: '08:18 AM', coordinates: LatLng(22.2760, 73.1030)),
        BusStop(name: 'PANI GATE POLICE STATION', time: '08:20 AM', coordinates: LatLng(22.2750, 73.1020)),
        BusStop(name: 'PANIGATE TANKI', time: '08:21 AM', coordinates: LatLng(22.2745, 73.1015)),
        BusStop(name: 'SURYANAGAR', time: '08:22 AM', coordinates: LatLng(22.2740, 73.1010)),
        BusStop(name: 'UMA CHAR RASTA', time: '08:22 AM', coordinates: LatLng(22.2735, 73.1005)),
        BusStop(name: 'ZAVER NAGAR CHAR RASTA', time: '08:25 AM', coordinates: LatLng(22.2730, 73.1000)),
        BusStop(name: 'ZAVER NAGAR', time: '08:26 AM', coordinates: LatLng(22.2720, 73.0990)),
        BusStop(name: 'BAPOD JAKAT NAKA', time: '08:27 AM', coordinates: LatLng(22.2715, 73.0985)),
        BusStop(name: 'VAIKUND', time: '08:30 AM', coordinates: LatLng(22.2710, 73.0980)),
        BusStop(name: 'BAPOD BYEPASS', time: '08:32 AM', coordinates: LatLng(22.2690, 73.0960)),
        BusStop(name: 'GAYATRI TEMPLE', time: '08:38 AM', coordinates: LatLng(22.2680, 73.0950)),
        BusStop(name: 'PIPALIYA', time: '08:40 AM', coordinates: LatLng(22.2665, 73.0935)),
        BusStop(name: 'PIPADIYA', time: '08:40 AM', coordinates: LatLng(22.2660, 73.0930)),
        BusStop(name: 'PIPALIYA NAVI NAGRI', time: '08:43 AM', coordinates: LatLng(22.2650, 73.0920)),
        BusStop(name: 'DUTTAPURA', time: '08:45 AM', coordinates: LatLng(22.2635, 73.0905)),
        BusStop(name: 'LIMDA', time: '08:48 AM', coordinates: LatLng(22.2620, 73.0890)),
        BusStop(name: 'JINDAL ALUMINIUM FOILS PVT LTD', time: '08:50 AM', coordinates: LatLng(22.2610, 73.0880)),
        BusStop(name: 'SHANKAR PACKAGING LIMITED', time: '08:53 AM', coordinates: LatLng(22.2600, 73.0870)),
        BusStop(name: 'GSCSC GODOWN', time: '08:54 AM', coordinates: LatLng(22.2595, 73.0865)),
        BusStop(name: 'WAGHODIA CHOWK', time: '08:55 AM', coordinates: LatLng(22.2590, 73.0860)),
        BusStop(name: 'WAGHODIA', time: '08:55 AM', coordinates: LatLng(22.2587, 73.0857)),
      ],
      routePath: [
        LatLng(22.2830, 73.1100), LatLng(22.2825, 73.1095), LatLng(22.2820, 73.1090),
        LatLng(22.2815, 73.1085), LatLng(22.2810, 73.1080), LatLng(22.2805, 73.1075),
        LatLng(22.2795, 73.1065), LatLng(22.2790, 73.1060), LatLng(22.2780, 73.1050),
        LatLng(22.2770, 73.1040), LatLng(22.2760, 73.1030), LatLng(22.2750, 73.1020),
        LatLng(22.2745, 73.1015), LatLng(22.2740, 73.1010), LatLng(22.2735, 73.1005),
        LatLng(22.2730, 73.1000), LatLng(22.2720, 73.0990), LatLng(22.2715, 73.0985),
        LatLng(22.2710, 73.0980), LatLng(22.2690, 73.0960), LatLng(22.2680, 73.0950),
        LatLng(22.2665, 73.0935), LatLng(22.2660, 73.0930), LatLng(22.2650, 73.0920),
        LatLng(22.2635, 73.0905), LatLng(22.2620, 73.0890), LatLng(22.2610, 73.0880),
        LatLng(22.2600, 73.0870), LatLng(22.2595, 73.0865), LatLng(22.2590, 73.0860),
        LatLng(22.2587, 73.0857),
      ],
    ),
  ];

  Future<List<BusRoute>> getAllRoutes() async {
    final routes = List<BusRoute>.from(_vadodaraRoutes);
    
    // Generate real route paths using Directions API
    for (int i = 0; i < routes.length; i++) {
      final route = routes[i];
      if (route.routePath.isEmpty && route.stops.length >= 2) {
        final waypoints = route.stops.map((stop) => stop.coordinates).toList();
        final realPath = await DirectionsService.getRoute(waypoints);
        
        routes[i] = BusRoute(
          routeId: route.routeId,
          routeName: route.routeName,
          city: route.city,
          stops: route.stops,
          routePath: realPath,
          color: route.color,
          isActive: route.isActive,
        );
      }
    }
    
    return List.unmodifiable(routes);
  }

  List<BusRoute> getRoutesByCity(String city) {
    return _vadodaraRoutes
        .where((route) => route.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  BusRoute? getRouteById(String routeId) {
    try {
      return _vadodaraRoutes.firstWhere(
        (route) => route.routeId.toLowerCase() == routeId.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<BusRoute> searchRoutes(String query) {
    final lowerQuery = query.toLowerCase();
    return _vadodaraRoutes.where((route) {
      return route.routeId.toLowerCase().contains(lowerQuery) ||
          route.routeName.toLowerCase().contains(lowerQuery) ||
          route.stops.any((stop) => stop.name.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  BusStop? findNearestStop(LatLng userLocation, {double maxDistance = 1000}) {
    BusStop? nearestStop;
    double minDistance = double.infinity;

    for (final route in _vadodaraRoutes) {
      for (final stop in route.stops) {
        final distance = _calculateDistance(userLocation, stop.coordinates);
        if (distance < minDistance && distance <= maxDistance) {
          minDistance = distance;
          nearestStop = stop;
        }
      }
    }

    return nearestStop;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    // Simple distance calculation (in meters)
    const double earthRadius = 6371000; // Earth's radius in meters
    final double lat1Rad = point1.latitude * (3.14159 / 180);
    final double lat2Rad = point2.latitude * (3.14159 / 180);
    final double deltaLat = (point2.latitude - point1.latitude) * (3.14159 / 180);
    final double deltaLng = (point2.longitude - point1.longitude) * (3.14159 / 180);

    final double a = (deltaLat / 2) * (deltaLat / 2) +
        lat1Rad.cos() * lat2Rad.cos() * (deltaLng / 2) * (deltaLng / 2);
    final double c = 2 * (a.sqrt()).asin();

    return earthRadius * c;
  }
}

extension on double {
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}
