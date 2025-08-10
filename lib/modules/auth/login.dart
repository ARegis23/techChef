// =================================================================
// 📁 ARQUIVO: lib/modules/auth/views/login_page.dart
// =================================================================
// 🔐 Tela de Login com layout responsivo e lógica de autenticação completa.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores e estado
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotPasswordEmailController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;

  // Função para realizar o login com e-mail e senha
  Future<void> _login() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authService.getErrorMessage(e)), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Função para login com Google (lógica local)
  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return; // Usuário cancelou
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final dbService = DatabaseService(uid: user.uid);
        final userData = await dbService.getUserData();
        if (userData == null) {
          await dbService.updateUserData(
            user.displayName ?? 'Usuário Google',
            user.email ?? '',
          );
        }
        if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no login com Google: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  // Função para mostrar o diálogo de recuperação de senha
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Usamos um StatefulBuilder para gerir o estado de carregamento dentro do diálogo
        bool isDialogLoading = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Recuperar Senha'),
              content: TextField(
                controller: _forgotPasswordEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Digite seu e-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDialogLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isDialogLoading ? null : () async {
                    if (_forgotPasswordEmailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, insira um e-mail.'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    setDialogState(() => isDialogLoading = true);
                    try {
                      await _authService.sendPasswordResetEmail(_forgotPasswordEmailController.text.trim());
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('E-mail de recuperação enviado com sucesso!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_authService.getErrorMessage(e)), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                       if (mounted) {
                         setDialogState(() => isDialogLoading = false);
                       }
                    }
                  },
                  child: isDialogLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget que constrói o painel da imagem para telas grandes
  Widget _buildImagePanel() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/login_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget que constrói o formulário de login
  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/logo.png'), 
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Bem-vindo', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
              const SizedBox(height: 16),
              const Text('Versão 1.0.1.06.8.25', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey),),
              ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
              const SizedBox(height: 40),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v ?? false)), const Text('Lembrar-me')]),
                  TextButton(onPressed: _showForgotPasswordDialog, child: const Text('Esqueci a senha')),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Entrar'),
                ),
              const SizedBox(height: 24),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('OU')), Expanded(child: Divider())]),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: SvgPicture.asset('assets/google_logo.svg', height: 24.0),
                label: const Text('Entrar com Google'),
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 2),
              ),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Primeiro acesso?'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.userEditor,
                      arguments: {'isRegisteringNewAdmin': true},
                    );
                  },
                  child: const Text('Crie um perfil'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    children: [
                      Expanded(flex: 1, child: _buildLoginForm()),
                      Expanded(flex: 1, child: _buildImagePanel()),
                    ],
                  );
                } else {
                  return _buildLoginForm();
                }
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.about),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
