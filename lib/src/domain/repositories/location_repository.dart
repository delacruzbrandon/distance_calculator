import 'package:distance_calculator/src/domain/entities/location_reading.dart';
import 'package:distance_calculator/src/domain/entities/target_location.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationRepository {
  Future<LocationPermission> checkLocationPermissions();
  Future<Position> getCurrentLocation();
  Stream<Position> streamCurrentLocation();
  Future<TargetLocation?> getTargetLocation();
  Future<void> requestOpenLocationSettings();
  List<LocationReading> getLocationReadings();
  // Future<void> storeReadingsBulk(List<LocationReading> readings);
  Future<void> clearReadings();
  Future<void> storeReading(LocationReading reading);
}