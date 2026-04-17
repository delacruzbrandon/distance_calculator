import 'dart:async';
import 'dart:ui';

import 'package:distance_calculator/src/domain/entities/location_reading.dart';
import 'package:distance_calculator/src/domain/entities/target_location.dart';
import 'package:distance_calculator/src/domain/repositories/location_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final LocationRepository _repository;

  HomeCubit(this._repository) : super(HomeIdle());

  StreamSubscription<Position>? _currentLocationStream;
  TargetLocation? _targetLocation;
  final List<LocationReading> _locationReadings = [];

  Timer? _locationTimer;
  int _tickCounter = 0;

  Future<void> toggleTracking(bool isTracking) async {
    emit(HomeLoading());
    if (isTracking) {
      _clearHistory();
      await _getPermissions();
      _targetLocation = await _repository.getTargetLocation();
      _streamCurrentLocation();
    } else {
      await _endStream();
      _getLocationHistory();
    }
  }

  void _streamCurrentLocation() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _onLocationTick();
    });

    _onLocationTick();
  }

  Future<void> _onLocationTick() async {
    final target = _targetLocation;
    if (target == null) return;

    try {
      final position = await _repository.getCurrentLocation();
      final distance = target.distanceTo(position);
      final formattedDistance = _formatDistance(distance);

      final newReading = LocationReading(
        timeStamp: DateTime.now(),
        distance: formattedDistance,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _repository.storeReading(newReading);
      _locationReadings.insert(0, newReading);

      _tickCounter++;

      emit(TrackingStart(
        currentPosition: position,
        targetPosition: target,
        distanceFromTarget: formattedDistance,
        historyList: List.from(_locationReadings),
        tick: _tickCounter,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  String _formatDistance(double distance) =>
      distance < 1000
        ? "${distance.toStringAsFixed(0)}m"
        : "${(distance / 1000).toStringAsFixed(2)}km";


  Future<void> _getPermissions() async {
    try {
      await _repository
          .checkLocationPermissions();
    } catch (e) {
      await _repository.requestOpenLocationSettings();
    }
  }

  Future<void> _endStream() async {
    _locationTimer?.cancel();
    _locationTimer = null;
    await _currentLocationStream?.cancel();
    _currentLocationStream = null;
    emit(TrackingEnd(List.from(_locationReadings)));
  }

  void _getLocationHistory() {
    final readingHistory = _repository.getLocationReadings();
    _locationReadings.addAll(readingHistory);
  }

  Future<void> _clearHistory() async {
    await _repository.clearReadings();
    _tickCounter = 0;
    _locationReadings.clear();
  }

  void onChangeLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused || lifecycle == AppLifecycleState.inactive) {
      _locationTimer?.cancel();
      _locationTimer = null;
    } else if (lifecycle == AppLifecycleState.resumed) {
      if (state is TrackingStart) {
        _streamCurrentLocation();
      }
    }
  }

  @override
  Future<void> close() {
    _endStream();
    return super.close();
  }
}
