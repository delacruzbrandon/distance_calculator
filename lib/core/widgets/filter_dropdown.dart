import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../src/presentation/filter_cubit.dart';

class FilterDropdown extends StatelessWidget {
  const FilterDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterSize>(
      builder: (context, selectedFilter) {
        return DropdownButton<FilterSize>(
          value: selectedFilter,
          borderRadius: BorderRadius.circular(8),
          items: FilterSize.values.map((filter) {
            return DropdownMenuItem(
              value: filter,
              child: Text(filter.label),
            );
          }).toList(),
          onChanged: (FilterSize? value) {
            if (value != null) {
              context.read<FilterCubit>().setFilter(value);
            }
          },
        );
      },
    );
  }
}