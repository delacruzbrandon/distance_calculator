import 'package:distance_calculator/src/presentation/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/filter_dropdown.dart';
import '../domain/entities/location_reading.dart';
import 'filter_cubit.dart';
import 'home_cubit.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    context.read<HomeCubit>().onChangeLifecycleState(lifecycle);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final bool isCurrentlyTracking = state is TrackingStart;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statusCard(state),
              const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: isCurrentlyTracking,
                    activeThumbColor: Colors.green,
                    onChanged: (bool value) async =>
                        await _onToggleTracking(value),
                  ),
                  SizedBox(width: 8,),
                  Text(isCurrentlyTracking ? "ONLINE" : "OFFLINE"),
                  Spacer(),
                  const FilterDropdown(),
                ],
              ),
          ),
              _locationReadings(state),
            ],
          ),
        );
      },
    );
  }

  Widget _locationReadings(HomeState state) {
    final List<LocationReading>? readings = switch (state) {
      TrackingStart s => s.historyList,
      TrackingEnd s => s.historyList,
      _ => null,
    };

    if (readings == null) return const SizedBox.shrink();

    return BlocBuilder<FilterCubit, FilterSize>(
      builder: (context, filterSize) {
        final history = readings.take(filterSize.value).toList();

        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final reading = history[index];
                    return Card(
                      color: index == 0
                          ? Colors.greenAccent.withValues(alpha: 0.5)
                          : null,
                      child: ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: index == 0 ? Colors.green : Colors.grey,
                        ),
                        title: Text(
                          "Lat: ${reading.latitude.toStringAsFixed(4)}, "
                          "Lng: ${reading.longitude.toStringAsFixed(4)}",
                        ),
                        subtitle: Text("Time: ${reading.timeStamp.toLocal()}"),
                        trailing: index == 0
                            ? const Badge(
                                label: Text("Latest"),
                                backgroundColor: Colors.blueAccent,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusCard(HomeState state) {
    if (state is HomeLoading) {
      return const CircularProgressIndicator();
    }

    if (state is TrackingStart) {
      final current = state.currentPosition;
      final target = state.targetPosition;
      final distance = state.distanceFromTarget;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Current"),
                      Text(
                        "${current.latitude.toStringAsFixed(4)}, ${current.longitude.toStringAsFixed(4)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Target"),
                      Text(
                        "${target.latitude.toStringAsFixed(4)}, ${target.longitude.toStringAsFixed(4)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              const Text("Distance to Target"),
              Text(
                distance < 1000
                    ? "${distance.toStringAsFixed(0)}m"
                    : "${(distance / 1000).toStringAsFixed(2)}km",
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const Text("Toggle switch to start tracking");
  }

  Future<void> _onToggleTracking(bool value) async {
    await context.read<HomeCubit>().toggleTracking(value);
  }
}
