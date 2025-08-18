// =================================================================
// 📁 ARQUIVO: lib/modules/user/user_editor.dart
// =================================================================
// 📝 Tela final e completa para gestão de perfis, com todas as funcionalidades.

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes.dart';
import '../../../models/family_member_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../services/storage_service.dart';

class UserEditorPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const UserEditorPage({super.key, this.arguments});

  @override
  State<UserEditorPage> createState() => _UserEditorPageState();
}

class _UserEditorPageState extends State<UserEditorPage> {
  // Controladores, Estado e Serviços
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _transitioningToController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isRegisteringNewAdmin = false;
  bool _isEditingAdmin = false;
  bool _isFamilyMember = false;
  FamilyMember? _editingMember;
  String? _gender;
  String? _activityLevel;
  String? _goal;
  final Map<String, bool> _conditions = {'Intolerância à Lactose': false, 'Gastrite': false, 'Veganismo': false, 'Celíaco': false, 'Diabetes': false, 'Hipertenso': false};
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;
  String? _selectedRelationship;
  final List<String> _relationships = ['Cônjuge', 'Filho(a)', 'Pai', 'Mãe', 'Outro'];
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  XFile? _selectedImageFile;
  String? _existingImageUrl;

  // Calcula a idade atual com base na data de nascimento selecionada
  int? get _currentAge {
    if (_selectedDate == null) return null;
    final now = DateTime.now();
    int age = now.year - _selectedDate!.year;
    if (now.month < _selectedDate!.month || (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) {
      age--;
    }
    return age;
  }

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
        _gender = member.gender;
        _transitioningToController.text = member.transitioningTo ?? '';
        _activityLevel = member.activityLevel;
        _goal = member.goal;
        _existingImageUrl = member.imageUrl;
        for (var condition in member.conditions ?? []) {
          if (_conditions.containsKey(condition)) _conditions[condition] = true;
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
            _gender = appUser.gender;
            _transitioningToController.text = appUser.transitioningTo ?? '';
            _activityLevel = appUser.activityLevel;
            _goal = appUser.goal;
            _existingImageUrl = appUser.imageUrl;
            for (var condition in appUser.conditions ?? []) {
              if (_conditions.containsKey(condition)) _conditions[condition] = true;
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
    _transitioningToController.dispose();
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

  Future<void> _pickImage() async {
    final image = await _storageService.pickImage();
    if (image != null) {
      setState(() => _selectedImageFile = image);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final currentUser = FirebaseAuth.instance.currentUser;
    String? finalImageUrl = _existingImageUrl;

    final selectedConditions = _conditions.entries.where((e) => e.value).map((e) => e.key).toList();

    try {
      if (_selectedImageFile != null && currentUser != null) {
        final profileId = _isFamilyMember ? (_editingMember?.id ?? 'member_${DateTime.now().millisecondsSinceEpoch}') : currentUser.uid;
        finalImageUrl = await _storageService.uploadProfilePicture(
          adminId: currentUser.uid,
          profileId: profileId,
          file: _selectedImageFile!,
        );
      }

      if (_isRegisteringNewAdmin) {
        User? user = await _authService.registerWithEmailAndPassword(_emailController.text.trim(), _passwordController.text.trim());
        if (user != null) {
          await DatabaseService(uid: user.uid).updateUserData(_nameController.text.trim(), _emailController.text.trim());
          if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.verifyEmail, (route) => false);
        }
      } else if (_isFamilyMember) {
        if (currentUser == null) throw ('Utilizador não autenticado.');
        final member = FamilyMember(
          id: _editingMember?.id ?? 'new',
          name: _nameController.text.trim(),
          relationship: _selectedRelationship!,
          imageUrl: finalImageUrl,
          weight: double.tryParse(_weightController.text),
          height: double.tryParse(_heightController.text),
          birthDate: _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
          gender: _gender,
          transitioningTo: _gender == 'Intersexo' ? _transitioningToController.text.trim() : null,
          activityLevel: _activityLevel,
          goal: _goal,
          conditions: selectedConditions,
        );
        await DatabaseService(uid: currentUser.uid).upsertFamilyMember(member);
        if (mounted) Navigator.of(context).pop();
      } else if (_isEditingAdmin) {
        if (currentUser == null) throw ('Utilizador não autenticado.');
        await DatabaseService(uid: currentUser.uid).updateAdminProfile(
          name: _nameController.text.trim(),
          imageUrl: finalImageUrl,
          weight: double.tryParse(_weightController.text),
          height: double.tryParse(_heightController.text),
          birthDate: _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
          gender: _gender,
          transitioningTo: _gender == 'Intersexo' ? _transitioningToController.text.trim() : null,
          activityLevel: _activityLevel,
          goal: _goal,
          conditions: selectedConditions,
        );
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_authService.getErrorMessage(e)), backgroundColor: Colors.red));
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
        lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate) {
      // Calcula a idade com base na data escolhida
      final now = DateTime.now();
      int age = now.year - picked.year;
      if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) {
        age--;
      }

      // Valida a idade mínima de 3 anos
      if (age < 3) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Atenção: Idade Mínima'),
              content: const Text(
                  'Perfis com menos de 3 anos não são incluídos nos cálculos nutricionais familiares. Para esta faixa etária, recomendamos que procure orientação de um pediatra ou nutricionista para uma introdução alimentar adequada.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        // Se a idade for válida, atualiza o estado
        setState(() {
          final oldAge = _currentAge;
          _selectedDate = picked;
          _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
          final newAge = _currentAge;

          if ((oldAge ?? 10) >= 10 && (newAge ?? 0) < 10 ||
              (oldAge ?? 0) < 10 && (newAge ?? 10) >= 10) {
            _activityLevel = null;
          }
        });
      }
    }
  }

  // Função que retorna a lista de opções de atividade física com base na idade.
  List<DropdownMenuItem<String>> _getActivityLevelItems() {
    final age = _currentAge;
    // Se a idade for menor que 10, mostra as opções para crianças.
    if (age != null && age < 10) {
      return [
        _buildTooltipDropdownItem('Sedentário', 'Apenas as atividades leves da vida cotidiana (ir à escola, fazer lição de casa, etc.).'),
        _buildTooltipDropdownItem('Pouco Ativo', 'Atividades cotidianas + o equivalente a caminhar por 30-60 minutos em ritmo moderado.'),
        _buildTooltipDropdownItem('Ativo', 'Atividades cotidianas + o equivalente a caminhar por pelo menos 60 minutos em ritmo moderado.'),
        _buildTooltipDropdownItem('Muito Ativo', 'Atividades cotidianas + pelo menos 60 minutos de atividade moderada + 60 minutos de atividade vigorosa.'),
      ];
    } 
    // Caso contrário (idade >= 10 ou sem data de nascimento), mostra as opções padrão.
    else {
      return [
        _buildTooltipDropdownItem('Sedentário', 'Pouco ou nenhum exercício.'),
        _buildTooltipDropdownItem('Levemente Ativo', 'Exercício leve 1-3 dias/semana.'),
        _buildTooltipDropdownItem('Moderado', 'Exercício moderado 3-5 dias/semana.'),
        _buildTooltipDropdownItem('Ativo', 'Exercício intenso 6-7 dias/semana.'),
        _buildTooltipDropdownItem('Extremamente Ativo', 'Exercício muito intenso e trabalho físico.'),
      ];
    }
  }

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
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _selectedImageFile != null
                            ? (kIsWeb ? NetworkImage(_selectedImageFile!.path) : FileImage(File(_selectedImageFile!.path))) as ImageProvider
                            : (_existingImageUrl != null ? NetworkImage(_existingImageUrl!) : null),
                        child: _selectedImageFile == null && _existingImageUrl == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Alterar Foto'),
                    ),
                    const SizedBox(height: 24),
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

                    if (!_isRegisteringNewAdmin) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('Informações de Saúde', style: Theme.of(context).textTheme.titleLarge),
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
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(labelText: 'Sexo', prefixIcon: Icon(Icons.wc)),
                        items: ['Masculino', 'Feminino', 'Intersexo'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                        onChanged: (newValue) => setState(() => _gender = newValue),
                      ),
                      if (_gender == 'Intersexo') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _transitioningToController,
                          decoration: const InputDecoration(labelText: 'Transicionando para (opcional)', prefixIcon: Icon(Icons.transgender)),
                        ),
                      ],
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _activityLevel,
                        decoration: const InputDecoration(labelText: 'Nível de Atividade Física', prefixIcon: Icon(Icons.fitness_center)),
                        items: _getActivityLevelItems(),
                        onChanged: (newValue) => setState(() => _activityLevel = newValue),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _goal,
                        decoration: const InputDecoration(labelText: 'Meta de Peso', prefixIcon: Icon(Icons.flag_outlined)),
                        items: ['Manter Peso', 'Aumentar Peso', 'Diminuir Peso'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                        onChanged: (newValue) => setState(() => _goal = newValue),
                      ),
                      const SizedBox(height: 24),
                      Text('Condições e Alergias', style: Theme.of(context).textTheme.titleMedium),
                      ..._conditions.keys.map((String key) {
                        return CheckboxListTile(
                          title: Text(key),
                          value: _conditions[key],
                          onChanged: (bool? value) => setState(() => _conditions[key] = value!),
                        );
                      }).toList(),
                    ],
                    
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
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildTooltipDropdownItem(String value, String tooltip) {
    return DropdownMenuItem<String>(
      value: value,
      child: Tooltip(
        message: tooltip,
        child: Text(value),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    String appBarTitle = 'Criar Perfil';
    if (_isEditingAdmin) appBarTitle = 'Editar Meu Perfil';
    if (_isFamilyMember) appBarTitle = _editingMember == null ? 'Adicionar Familiar' : 'Editar Familiar';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/dashboard_background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
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
        ],
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
