import 'package:dio/dio.dart';
import 'package:distance_calculator/src/data/repositories/location_repository_impl.dart';
import 'package:distance_calculator/src/domain/repositories/location_repository.dart';
import 'package:distance_calculator/src/presentation/filter_cubit.dart';
import 'package:distance_calculator/src/presentation/home_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../src/domain/entities/location_reading.dart';

GetIt sl = GetIt.instance;

Future<void> init() async {
  Hive.registerAdapter(LocationReadingAdapter());
  final myBox = await Hive.openBox(
    'myBox',
  );

  sl
    // UI Logic
    ..registerFactory(
            () => HomeCubit(sl()))
    ..registerFactory(
            () => FilterCubit())

    // Data Sources
    ..registerLazySingleton<LocationRepository>(
            () => LocationRepositoryImpl(dio: sl<Dio>(), box: sl<Box>()))

    // External

    ..registerLazySingleton<Dio>(
            () => Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        ))
    ..registerSingleton<Box>(myBox);
}