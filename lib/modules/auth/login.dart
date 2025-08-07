// =================================================================
// 📁 ARQUIVO: lib/modules/auth/views/login_page.dart
// =================================================================
// 🔐 Tela de Login com layout responsivo.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotPasswordEmailController = TextEditingController();
  bool _rememberMe = false;

  void _login() {
    // TODO: Implementar lógica de autenticação com Firebase
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  void _signInWithGoogle() {
    // TODO: Implementar lógica de autenticação com google_sign_in e Firebase
    print('Login com Google clicado!');
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar Senha'),
          content: TextField(
            controller: _forgotPasswordEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Digite seu email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar lógica de envio de email de recuperação
                Navigator.of(context).pop();
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  // Widget que constrói o painel da imagem para telas grandes
  Widget _buildImagePanel() {
    // Usamos Center para centralizar o conteúdo dentro do espaço disponível.
    return Center(
      // Adicionamos padding para criar um respiro nas bordas.
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: ClipRRect(
          // ClipRRect para aplicar bordas arredondadas à imagem, combinando com o design.
          borderRadius: BorderRadius.circular(24.0),
          child: ConstrainedBox(
            // Limitamos o tamanho máximo da imagem para que ela não ocupe todo o espaço.
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 700,
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 40.0), // Aumenta o padding
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400), // Limita a largura do formulário
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  // Define a forma do container como um círculo perfeito.
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    // IMPORTANTE: Garante que a imagem inteira apareça dentro do círculo
                    // sem ser cortada ou deformada.
                    fit: BoxFit.contain,
                    
                    // Lembre-se de usar o caminho completo do asset, ex: 'assets/logo.png'
                    image: AssetImage('logo.png'), 
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Bem-vindo', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock_outline))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v ?? false)), const Text('Lembrar-me')]),
                  TextButton(onPressed: _showForgotPasswordDialog, child: const Text('Esqueci a senha')),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _login, child: const Text('Entrar')),
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
                TextButton(onPressed: () { /* TODO: Navegar para registro */ }, child: const Text('Crie um perfil')),
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
            // O LayoutBuilder verifica o tamanho da tela e decide qual layout mostrar
            LayoutBuilder(
              builder: (context, constraints) {
                // Define um ponto de quebra. Se a tela for maior que 900 pixels, mostra o layout de duas colunas.
                if (constraints.maxWidth > 900) {
                  return Row(
                    children: [
                      // Metade esquerda: Formulário de Login
                      Expanded(
                        flex: 1,
                        child: _buildLoginForm(),
                      ),
                      // Metade direita: Imagem
                      Expanded(
                        flex: 1,
                        child: _buildImagePanel(),
                      ),
                    ],
                  );
                } else {
                  // Para telas menores, mostra apenas o formulário de login centralizado.
                  return _buildLoginForm();
                }
              },
            ),
            // Ícone "Sobre" continua posicionado no canto superior direito
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
