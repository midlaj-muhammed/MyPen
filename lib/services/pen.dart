import 'package:hive/hive.dart';
import 'package:start2/models/pen.dart';
import 'package:start2/services/secure_storage.dart';

class PenService {
  final String _boxName = 'pens';

  // Open the Hive box for Pens
  Future<Box<Pen>> _openBox() async {
    var cipher = await SecureStorage.getCipher();
    return await Hive.openBox<Pen>(_boxName, encryptionCipher: cipher);
  }

  // Add a new pen
  Future<void> addPen(Pen pen) async {
    var box = await _openBox();
    await box.add(pen);
  }

  // Get all pens
  Future<List<Pen>> getPens() async {
    var box = await _openBox();
    return box.values.toList();
  }

  // Get pens by type (Fountain, Rollerball, etc.)
  Future<List<Pen>> getPensByType(String type) async {
    var box = await _openBox();
    return box.values
        .where((pen) => pen.type == type) // Filter by pen type
        .toList();
  }

  Future<List<Pen>> getPensSortedByPrice(bool ascending) async {
    var box = await _openBox();
    var pens = box.values.toList();
    pens.sort((a, b) {
      // Provide default value of 0.0 for null price
      double priceA = a.price ?? 0.0;
      double priceB = b.price ?? 0.0;

      return ascending
          ? priceA.compareTo(priceB) // Ascending order
          : priceB.compareTo(priceA); // Descending order
    });
    return pens;
  }

  // Update an existing pen
  Future<void> updatePen(int index, Pen pen) async {
    var box = await _openBox();
    await box.putAt(index, pen);
  }

  // Delete a pen
  Future<void> deletePen(int index) async {
    var box = await _openBox();
    await box.deleteAt(index);
  }

  // Update the ink brand associated with a pen
  Future<void> updateInkBrand(int index, String inkBrand) async {
    var box = await _openBox();
    var pen = box.getAt(index);
    if (pen != null) {
      pen.inkId = inkBrand; // Update the ink ID
      await box.putAt(index, pen); // Save the updated pen object
    }
  }

  // Fetch a pen based on its inkId (if an ink is associated with it)
  Future<Pen?> getPenByInkId(String inkId) async {
    var box = await _openBox();

    // Strip the "bottle-" prefix if it exists
    if (inkId.startsWith('bottle-')) {
      inkId = inkId.substring(7); // Remove the "bottle-" part
    }

    // Debugging log to confirm inkId
    print('Searching for pen with inkId: $inkId');

    // Iterate through all pens to find the one with the matching inkId
    for (var pen in box.values) {
      // Debugging log to check the inkId of each pen
      print('Checking pen with inkId: ${pen.inkId}');
      if (pen.inkId == inkId) {
        print('Pen found with inkId: $inkId'); // Found a pen, log it
        return pen;
      }
    }
    print('No pen found with inkId: $inkId'); // Log if no pen is found
    return null; // Return null if no pen is found with the given inkId
  }
}
