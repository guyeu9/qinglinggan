import 'dart:convert';

class SecureString {
  SecureString._();

  static String encode(String plainText) {
    return base64Encode(utf8.encode(plainText));
  }

  static String decode(String encodedText) {
    return utf8.decode(base64Decode(encodedText));
  }
}
