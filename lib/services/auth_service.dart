import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Регистрация пользователя
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
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
  }) async {
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