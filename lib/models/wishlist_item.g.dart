part of 'wishlist_item.dart';

class WishlistItemAdapter extends TypeAdapter<WishlistItem> {
  @override
  final int typeId = 3;

  @override
  WishlistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WishlistItem(
      name: fields[0] as String,
      brand: fields[1] as String,
      targetPrice: fields[2] as double,
      itemType: fields[3] as String,
      url: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WishlistItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.brand)
      ..writeByte(2)
      ..write(obj.targetPrice)
      ..writeByte(3)
      ..write(obj.itemType)
      ..writeByte(4)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
