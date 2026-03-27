// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cartridge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartridgeAdapter extends TypeAdapter<Cartridge> {
  @override
  final int typeId = 2;

  @override
  Cartridge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Cartridge(
      brand: fields[0] as String? ?? '',
      image: fields[1] as String? ?? '',
      penIds: (fields[2] as List?)?.cast<String>(),
      inkName: fields[3] as String? ?? '',
      inkColor: fields[4] as String? ?? '',
      inkGroup: fields[5] as String? ?? '',
      quantity: fields[6] as int? ?? 0,
      price: fields[7] as double? ?? 0.0,
      inkColorName: fields[8] as String? ??
          '', // Handle null and provide an empty string as default
    );
  }

  @override
  void write(BinaryWriter writer, Cartridge obj) {
    writer
      ..writeByte(9) // Number of fields is now 9
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
      ..write(obj.inkColorName); // Write the ink color name field
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartridgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
