
import 'package:distance_calculator/src/presentation/filter_cubit.dart';
import 'package:distance_calculator/src/presentation/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dependencies.dart';

class DependencyProvider {
  static List<BlocProvider> listProvider() {
    return [
      BlocProvider<HomeCubit>(create: (_) => sl<HomeCubit>(),),
      BlocProvider<FilterCubit>(create: (_) => sl<FilterCubit>(),),
    ];
  }
}