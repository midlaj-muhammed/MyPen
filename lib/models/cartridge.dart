import 'package:hive/hive.dart';

part 'cartridge.g.dart';

@HiveType(typeId: 2)
class Cartridge extends HiveObject {
  @HiveField(0)
  String brand;

  @HiveField(1)
  String image;

  @HiveField(2)
  List<String>? penIds; // Use penIds instead of penBrands

  @HiveField(3)
  String inkName; // Ink name

  @HiveField(4)
  String inkColor; // Ink color

  @HiveField(5)
  String inkGroup; // Ink group

  @HiveField(6)
  int quantity; // Quantity

  @HiveField(7)
  double price; // Price

  @HiveField(8)
  String inkColorName; // Ink color name

  Cartridge({
    required this.brand,
    required this.image,
    this.penIds,
    required this.inkName,
    required this.inkColor,
    required this.inkGroup,
    required this.quantity,
    required this.price,
    required this.inkColorName, // Initialize this field
  });

  get inkId => null;
}
