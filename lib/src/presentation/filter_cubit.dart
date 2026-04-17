import 'package:flutter_bloc/flutter_bloc.dart';

enum FilterSize { five, ten, fifteen, twenty }

extension FilterSizeExtension on FilterSize {
  int get value {
    switch (this) {
      case FilterSize.five:     return 5;
      case FilterSize.ten:      return 10;
      case FilterSize.fifteen:  return 15;
      case FilterSize.twenty:   return 20;
    }
  }

  String get label => '${value} readings';
}

class FilterCubit extends Cubit<FilterSize> {
  FilterCubit() : super(FilterSize.ten);

  void setFilter(FilterSize size) => emit(size);
}