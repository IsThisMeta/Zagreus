import 'package:firebase_storage/firebase_storage.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/firebase/auth.dart';

class ZagFirebaseStorage {
  static const String _BACKUP_BUCKET = 'backup.zagreus.app';

  /// Returns an instance of [FirebaseStorage] for the default bucket.
  ///
  /// Throws an error if [ZagFirebase.initialize] has not been called.
  static FirebaseStorage get instanceDefault => FirebaseStorage.instance;

  /// Returns an instance of [FirebaseStorage] for the backup bucket.
  ///
  /// Throws an error if [ZagFirebase.initialize] has not been called.
  static FirebaseStorage get instanceBackup =>
      FirebaseStorage.instanceFor(bucket: _BACKUP_BUCKET);

  /// Upload a backup configuration to Firebase storage.
  ///
  /// If the user is not signed in, returns null.
  Future<bool> uploadBackup(String data, String id) async {
    if (!ZagFirebaseAuth().isSignedIn) return false;
    try {
      await instanceBackup
          .ref('${ZagFirebaseAuth().uid}/$id.zagreus')
          .putString(data);
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to backup to Firebase', error, stack);
      return false;
    }
  }

  /// Delete a backup configuration from Firebase storage.
  ///
  /// If the user is not signed in, returns null.
  Future<bool> deleteBackup(String? id) async {
    if (!ZagFirebaseAuth().isSignedIn) return false;
    try {
      await instanceBackup
          .ref('${ZagFirebaseAuth().uid}/$id.zagreus')
          .delete();
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to delete backup from Firebase', error, stack);
      return false;
    }
  }

  /// Download a backup configuration from Firebase storage.
  ///
  /// If the user is not signed in, returns null.
  Future<String?> downloadBackup(String? id) async {
    if (!ZagFirebaseAuth().isSignedIn) return null;
    try {
      Uint8List? data = await instanceBackup
          .ref('${ZagFirebaseAuth().uid}/$id.zagreus')
          .getData();
      return String.fromCharCodes(data!);
    } catch (error, stack) {
      ZagLogger()
          .error('Failed to download backup from Firebase', error, stack);
      return null;
    }
  }
}
