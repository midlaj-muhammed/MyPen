import 'package:hive/hive.dart';

part 'pen.g.dart';

@HiveType(typeId: 0)
class Pen extends HiveObject {
  @HiveField(0)
  String brand;

  @HiveField(1)
  String image;

  @HiveField(2)
  String? inkId;

  @HiveField(3)
  List<DateTime> sessions;

  @HiveField(4)
  String? color; // Store color as a string (e.g., hex value or color name)

  // New fields
  @HiveField(5)
  String? type;

  @HiveField(6)
  String? model;

  @HiveField(7)
  String? penMaterial;

  @HiveField(8)
  String? penGroup;

  @HiveField(9)
  DateTime? purchaseDate;

  @HiveField(10)
  double? price;

  @HiveField(11)
  String? nibStroke;

  @HiveField(12)
  String? nibMaterial;

  @HiveField(13)
  String? nibPlatting;

  @HiveField(14)
  DateTime? lastCleaned;

  Pen({
    required this.brand,
    required this.image,
    this.inkId,
    List<DateTime>? sessions,
    this.color, // Initialize color as a string
    this.type,
    this.model,
    this.penMaterial,
    this.penGroup,
    this.purchaseDate,
    this.price,
    this.nibStroke,
    this.nibMaterial,
    this.nibPlatting,
    this.lastCleaned,
  }) : sessions = sessions ?? [];

  get id => null;

  set imagePath(String imagePath) {}
}
