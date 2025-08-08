// =================================================================
// 📁 ARQUIVO: lib/modules/user/user_editor.dart
// =================================================================
// 📝 Tela versátil para criar e editar perfis, com layout responsivo e validações.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

class UserEditorPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const UserEditorPage({super.key, this.arguments});

  @override
  State<UserEditorPage> createState() => _UserEditorPageState();
}

class _UserEditorPageState extends State<UserEditorPage> {
  // Controladores e Chaves
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // NOVOS CONTROLADORES PARA INFORMAÇÕES ADICIONAIS
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _birthDateController = TextEditingController();

  // Estado da UI
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Estado Lógico (controlado pelos argumentos da rota)
  bool _isRegisteringNewAdmin = false;
  bool _isEditingByAdmin = false;

  // Estado para Validação
  bool _isEmailValid = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;

  // Estado para o formulário de familiar
  bool _isFamilyMember = false;
  String? _selectedRelationship;
  final List<String> _relationships = ['Cônjuge', 'Filho(a)', 'Pai', 'Mãe', 'Outro'];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Define o modo da página com base nos argumentos recebidos
    _isRegisteringNewAdmin = widget.arguments?['isRegisteringNewAdmin'] ?? false;
    _isEditingByAdmin = !_isRegisteringNewAdmin;
    _isFamilyMember = widget.arguments?['isFamilyMember'] ?? false;
    
    // Adiciona listeners para validação em tempo real
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);

    // TODO: Se estiver editando, preencher os campos com os dados do usuário
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Funções de Validação em Tempo Real
  void _validateEmail() {
    final email = _emailController.text;
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (isValid != _isEmailValid) {
      setState(() => _isEmailValid = isValid);
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 8;
    });
  }

  // Função para salvar o perfil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isRegisteringNewAdmin) {
        User? user = await _authService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (user != null) {
          await DatabaseService(uid: user.uid).updateUserData(
            _nameController.text.trim(),
            _emailController.text.trim(),
          );
          if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.verifyEmail, (route) => false);
        }
      } else {
        // TODO: Implementar lógica de adição/edição de familiar, incluindo os novos campos
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authService.getErrorMessage(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Widgets de Construção da UI ---

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
                  image: AssetImage('assets/perfil.png'), // Use uma imagem para o cadastro
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormPanel() {
    String title = _isRegisteringNewAdmin ? 'Crie seu Perfil' : (_isEditingByAdmin && _isFamilyMember ? 'Adicionar Familiar' : 'Editar Perfil');
    String buttonText = _isRegisteringNewAdmin ? 'Criar Conta' : (_isEditingByAdmin && _isFamilyMember ? 'Adicionar Familiar' : 'Salvar Alterações');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 32),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome Completo', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: _emailController.text.isEmpty ? null : Icon(_isEmailValid ? Icons.check_circle : Icons.cancel, color: _isEmailValid ? Colors.green : Colors.red),
                  ),
                  validator: (v) => (v != null && v.isNotEmpty && !_isEmailValid) ? 'Por favor, insira um e-mail válido.' : null,
                ),
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
                const SizedBox(height: 16),
                // Indicador de Força da Senha
                _PasswordRequirement(label: 'Pelo menos 8 caracteres', isValid: _hasMinLength),
                _PasswordRequirement(label: 'Uma letra maiúscula (A-Z)', isValid: _hasUppercase),
                _PasswordRequirement(label: 'Uma letra minúscula (a-z)', isValid: _hasLowercase),
                _PasswordRequirement(label: 'Um número (0-9)', isValid: _hasNumber),
                _PasswordRequirement(label: 'Um caractere especial (!@#\$...)', isValid: _hasSpecialChar),
                
                // Seção para adicionar familiar e informações adicionais (visível apenas para admin)
                if (_isEditingByAdmin) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Informações Adicionais', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso (kg)', prefixIcon: Icon(Icons.monitor_weight_outlined)))),
                      const SizedBox(width: 16),
                      Expanded(child: TextFormField(controller: _heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Altura (cm)', prefixIcon: Icon(Icons.height_outlined)))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _birthDateController, keyboardType: TextInputType.datetime, decoration: const InputDecoration(labelText: 'Data de Nascimento (DD/MM/AAAA)', prefixIcon: Icon(Icons.cake_outlined))),
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    title: const Text('Este perfil é de um familiar?'),
                    value: _isFamilyMember,
                    onChanged: (value) => setState(() => _isFamilyMember = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_isFamilyMember)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedRelationship,
                        decoration: const InputDecoration(labelText: 'Grau de Parentesco', prefixIcon: Icon(Icons.family_restroom_outlined)),
                        items: _relationships.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                        onChanged: (newValue) => setState(() => _selectedRelationship = newValue),
                      ),
                    ),
                ],
                
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text(buttonText),
                  ),

                // Link para voltar ao login (visível apenas no primeiro acesso)
                if (_isRegisteringNewAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Já tem uma conta?'),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
                          child: const Text('Faça o login'),
                        ),
                      ],
                    ),
                  ),

                // Botões de Cancelar e Excluir (visíveis apenas para admin)
                if (_isEditingByAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                      // TODO: Adicionar lógica de exclusão
                      TextButton(onPressed: () {}, child: Text('Excluir Perfil', style: TextStyle(color: Colors.red.shade400))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                children: [
                  Expanded(flex: 1, child: _buildFormPanel()),
                  Expanded(flex: 1, child: _buildImagePanel()),
                ],
              );
            } else {
              return _buildFormPanel();
            }
          },
        ),
      ),
    );
  }
}

// Widget auxiliar para mostrar os requisitos da senha
class _PasswordRequirement extends StatelessWidget {
  final String label;
  final bool isValid;
  const _PasswordRequirement({required this.label, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle : Icons.cancel, color: isValid ? Colors.green : Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isValid ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}
