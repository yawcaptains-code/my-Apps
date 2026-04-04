import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hashPassword({required String password, required String salt}) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  static bool verifyPassword({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    return hashPassword(password: password, salt: salt) == expectedHash;
  }
}
