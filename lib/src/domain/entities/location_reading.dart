import 'package:hive/hive.dart';

part 'location_reading.g.dart';

@HiveType(typeId: 0)
class LocationReading {
  @HiveField(0)
  final DateTime timeStamp;
  @HiveField(1)
  final double distance;
  @HiveField(2)
  final double latitude;
  @HiveField(3)
  final double longitude;

  LocationReading({
    required this.timeStamp,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });
}
