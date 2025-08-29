import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/firebase/auth.dart';
import 'package:zagreus/firebase/messaging.dart';
import 'package:zagreus/firebase/types.dart';

class ZagFirebaseFirestore {
  /// Returns an instance of [FirebaseFirestore].
  ///
  /// Throws an error if [ZagFirebase.initialize] has not been called.
  static FirebaseFirestore get instance => FirebaseFirestore.instance;

  /// Add a backup entry to Firestore. Returns true if successful, and false on any error.
  ///
  /// If the user is not signed in, returns false.
  Future<bool> addBackupEntry(
    String id,
    int timestamp, {
    String title = '',
    String description = '',
  }) async {
    if (!ZagFirebaseAuth().isSignedIn) return false;
    try {
      ZagFirebaseBackupDocument entry = ZagFirebaseBackupDocument(
        id: id,
        title: title,
        description: description,
        timestamp: timestamp,
      );
      instance
          .doc('users/${ZagFirebaseAuth().uid}/backups/$id')
          .set(entry.toJSON());
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to add backup entry', error, stack);
      return false;
    }
  }

  /// Delete a backup entry from Firestore. Returns true if successful, and false on any error.
  ///
  /// If the user is not signed in, returns false.
  Future<bool> deleteBackupEntry(String? id) async {
    if (!ZagFirebaseAuth().isSignedIn) return false;
    try {
      await instance
          .doc('users/${ZagFirebaseAuth().uid}/backups/$id')
          .delete();
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to delete backup entry', error, stack);
      return false;
    }
  }

  /// Returns a list of all backups available for this account.
  ///
  /// If the user is not signed in, returns an empty list.
  Future<List<ZagFirebaseBackupDocument>> getBackupEntries() async {
    if (!ZagFirebaseAuth().isSignedIn) return [];
    try {
      QuerySnapshot snapshot = await instance
          .collection('users/${ZagFirebaseAuth().uid}/backups')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map<ZagFirebaseBackupDocument>((document) =>
              ZagFirebaseBackupDocument.fromQueryDocumentSnapshot(
                  document as QueryDocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (error, stack) {
      ZagLogger().error('Failed to get backup list', error, stack);
      return [];
    }
  }

  /// Add the current device token to Firestore. Returns true if successful, and false on any error.
  Future<bool> addDeviceToken() async {
    if (!ZagFirebaseAuth().isSignedIn) return false;
    try {
      String? token = await ZagFirebaseMessaging.instance.getToken();
      instance.doc('users/${ZagFirebaseAuth().uid}').set({
        'devices': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to add device token', error, stack);
      return false;
    }
  }
}
