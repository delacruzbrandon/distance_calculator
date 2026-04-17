import 'package:distance_calculator/src/domain/entities/location_reading.dart';
import 'package:distance_calculator/src/domain/entities/target_location.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

class HomeIdle extends HomeState {
  @override
  List<Object?> get props => [];
}

class TrackingStart extends HomeState {
  final Position currentPosition;
  final TargetLocation targetPosition;
  final String distanceFromTarget;
  final List<LocationReading> historyList;
  final int tick;

  const TrackingStart({
    required this.currentPosition,
    required this.targetPosition,
    required this.distanceFromTarget,
    required this.historyList,
    required this.tick,
  });

  @override
  List<Object?> get props => [
    currentPosition,
    targetPosition,
    distanceFromTarget,
    historyList,
    tick,
  ];
}

class TrackingEnd extends HomeState {
  final List<LocationReading> historyList;

  const TrackingEnd(this.historyList);

  @override
  List<Object?> get props => [historyList];
}

class HomeError extends HomeState {
  final String error;

  const HomeError(this.error);

  @override
  List<Object?> get props => [error];
}

class HomeLoading extends HomeState {
  @override
  List<Object?> get props => [];
}
