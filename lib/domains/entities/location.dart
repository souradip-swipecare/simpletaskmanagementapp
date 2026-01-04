class LoginLocation {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LoginLocation({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LoginLocation.fromMap(String id, Map<String, dynamic> map) =>
      LoginLocation(
        id: id,
        userId: map['userId'] ?? '',
        latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      );
}
