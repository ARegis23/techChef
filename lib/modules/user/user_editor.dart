// =================================================================
// 📁 ARQUIVO: lib/modules/profile/views/user_editor.dart
// =================================================================
// 📝 Tela versátil para criar e editar perfis de administrador e familiares.

import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class UserEditorPage extends StatefulWidget {
  // Argumentos para determinar o modo da página:
  // - Criando um novo admin (vindo da tela de login)
  // - Adicionando um familiar (vindo do dashboard do admin)
  // - Editando um perfil existente
  final Map<String, dynamic>? arguments;

  const UserEditorPage({super.key, this.arguments});

  @override
  State<UserEditorPage> createState() => _UserEditorPageState();
}

class _UserEditorPageState extends State<UserEditorPage> {
  // Controladores para os campos do formulário
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Estado para os checkboxes e dropdown
  bool _isFamilyMember = false;
  String? _selectedRelationship;
  bool _isRegisteringNewAdmin = false;

  final List<String> _relationships = ['Cônjuge', 'Filho(a)', 'Pai', 'Mãe', 'Outro'];

  @override
  void initState() {
    super.initState();
    // Define o estado inicial da página com base nos argumentos recebidos
    _isRegisteringNewAdmin = widget.arguments?['isRegisteringNewAdmin'] ?? false;
    _isFamilyMember = widget.arguments?['isFamilyMember'] ?? false;

    // TODO: Se estiver editando, preencher os campos com os dados do usuário
  }

  void _saveProfile() {
    // TODO: Implementar a lógica de salvar os dados no Firebase
    
    if (_isRegisteringNewAdmin) {
      // Se for o primeiro cadastro, volta para a tela de login para o usuário entrar.
      // Usamos pushNamedAndRemoveUntil para limpar a pilha de navegação.
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } else {
      // Se estiver editando ou adicionando um familiar, apenas volta para a tela anterior.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisteringNewAdmin ? 'Criar Perfil de Administrador' : (_isFamilyMember ? 'Adicionar Familiar' : 'Editar Perfil')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campos comuns a todos os perfis
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome Completo')),
            const SizedBox(height: 16),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
            const SizedBox(height: 24),
            
            // Lógica para mostrar campos específicos
            if (_isRegisteringNewAdmin)
              const Text('Marque abaixo apenas se você for um familiar sendo adicionado por um administrador.'),

            // Checkbox para definir se é um familiar
            CheckboxListTile(
              title: const Text('Este perfil é de um familiar?'),
              value: _isFamilyMember,
              onChanged: (value) {
                setState(() {
                  _isFamilyMember = value ?? false;
                });
              },
            ),

            // Dropdown de parentesco, visível apenas se for um familiar
            if (_isFamilyMember)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedRelationship,
                  decoration: const InputDecoration(labelText: 'Grau de Parentesco'),
                  items: _relationships.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRelationship = newValue;
                    });
                  },
                ),
              ),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Salvar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
