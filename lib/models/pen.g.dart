// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pen.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PenAdapter extends TypeAdapter<Pen> {
  @override
  final int typeId = 0;

  @override
  Pen read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    var sessions = fields[3];

    // If sessions is a DateTime, wrap it in a list
    if (sessions is DateTime) {
      sessions = [sessions]; // Wrap the single DateTime in a list
    } else if (sessions is! List) {
      sessions =
          <DateTime>[]; // Default to an empty list if it's not a valid type
    }

    // Read the color field as a String
    String? color = fields[4] as String?;

    return Pen(
      brand: fields[0] as String,
      image: fields[1] as String,
      inkId: fields[2] as String?,
      sessions: (sessions as List).cast<DateTime>(),
      color: color, // Pass the color string to the Pen constructor
      type: fields[5] as String?,
      model: fields[6] as String?,
      penMaterial: fields[7] as String?,
      penGroup: fields[8] as String?,
      purchaseDate: fields[9] as DateTime?,
      price: fields[10] as double?,
      nibStroke: fields[11] as String?,
      nibMaterial: fields[12] as String?,
      nibPlatting: fields[13] as String?,
      lastCleaned: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Pen obj) {
    writer
      ..writeByte(15) // Updated field count
      ..writeByte(0)
      ..write(obj.brand)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.inkId)
      ..writeByte(3)
      ..write(obj.sessions)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.model)
      ..writeByte(7)
      ..write(obj.penMaterial)
      ..writeByte(8)
      ..write(obj.penGroup)
      ..writeByte(9)
      ..write(obj.purchaseDate)
      ..writeByte(10)
      ..write(obj.price)
      ..writeByte(11)
      ..write(obj.nibStroke)
      ..writeByte(12)
      ..write(obj.nibMaterial)
      ..writeByte(13)
      ..write(obj.nibPlatting)
      ..writeByte(14)
      ..write(obj.lastCleaned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
