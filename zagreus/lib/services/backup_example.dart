import 'package:zagreus/services/backup_encryption_service.dart';

/// Example usage of the backup encryption service
/// Following LunaSea's approach - simple password-based encryption
class BackupExample {
  
  /// Create an encrypted backup with a user-provided password
  static String createEncryptedBackup(String password) {
    // Your profile data (API keys, hostnames, etc)
    final profileData = {
      'name': 'My Server',
      'hostname': '192.168.1.100',
      'port': 8989,
      'apiKey': 'your-api-key-here',
      'radarrEnabled': true,
      'sonarrEnabled': true,
      'radarrApiKey': 'radarr-key-here',
      'sonarrApiKey': 'sonarr-key-here',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Encrypt with the user's password
    final encryptedBackup = BackupEncryptionService.createBackup(
      profileData,
      password,
    );
    
    print('Encrypted backup created');
    print('Length: ${encryptedBackup.length} characters');
    
    return encryptedBackup;
  }
  
  /// Restore from an encrypted backup
  static Map<String, dynamic>? restoreFromBackup(
    String encryptedBackup, 
    String password,
  ) {
    try {
      // Decrypt with the user's password
      final restoredData = BackupEncryptionService.restoreBackup(
        encryptedBackup,
        password,
      );
      
      print('Backup restored successfully');
      print('Profile: ${restoredData['name']}');
      print('Host: ${restoredData['hostname']}');
      
      return restoredData;
    } catch (e) {
      print('Failed to restore - incorrect password');
      return null;
    }
  }
  
  /// Check if a password is correct for a backup
  static bool checkPassword(String encryptedBackup, String password) {
    final isValid = BackupEncryptionService.verifyPassword(
      encryptedBackup,
      password,
    );
    
    print('Password is ${isValid ? 'correct' : 'incorrect'}');
    return isValid;
  }
}

// Usage in your app:
// 
// 1. When user wants to backup:
//    - Show dialog asking for password
//    - String backup = BackupExample.createEncryptedBackup(userPassword);
//    - Save backup to file or cloud
//
// 2. When user wants to restore:
//    - Load backup file
//    - Show dialog asking for password
//    - var data = BackupExample.restoreFromBackup(backup, userPassword);
//    - If null, password was wrong, ask again
//
// The beauty of this approach:
// - You (the developer) never have access to decrypt user's backups
// - Each user chooses their own password
// - No keys stored anywhere - completely stateless
// - User is responsible for remembering their password