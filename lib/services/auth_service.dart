// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Регистрация с email и паролем
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception("Неизвестная ошибка: $e");
    }
  }

  // Вход с email и паролем
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception("Неизвестная ошибка: $e");
    }
  }

  // Выход из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Обработка ошибок FirebaseAuth
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception("Некорректный email.");
      case 'user-disabled':
        return Exception("Пользователь отключен.");
      case 'user-not-found':
        return Exception("Пользователь не найден.");
      case 'wrong-password':
        return Exception("Неверный пароль.");
      case 'email-already-in-use':
        return Exception("Email уже используется.");
      case 'operation-not-allowed':
        return Exception("Операция не разрешена.");
      case 'weak-password':
        return Exception("Пароль слишком слабый.");
      default:
        return Exception("Ошибка: ${e.message}");
    }
  }
}