import 'package:hive/hive.dart';
import 'package:start2/models/cartridge.dart';
import 'package:start2/services/secure_storage.dart';

class CartridgeService {
  final String _boxName = 'cartridges';

  Future<Box<Cartridge>> _openBox() async {
    var cipher = await SecureStorage.getCipher();
    return await Hive.openBox<Cartridge>(_boxName, encryptionCipher: cipher);
  }

  Future<void> addCartridge(Cartridge cartridge) async {
    var box = await _openBox();
    await box.add(cartridge);
  }

  Future<List<Cartridge>> getCartridges() async {
    var box = await _openBox();
    return box.values.toList();
  }


  Future<void> updateCartridge(int index, Cartridge cartridge) async {
    var box = await _openBox();

    if (index < 0 || index >= box.length) {
      print('Invalid index: $index');
      return;
    }

    await box.putAt(index, cartridge);
  }

  Future<void> deleteCartridge(int index) async {
    var box = await _openBox();

    if (index < 0 || index >= box.length) {
      print('Invalid index: $index');
      return;
    }

    await box.deleteAt(index);
  }

  Future<Cartridge?> getCartridgeById(String id) async {
    // Extract numeric part of the ID
    final key = int.tryParse(id.split('-').last);
    if (key == null) {
      print('Invalid cartridge ID format: $id');
      return null;
    }

    var box = await _openBox();
    if (box.containsKey(key)) {
      return box.get(key);
    } else {
      print('Cartridge not found for key: $key');
      return null;
    }
  }
}
