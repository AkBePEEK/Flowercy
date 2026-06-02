import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowery_app/services/userService.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Регистрация пользователя
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async
  {
    try {
      // 1. Создаем пользователя в Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Сохраняем дополнительные данные в Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Произошла ошибка: ${e.toString()}',
      };
    }
  }

  // Вход пользователя
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async
  {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Произошла ошибка: ${e.toString()}',
      };
    }
  }

  Future<void> initGoogleSignIn() async {
    await GoogleSignIn.instance.initialize();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();

      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      final clientAuth = await googleUser.authorizationClient
          .authorizeScopes(['email', 'profile']);

      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
        accessToken: clientAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // ✅ Создаём пользователя в Firestore если он новый
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await UserService().createUser(
          email: userCredential.user?.email ?? '',
          name: userCredential.user?.displayName,
        );
      }

      return userCredential;

    } catch (e, stackTrace) {
      print('=== Google Sign-In ERROR ===');
      print('Type: ${e.runtimeType}');
      print('Message: $e');
      print('StackTrace: $stackTrace');
      print('============================');
      return null;
    }
  }
  // ─── Apple ────────────────────────────────────────────────
  String _generateNonce([int length = 32]) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // ✅ Создаём пользователя в Firestore если он новый
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final fullName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((s) => s != null).join(' ');

        await UserService().createUser(
          email: userCredential.user?.email ?? '',
          name: fullName.isNotEmpty ? fullName : null,
        );
      }

      return userCredential;
    } catch (e) {
      print('Apple Sign-In error: $e');
      return null;
    }
  }

  Future<void> signOutGoogle() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  // Выход
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Получение текущего пользователя
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Расшифровка ошибок
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'invalid-email':
        return 'Некорректный email';
      case 'operation-not-allowed':
        return 'Операция не разрешена';
      case 'weak-password':
        return 'Пароль слишком слабый (минимум 6 символов)';
      case 'user-disabled':
        return 'Пользователь заблокирован';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      default:
        return 'Произошла ошибка. Попробуйте позже';
    }
  }
}