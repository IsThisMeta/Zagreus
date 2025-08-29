import 'package:firebase_auth/firebase_auth.dart';

class ZagFirebaseResponse {
  final bool state;
  final UserCredential? user;
  final FirebaseAuthException? error;

  ZagFirebaseResponse({
    required this.state,
    this.user,
    this.error,
  });
}
