import 'package:hive/hive.dart';
import 'package:start2/models/wishlist_item.dart';
import 'package:start2/services/secure_storage.dart';

class WishlistService {
  final String _boxName = 'wishlist';

  Future<Box<WishlistItem>> _openBox() async {
    var cipher = await SecureStorage.getCipher();
    return await Hive.openBox<WishlistItem>(_boxName, encryptionCipher: cipher);
  }

  Future<void> addItem(WishlistItem item) async {
    var box = await _openBox();
    await box.add(item);
  }

  Future<List<WishlistItem>> getItems() async {
    var box = await _openBox();
    return box.values.toList();
  }

  Future<void> deleteItem(int index) async {
    var box = await _openBox();
    if (index >= 0 && index < box.length) {
      await box.deleteAt(index);
    }
  }
}
