import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  User? get user => _auth.currentUser;
  bool get isSignedIn => user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> signInWithGoogle() async {
    try {
      _errorMessage = null;
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false; // 사용자가 취소

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
