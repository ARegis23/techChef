// =================================================================
// 📁 ARQUIVO: lib/services/auth_service.dart
// =================================================================
// 🔑 Serviço para gerenciar a lógica de autenticação com Firebase.

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de mudanças de autenticação
  Stream<User?> get user => _auth.authStateChanges();

  // Mensagens de erro personalizadas
  String getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found': return 'Usuário não encontrado.';
        case 'wrong-password': return 'Senha incorreta.';
        case 'email-already-in-use': return 'Esse e-mail já está em uso.';
        case 'invalid-email': return 'E-mail inválido.';
        case 'weak-password': return 'A senha é muito fraca.';
        case 'too-many-requests': return 'Muitas tentativas. Tente novamente mais tarde.';
        default: return 'Erro: ${e.message}';
      }
    }
    return 'Erro inesperado. Tente novamente.';
  }

  // 🔐 Login com e-mail e senha
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!result.user!.emailVerified) {
        throw FirebaseAuthException(code: 'email-not-verified', message: 'Por favor, verifique seu e-mail antes de fazer login.');
      }
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // 🆕 Registro com e-mail e senha
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await result.user?.sendEmailVerification();
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // 🚪 Logout
  Future<void> signOut() async {
    // Como o GoogleSignIn será local da LoginPage, não precisamos chamá-lo aqui.
    // A LoginPage cuidará disso.
    await _auth.signOut();
  }

  // 📩 Verifica se e-mail foi confirmado
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // 🔄 Atualiza o usuário para garantir verificação mais recente
  Future<void> refreshUser() async {
    await _auth.currentUser?.reload();
  }
}
