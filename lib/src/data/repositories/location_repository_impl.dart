import 'package:dio/dio.dart';
import 'package:distance_calculator/src/domain/entities/location_reading.dart';
import 'package:distance_calculator/src/domain/entities/target_location.dart';
import 'package:distance_calculator/src/domain/repositories/location_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

import '../constants/app_constants.dart';

class LocationRepositoryImpl implements LocationRepository {
  final Dio dio;
  final Box box;

  LocationRepositoryImpl({
    required this.dio,
    required this.box,
  });

  @override
  Future<TargetLocation?> getTargetLocation() async {
    try {
      final response = await dio.get(AppConstants.target);
      return TargetLocation.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Unknown error');
    }
  }

  @override
  List<LocationReading> getLocationReadings() {
    return box.values.cast<LocationReading>().toList();
  }

  // @override
  // Future<void> storeReadingsBulk(List<LocationReading> readings) async =>
  //     await box.addAll(readings);

  @override
  Future<void> storeReading(LocationReading reading) async =>
      await box.add(reading);

  @override
  Future<void> clearReadings() async =>
      await box.clear();

  @override
  Future<LocationPermission> checkLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceDisabledException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceDisabledException();
    }

    return permission;
  }

  @override
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  @override
  Stream<Position> streamCurrentLocation() {
    return Geolocator.getServiceStatusStream()
        .startWith(ServiceStatus.enabled)
        .switchMap((status) {

      if (status == ServiceStatus.disabled) {
        return Stream.error(LocationServiceDisabledException());
      }
      return Geolocator.getPositionStream(
        locationSettings: _getLocationSettings()
      );
    });
  }

  LocationSettings _getLocationSettings() {
    late LocationSettings locationSettings;
    print("streamCurrentLocation defaultTargetPlatform ${defaultTargetPlatform}");

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 5),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            "App will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.other,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: false,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    return locationSettings;
  }

  @override
  Future<void> requestOpenLocationSettings() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool opened = await Geolocator.openLocationSettings();
      if (!opened) {
        throw LocationServiceDisabledException();
      }
    }
  }

}
