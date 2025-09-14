import 'dart:convert';
import 'package:encrypt/encrypt.dart';

/// Simple encryption service for backups
/// Based on LunaSea's approach - user provides password, we don't store any keys
class BackupEncryptionService {
  BackupEncryptionService._();
  
  static Key _generateKey(String password) {
    const length = 32;
    const pad = '0';
    // Morph the password to exactly 32 characters for AES-256
    String morphed = (password + password).padRight(length, pad).substring(0, length);
    return Key.fromUtf8(morphed);
  }
  
  static IV _generateIV() {
    const length = 16;
    return IV.fromLength(length);
  }
  
  /// Encrypt backup data with a user-provided password
  static String encrypt(String password, String data) {
    try {
      final encrypter = Encrypter(AES(_generateKey(password)));
      return encrypter.encrypt(data, iv: _generateIV()).base64;
    } catch (e) {
      throw Exception('Failed to encrypt backup: $e');
    }
  }
  
  /// Decrypt backup data with a user-provided password
  static String decrypt(String password, String encryptedData) {
    try {
      final encrypter = Encrypter(AES(_generateKey(password)));
      return encrypter.decrypt64(encryptedData, iv: _generateIV());
    } catch (e) {
      throw Exception('Failed to decrypt backup - incorrect password');
    }
  }
  
  /// Create an encrypted backup from profile data
  static String createBackup(Map<String, dynamic> profileData, String password) {
    final jsonData = jsonEncode(profileData);
    return encrypt(password, jsonData);
  }
  
  /// Restore profile data from an encrypted backup
  static Map<String, dynamic> restoreBackup(String encryptedBackup, String password) {
    final jsonData = decrypt(password, encryptedBackup);
    return jsonDecode(jsonData);
  }
  
  /// Verify if a password can decrypt a backup
  static bool verifyPassword(String encryptedBackup, String password) {
    try {
      decrypt(password, encryptedBackup);
      return true;
    } catch (e) {
      return false;
    }
  }
}