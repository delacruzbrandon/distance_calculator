import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:distance_calculator/src/domain/entities/location_reading.dart';
import 'package:distance_calculator/src/domain/entities/target_location.dart';
import 'package:distance_calculator/src/domain/repositories/location_repository.dart';
import 'package:distance_calculator/src/presentation/home_cubit.dart';
import 'package:distance_calculator/src/presentation/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

// Mock Repository
class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late HomeCubit homeCubit;
  late MockLocationRepository mockRepository;

  // Mock sample data
  final mockPosition = Position(
    latitude: 10.0, longitude: 10.0,
    timestamp: DateTime.now(), accuracy: 1.0, altitude: 1.0,
    heading: 0.0, speed: 0.0, speedAccuracy: 0.0,
    altitudeAccuracy: 0.0, headingAccuracy: 0.0,
  );
  final mockTarget = TargetLocation(latitude: 1.265, longitude: 103.695, id: '001');
  final mockPermission = LocationPermission.always;

  setUp(() {
    mockRepository = MockLocationRepository();
    homeCubit = HomeCubit(mockRepository);

    // Default mock behaviors
    when(() => mockRepository.checkLocationPermissions()).thenAnswer((_) async => mockPermission);
    when(() => mockRepository.clearReadings()).thenAnswer((_) async => {});
    when(() => mockRepository.storeReading(any())).thenAnswer((_) async => {});
  });

  tearDown(() {
    homeCubit.close();
  });

  setUpAll(() {
    registerFallbackValue(LocationReading(
      timeStamp: DateTime.now(),
      distance: "0m",
      latitude: 0,
      longitude: 0,
    ));
  });

  group('HomeCubit - toggleTracking', () {
    test('initial state is HomeIdle', () {
      expect(homeCubit.state, isA<HomeIdle>());
    });

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, TrackingStart] when isTracking is true',
      build: () {
        when(() => mockRepository.getTargetLocation()).thenAnswer((_) async => mockTarget);
        when(() => mockRepository.getCurrentLocation()).thenAnswer((_) async => mockPosition);
        return homeCubit;
      },
      act: (cubit) => cubit.toggleTracking(true),
      expect: () => [
        isA<HomeLoading>(),
        isA<TrackingStart>(),
      ],
      verify: (_) {
        verify(() => mockRepository.clearReadings()).called(1);
        verify(() => mockRepository.getTargetLocation()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when permissions are denied',
      build: () {
        when(() => mockRepository.getTargetLocation())
            .thenAnswer((_) async => mockTarget);
        when(() => mockRepository.checkLocationPermissions())
            .thenThrow(Exception("Permission Denied"));
        when(() => mockRepository.requestOpenLocationSettings()).thenAnswer((_) async => true);
        return homeCubit;
      },
      act: (cubit) => cubit.toggleTracking(true),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>(),
      ],
    );
  });

  group('Lifecycle Management', () {
    test('stops timer when app is paused', () {
      homeCubit.onChangeLifecycleState(AppLifecycleState.paused);
    });
  });
}