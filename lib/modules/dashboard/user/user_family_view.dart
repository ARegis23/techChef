// =================================================================
// 📁 ARQUIVO: lib/modules/user/user_family_view.dart
// =================================================================
// 👨‍👩‍👧‍👦 Tela redesenhada para visualizar a família em grelha de cards.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/routes.dart';
import '../../../models/family_member_model.dart';
import '../../../services/database_service.dart';

class UserFamilyViewPage extends StatefulWidget {
  const UserFamilyViewPage({super.key});

  @override
  State<UserFamilyViewPage> createState() => _UserFamilyViewPageState();
}

class _UserFamilyViewPageState extends State<UserFamilyViewPage> {
  late final DatabaseService _dbService;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _dbService = DatabaseService(uid: user?.uid);
  }

  void _showMemberDetails(BuildContext context, FamilyMember member) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name, style: Theme.of(context).textTheme.headlineSmall),
              Text(member.relationship, style: TextStyle(color: Colors.grey.shade600)),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.monitor_weight_outlined),
                title: Text('Peso: ${member.weight?.toStringAsFixed(1) ?? 'N/A'} kg'),
              ),
              ListTile(
                leading: const Icon(Icons.height_outlined),
                title: Text('Altura: ${member.height?.toStringAsFixed(0) ?? 'N/A'} cm'),
              ),
              ListTile(
                leading: const Icon(Icons.cake_outlined),
                title: Text('Nascimento: ${member.birthDate != null ? DateFormat('dd/MM/yyyy').format(member.birthDate!.toDate()) : 'N/A'}'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                    onPressed: () {
                      Navigator.of(ctx).pop(); // Fecha o painel
                      Navigator.of(context).pushNamed(AppRoutes.userEditor, arguments: {
                        'isFamilyMember': true,
                        'memberData': member,
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Minha Família'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/dashboard_background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<List<FamilyMember>>(
              stream: _dbService.familyStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum familiar adicionado ainda.', style: TextStyle(color: Colors.white)));
                }
                final familyMembers = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: familyMembers.length,
                  itemBuilder: (context, index) {
                    final member = familyMembers[index];
                    return _buildFamilyMemberCard(context, member);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.userEditor, arguments: {'isFamilyMember': true, 'isRegisteringNewAdmin': false});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFamilyMemberCard(BuildContext context, FamilyMember member) {
    return Card(
      child: InkWell(
        onTap: () => _showMemberDetails(context, member),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey.shade300,
                // TODO: Substituir por uma imagem real (member.imageUrl)
                child: const Center(child: Icon(Icons.person, size: 60, color: Colors.white)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(member.relationship, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
