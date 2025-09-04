class User {
  final String id;
  final String name;
  final String email;
  final int points;
  final double walletBalance;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.points,
    required this.walletBalance,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      points: json['points'] ?? 0,
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'points': points,
      'walletBalance': walletBalance,
      'token': token,
    };
  }
}

class LocationShare {
  final String userId;
  final double latitude;
  final double longitude;
  final String busName;
  final DateTime timestamp;
  final String busType;
  final double speed;
  final String? userName;

  LocationShare({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.busName,
    required this.timestamp,
    this.busType = 'regular',
    this.speed = 0.0,
    this.userName,
  });

  factory LocationShare.fromJson(Map<String, dynamic> json) {
    return LocationShare(
      userId: json['userId'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      busName: json['busName'],
      timestamp: DateTime.parse(json['timestamp']),
      busType: json['busType'] ?? 'regular',
      speed: (json['speed'] ?? 0.0).toDouble(),
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'busName': busName,
      'timestamp': timestamp.toIso8601String(),
      'busType': busType,
      'speed': speed,
      'userName': userName,
    };
  }
}
