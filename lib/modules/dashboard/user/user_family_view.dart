// =================================================================
// 📁 ARQUIVO: lib/modules/user/user_family_view.dart
// =================================================================
// 👨‍👩‍👧‍👦 Tela redesenhada para visualizar a família em grelha de cards.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../core/routes.dart';
import '../../../models/family_member_model.dart';
import '../../../models/user_model.dart';
import '../../../services/database_service.dart';

class UserFamilyViewPage extends StatefulWidget {
  const UserFamilyViewPage({super.key});

  @override
  State<UserFamilyViewPage> createState() => _UserFamilyViewPageState();
}

class _UserFamilyViewPageState extends State<UserFamilyViewPage> {
  late final DatabaseService _dbService;
  Future<AppUser?>? _adminUserFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbService = DatabaseService(uid: user.uid);
      _loadAdminData(); // Carrega os dados do admin pela primeira vez
    }
  }

  // CORREÇÃO: Função para carregar/recarregar os dados do admin
  void _loadAdminData() {
    setState(() {
      _adminUserFuture = _dbService.getUserData();
    });
  }

  void _showMemberDetails(BuildContext context, FamilyMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: StreamBuilder<List<FamilyMember>>(
                    stream: _dbService.familyStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                      }
                      if (snapshot.hasError) {
                        return SliverFillRemaining(child: Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white))));
                      }
                      
                      final familyMembers = snapshot.data ?? [];

                      return SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 3 / 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == 0) {
                              return FutureBuilder<AppUser?>(
                                future: _adminUserFuture,
                                builder: (context, adminSnapshot) {
                                  if (!adminSnapshot.hasData) return const Card(); // Placeholder
                                  return _buildAdminCard(context, adminSnapshot.data!);
                                },
                              );
                            }
                            final member = familyMembers[index - 1];
                            return _buildFamilyMemberCard(context, member);
                          },
                          childCount: 1 + familyMembers.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  Widget _buildAdminCard(BuildContext context, AppUser admin) {
    return Card(
      child: InkWell(
        // CORREÇÃO: Ao navegar para editar, usamos .then() para recarregar os dados no retorno.
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.userEditor,
          arguments: {'isFamilyMember': false},
        ).then((_) => _loadAdminData()), // Recarrega os dados do admin quando voltamos
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  image: admin.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(admin.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: admin.imageUrl == null
                    ? const Center(child: Icon(Icons.shield, size: 60, color: Colors.white))
                    : null,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(admin.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('Administrador', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  image: member.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(member.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: member.imageUrl == null
                    ? const Center(child: Icon(Icons.person, size: 60, color: Colors.white))
                    : null,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
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
