// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_reading.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationReadingAdapter extends TypeAdapter<LocationReading> {
  @override
  final int typeId = 0;

  @override
  LocationReading read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationReading(
      timeStamp: fields[0] as DateTime,
      distance: fields[1] as double,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LocationReading obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timeStamp)
      ..writeByte(1)
      ..write(obj.distance)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationReadingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
