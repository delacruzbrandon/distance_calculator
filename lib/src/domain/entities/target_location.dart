import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

class TargetLocation {
  final String id;
  final double latitude;
  final double longitude;

  TargetLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  double distanceTo(Position current) {
    const double earthRadius = 6371000;

    double dLat = _toRadians(latitude - current.latitude);
    double dLon = _toRadians(longitude - current.longitude);

    double lat1 = _toRadians(current.latitude);
    double lat2 = _toRadians(latitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  factory TargetLocation.fromJson(Map<String, dynamic> json) {
    return TargetLocation(
      id: json["id"],
      latitude: json["target_lat"],
      longitude: json["target_lng"],
    );
  }
}