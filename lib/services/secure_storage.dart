import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecureStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _encryptionKeyName = 'hive_encryption_key';

  static Future<HiveAesCipher> getCipher() async {
    var containsEncryptionKey = await _secureStorage.containsKey(key: _encryptionKeyName);
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();
      await _secureStorage.write(key: _encryptionKeyName, value: base64UrlEncode(key));
    }

    var encryptionKeyString = await _secureStorage.read(key: _encryptionKeyName);
    var encryptionKeyArray = base64Url.decode(encryptionKeyString!);
    return HiveAesCipher(encryptionKeyArray);
  }
}
