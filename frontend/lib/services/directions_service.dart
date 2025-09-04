import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';

class DirectionsService {
  static const String _baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';
  static const String _accessToken = 'sk.eyJ1IjoieWFzdW83MiIsImEiOiJjbWY0bWloenUwNzlnMnFxdjhjdGF5YXdmIn0.IZ3zeKo_VIt4jkxDczcwNw';

  static Future<List<LatLng>> getRoute(List<LatLng> waypoints, {String profile = 'driving'}) async {
    if (waypoints.length < 2) return waypoints;

    try {
      // Create coordinates string for API
      final coordinates = waypoints
          .map((point) => '${point.longitude},${point.latitude}')
          .join(';');

      final url = '$_baseUrl/$profile/$coordinates'
          '?geometries=geojson'
          '&overview=full'
          '&steps=true'
          '&access_token=$_accessToken';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          
          if (geometry != null && geometry['coordinates'] != null) {
            final coordinates = geometry['coordinates'] as List;
            return coordinates.map<LatLng>((coord) {
              return LatLng(coord[1].toDouble(), coord[0].toDouble());
            }).toList();
          }
        }
      }
    } catch (e) {
      print('Directions API Error: $e');
    }

    // Fallback to original waypoints if API fails
    return waypoints;
  }

  static Future<Map<String, dynamic>?> getRouteInfo(LatLng start, LatLng end) async {
    try {
      final coordinates = '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
      
      final url = '$_baseUrl/driving/$coordinates'
          '?geometries=geojson'
          '&overview=full'
          '&steps=true'
          '&access_token=$_accessToken';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          return {
            'distance': route['distance'], // in meters
            'duration': route['duration'], // in seconds
            'geometry': route['geometry']['coordinates'],
          };
        }
      }
    } catch (e) {
      print('Route info error: $e');
    }
    
    return null;
  }
}
