class UserProfile {
  final String? avatar;
  final String? bio;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;

  UserProfile({
    this.avatar,
    this.bio,
    this.phone,
    this.dateOfBirth,
    this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      avatar: json['avatar'],
      bio: json['bio'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'bio': bio,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
    };
  }
}

class UserPreferences {
  final bool notifications;
  final bool locationSharing;
  final String theme;
  final String language;
  final String privacyLevel;

  UserPreferences({
    this.notifications = true,
    this.locationSharing = true,
    this.theme = 'dark',
    this.language = 'en',
    this.privacyLevel = 'public',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notifications: json['notifications'] ?? true,
      locationSharing: json['locationSharing'] ?? true,
      theme: json['theme'] ?? 'dark',
      language: json['language'] ?? 'en',
      privacyLevel: json['privacyLevel'] ?? 'public',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'locationSharing': locationSharing,
      'theme': theme,
      'language': language,
      'privacyLevel': privacyLevel,
    };
  }
}

class UserStatistics {
  final int totalTrips;
  final double totalDistance;
  final int totalDuration;
  final double averageSpeed;
  final DateTime? lastActiveDate;

  UserStatistics({
    this.totalTrips = 0,
    this.totalDistance = 0.0,
    this.totalDuration = 0,
    this.averageSpeed = 0.0,
    this.lastActiveDate,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalTrips: json['totalTrips'] ?? 0,
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      totalDuration: json['totalDuration'] ?? 0,
      averageSpeed: (json['averageSpeed'] ?? 0).toDouble(),
      lastActiveDate: json['lastActiveDate'] != null ? DateTime.parse(json['lastActiveDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTrips': totalTrips,
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'averageSpeed': averageSpeed,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final int points;
  final List<String> badges;
  final int tipsReceived;
  final UserProfile? profile;
  final UserPreferences? preferences;
  final UserStatistics? statistics;
  final bool isActive;
  final bool isVerified;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.points = 0,
    this.badges = const [],
    this.tipsReceived = 0,
    this.profile,
    this.preferences,
    this.statistics,
    this.isActive = true,
    this.isVerified = false,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      points: json['points'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      tipsReceived: json['tipsReceived'] ?? 0,
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
      preferences: json['preferences'] != null ? UserPreferences.fromJson(json['preferences']) : null,
      statistics: json['statistics'] != null ? UserStatistics.fromJson(json['statistics']) : null,
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'points': points,
      'badges': badges,
      'tipsReceived': tipsReceived,
      'profile': profile?.toJson(),
      'preferences': preferences?.toJson(),
      'statistics': statistics?.toJson(),
      'isActive': isActive,
      'isVerified': isVerified,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
