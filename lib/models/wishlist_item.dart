import 'package:hive/hive.dart';

part 'wishlist_item.g.dart';

@HiveType(typeId: 3)
class WishlistItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String brand;

  @HiveField(2)
  double targetPrice;

  @HiveField(3)
  String itemType;

  @HiveField(4)
  String? url;

  WishlistItem({
    required this.name,
    required this.brand,
    required this.targetPrice,
    required this.itemType,
    this.url,
  });
}
