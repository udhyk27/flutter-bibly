import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  StreamSubscription<User?>? _authSub;

  User? get user => _auth.currentUser;
  bool get isSignedIn => user != null;

  AuthProvider() {
    _authSub = _auth.authStateChanges().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
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
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  // 예외를 사용자에게 보여줄 한국어 메시지로 변환한다.
  String _friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          return '다른 방법으로 이미 가입된 계정입니다.';
        case 'invalid-credential':
          return '인증 정보가 올바르지 않습니다. 다시 시도해주세요.';
        case 'user-disabled':
          return '사용이 중지된 계정입니다.';
        case 'network-request-failed':
          return '네트워크 연결을 확인해주세요.';
        default:
          return '로그인 중 문제가 발생했습니다. 다시 시도해주세요.';
      }
    }
    if (e is PlatformException) {
      if (e.code == 'network_error') {
        return '네트워크 연결을 확인해주세요.';
      }
      return '로그인 중 문제가 발생했습니다. 다시 시도해주세요.';
    }
    return '로그인 중 문제가 발생했습니다. 다시 시도해주세요.';
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
