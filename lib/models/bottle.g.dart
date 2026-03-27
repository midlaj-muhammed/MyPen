// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BottleAdapter extends TypeAdapter<Bottle> {
  @override
  final int typeId = 1;

  @override
  Bottle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Bottle(
      brand: fields[0] as String? ??
          '', // Handle null and provide an empty string as default
      image: fields[1] as String? ??
          '', // Handle null and provide an empty string as default
      penIds:
          (fields[2] as List?)?.cast<String>(), // Handle null penIds gracefully
      inkName: fields[3] as String? ??
          '', // Handle null and provide an empty string as default
      inkColor: fields[4] as String? ??
          '', // Handle null and provide an empty string as default
      inkGroup: fields[5] as String? ??
          '', // Handle null and provide an empty string as default
      quantity: fields[6] as int? ?? 0, // Handle null and provide 0 as default
      price:
          fields[7] as double? ?? 0.0, // Handle null and provide 0.0 as default
      inkColorName: fields[8] as String? ??
          '', // Handle null and provide an empty string as default
    );
  }

  @override
  void write(BinaryWriter writer, Bottle obj) {
    writer
      ..writeByte(9) // Number of fields is 9
      ..writeByte(0)
      ..write(obj.brand)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.penIds)
      ..writeByte(3)
      ..write(obj.inkName)
      ..writeByte(4)
      ..write(obj.inkColor)
      ..writeByte(5)
      ..write(obj.inkGroup)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.inkColorName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BottleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
