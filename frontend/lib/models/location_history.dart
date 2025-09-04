class LocationHistory {
  final String userId;
  final String busName;
  final String busType;
  final List<LocationPoint> route;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistance;
  final double averageSpeed;
  final int totalPoints;

  LocationHistory({
    required this.userId,
    required this.busName,
    required this.busType,
    required this.route,
    required this.startTime,
    this.endTime,
    this.totalDistance = 0.0,
    this.averageSpeed = 0.0,
    this.totalPoints = 0,
  });

  factory LocationHistory.fromJson(Map<String, dynamic> json) {
    return LocationHistory(
      userId: json['userId'],
      busName: json['busName'],
      busType: json['busType'] ?? 'regular',
      route: (json['route'] as List)
          .map((point) => LocationPoint.fromJson(point))
          .toList(),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      averageSpeed: (json['averageSpeed'] ?? 0.0).toDouble(),
      totalPoints: json['totalPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'busName': busName,
      'busType': busType,
      'route': route.map((point) => point.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalDistance': totalDistance,
      'averageSpeed': averageSpeed,
      'totalPoints': totalPoints,
    };
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isActive => endTime == null;
}

class LocationPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double speed;
  final double? accuracy;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed = 0.0,
    this.accuracy,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      speed: (json['speed'] ?? 0.0).toDouble(),
      accuracy: json['accuracy']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'accuracy': accuracy,
    };
  }
}
