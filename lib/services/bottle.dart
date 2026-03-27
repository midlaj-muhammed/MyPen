import 'package:hive/hive.dart';
import 'package:start2/models/bottle.dart';
import 'package:start2/services/secure_storage.dart';

class BottleService {
  final String _boxName = 'bottles';
  Future<Box<Bottle>>? _boxFuture;

  // Lazy initialization of the box
  Future<Box<Bottle>> _initializeBox() async {
    var cipher = await SecureStorage.getCipher();
    _boxFuture ??= Hive.openBox<Bottle>(_boxName, encryptionCipher: cipher);
    return _boxFuture!;
  }

  // Add a new bottle to the box
  Future<void> addBottle(Bottle bottle) async {
    var box = await _initializeBox();
    await box.add(bottle);
  }

  // Get all bottles from the box
  Future<List<Bottle>> getBottles() async {
    var box = await _initializeBox();
    return box.values.toList();
  }

  // Update a bottle at the specified index
  Future<void> updateBottle(int index, Bottle bottle) async {
    var box = await _initializeBox();

    if (index < 0 || index >= box.length) {
      print('Invalid index: $index');
      return;
    }

    await box.putAt(index, bottle);
  }

  // Delete a bottle at the specified index
  Future<void> deleteBottle(int index) async {
    var box = await _initializeBox();

    if (index < 0 || index >= box.length) {
      print('Invalid index: $index');
      return;
    }

    await box.deleteAt(index);
  }

  // Get a bottle by its ID
  Future<Bottle?> getBottleById(String id) async {
    var box = await _initializeBox();

    // Extract numeric part of the ID
    final key = int.tryParse(id.split('-').last);
    if (key == null) {
      print('Invalid bottle ID format: $id');
      return null;
    }

    if (box.containsKey(key)) {
      return box.get(key);
    } else {
      print('Bottle not found for key: $key');
      return null;
    }
  }
}
