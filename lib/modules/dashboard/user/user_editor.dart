// =================================================================
// 📁 ARQUIVO: lib/modules/user/user_editor.dart
// =================================================================
// 📝 Tela inteligente para criar e editar perfis, agora com AppBar.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/routes.dart';
import '../../../models/family_member_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

class UserEditorPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const UserEditorPage({super.key, this.arguments});

  @override
  State<UserEditorPage> createState() => _UserEditorPageState();
}

class _UserEditorPageState extends State<UserEditorPage> {
  // ... (todo o código de estado e lógica permanece o mesmo)
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _birthDateController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isRegisteringNewAdmin = false;
  bool _isEditingAdmin = false;
  bool _isFamilyMember = false;
  FamilyMember? _editingMember;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;
  String? _selectedRelationship;
  final List<String> _relationships = ['Cônjuge', 'Filho(a)', 'Pai', 'Mãe', 'Outro'];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _determineModeAndLoadData();
    _passwordController.addListener(_validatePassword);
  }

  Future<void> _determineModeAndLoadData() async {
    final args = widget.arguments;
    if (args == null || args['isRegisteringNewAdmin'] == true) {
      setState(() => _isRegisteringNewAdmin = true);
      return;
    }

    if (args['memberData'] != null) {
      final member = args['memberData'] as FamilyMember;
      setState(() {
        _isFamilyMember = true;
        _editingMember = member;
        _nameController.text = member.name;
        _selectedRelationship = member.relationship;
        _weightController.text = member.weight?.toString() ?? '';
        _heightController.text = member.height?.toString() ?? '';
        if (member.birthDate != null) {
          _selectedDate = member.birthDate!.toDate();
          _birthDateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        }
      });
    } else if (args['isFamilyMember'] == true) {
      setState(() => _isFamilyMember = true);
    } else {
      setState(() => _isEditingAdmin = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final appUser = await DatabaseService(uid: user.uid).getUserData();
        if (appUser != null && mounted) {
          setState(() {
            _nameController.text = appUser.name;
            _emailController.text = appUser.email;
            _weightController.text = appUser.weight?.toString() ?? '';
            _heightController.text = appUser.height?.toString() ?? '';
            if (appUser.birthDate != null) {
              _selectedDate = appUser.birthDate!.toDate();
              _birthDateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
            }
          });
        }
      }
    }
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final currentUser = FirebaseAuth.instance.currentUser;

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
      } else if (_isFamilyMember) {
        if (currentUser == null) throw('Utilizador não autenticado.');
        
        final member = FamilyMember(
          id: _editingMember?.id ?? 'new',
          name: _nameController.text.trim(),
          relationship: _selectedRelationship!,
          weight: double.tryParse(_weightController.text),
          height: double.tryParse(_heightController.text),
          birthDate: _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        );
        await DatabaseService(uid: currentUser.uid).upsertFamilyMember(member);
        if (mounted) Navigator.of(context).pop();

      } else if (_isEditingAdmin) {
        if (currentUser == null) throw('Utilizador não autenticado.');
        await DatabaseService(uid: currentUser.uid).updateAdminProfile(
          name: _nameController.text.trim(),
          weight: double.tryParse(_weightController.text),
          height: double.tryParse(_heightController.text),
          birthDate: _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        );
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
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
                  image: AssetImage('assets/perfil.png'),
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
    String title = 'Criar Perfil';
    if (_isEditingAdmin) title = 'Editar Meu Perfil';
    if (_isFamilyMember) title = _editingMember == null ? 'Adicionar Familiar' : 'Editar Familiar';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
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
                
                if (_isRegisteringNewAdmin || _isEditingAdmin) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    enabled: _isRegisteringNewAdmin,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: _isRegisteringNewAdmin ? 'Senha' : 'Nova Senha (opcional)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PasswordRequirement(label: 'Pelo menos 8 caracteres', isValid: _hasMinLength),
                  _PasswordRequirement(label: 'Uma letra maiúscula (A-Z)', isValid: _hasUppercase),
                  _PasswordRequirement(label: 'Uma letra minúscula (a-z)', isValid: _hasLowercase),
                  _PasswordRequirement(label: 'Um número (0-9)', isValid: _hasNumber),
                  _PasswordRequirement(label: 'Um caractere especial (!@#\$...)', isValid: _hasSpecialChar),
                ],

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
                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(labelText: 'Data de Nascimento', prefixIcon: Icon(Icons.cake_outlined)),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                
                if (_isFamilyMember) ...[
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedRelationship,
                    decoration: const InputDecoration(labelText: 'Grau de Parentesco', prefixIcon: Icon(Icons.family_restroom_outlined)),
                    items: _relationships.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                    onChanged: (newValue) => setState(() => _selectedRelationship = newValue),
                    validator: (v) => v == null ? 'Campo obrigatório' : null,
                  ),
                ],
                
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Salvar'),
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
    // Define o título da AppBar dinamicamente
    String appBarTitle = 'Criar Perfil';
    if (_isEditingAdmin) appBarTitle = 'Editar Meu Perfil';
    if (_isFamilyMember) appBarTitle = _editingMember == null ? 'Adicionar Familiar' : 'Editar Familiar';

    return Scaffold(
      // ADICIONA A APPBAR AQUI
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Permite que o fundo da imagem se estenda por trás da AppBar
      extendBodyBehindAppBar: true,
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
