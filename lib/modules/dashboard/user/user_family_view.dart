// =================================================================
// 📁 ARQUIVO: lib/modules/user/user_family_view.dart
// =================================================================
// 👨‍👩‍👧‍👦 Tela final e completa para visualizar a família em grelha de cards.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/routes.dart';
import '../../../models/dri_model.dart';
import '../../../models/family_member_model.dart';
import '../../../models/user_model.dart';
import '../../../services/database_service.dart';
import '../../../services/nutrition_service.dart';

class UserFamilyViewPage extends StatefulWidget {
  const UserFamilyViewPage({super.key});

  @override
  State<UserFamilyViewPage> createState() => _UserFamilyViewPageState();
}

class _UserFamilyViewPageState extends State<UserFamilyViewPage> {
  late final DatabaseService _dbService;
  final NutritionService _nutritionService = NutritionService();
  Future<AppUser?>? _adminUserFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbService = DatabaseService(uid: user.uid);
      _loadAdminData();
    }
  }

  void _loadAdminData() {
    setState(() {
      _adminUserFuture = _dbService.getUserData();
    });
  }

  void _showProfileDetails(BuildContext context, {AppUser? admin, FamilyMember? member}) {
    final name = admin?.name ?? member?.name;
    final relationship = admin != null ? 'Administrador' : member?.relationship;
    
    final canCalculateDRI = (admin?.weight != null && admin?.height != null && admin?.birthDate != null && admin?.gender != null && admin?.activityLevel != null && admin?.goal != null) ||
                              (member?.weight != null && member?.height != null && member?.birthDate != null && member?.gender != null && member?.activityLevel != null && member?.goal != null);

    DietaryReferenceIntake? dri;
    if (canCalculateDRI) {
      dri = _nutritionService.calculateDRIs(
        weight: admin?.weight ?? member!.weight!,
        height: admin?.height ?? member!.height!,
        birthDate: admin?.birthDate?.toDate() ?? member!.birthDate!.toDate(),
        gender: admin?.gender ?? member!.gender!,
        activityLevel: admin?.activityLevel ?? member!.activityLevel!,
        goal: admin?.goal ?? member!.goal!,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name ?? 'Perfil', style: Theme.of(context).textTheme.headlineSmall),
              Text(relationship ?? '', style: TextStyle(color: Colors.grey.shade600)),
              const Divider(height: 32),
              
              if (dri != null)
                _buildDriDisplay(dri)
              else
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Preencha todas as informações de saúde no perfil para ver as metas de ingestão.'),
                )),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Fechar')),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushNamed(
                        AppRoutes.userEditor,
                        arguments: admin != null ? {'isFamilyMember': false} : {'isFamilyMember': true, 'memberData': member},
                      ).then((_) => _loadAdminData());
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
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                
                final familyMembers = snapshot.data ?? [];

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
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
                                  if (!adminSnapshot.hasData) return const Card();
                                  return _buildAdminCard(context, adminSnapshot.data!);
                                },
                              );
                            }
                            final member = familyMembers[index - 1];
                            return _buildFamilyMemberCard(context, member);
                          },
                          childCount: 1 + familyMembers.length,
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildAdminCard(BuildContext context, AppUser admin) {
    return Card(
      child: InkWell(
        onTap: () => _showProfileDetails(context, admin: admin),
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
        onTap: () => _showProfileDetails(context, member: member),
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

  // =================================================================
  // 🔧 WIDGET ATUALIZADO
  // =================================================================
  Widget _buildDriDisplay(DietaryReferenceIntake dri) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metas Diárias de Ingestão', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildNutrientRow('Valor energético', dri.calories, 'kcal'),
        const Divider(),
        _buildNutrientRow('Carboidratos', dri.carbsGrams, 'g'),
        _buildNutrientRow('Açúcares totais', dri.totalSugarsGrams, 'g', isSubItem: true),
        _buildNutrientRow('Açúcares adicionados', dri.addedSugarsGrams, 'g', isSubItem: true),
        const Divider(),
        _buildNutrientRow('Proteínas', dri.proteinGrams, 'g'),
        const Divider(),
        _buildNutrientRow('Gorduras totais', dri.fatGrams, 'g'),
        _buildNutrientRow('Gorduras saturadas', dri.saturatedFatsGrams, 'g', isSubItem: true),
        _buildNutrientRow('Gorduras trans', dri.transFatsGrams, 'g', isSubItem: true),
        const Divider(),
        _buildNutrientRow('Fibra alimentar', dri.fiberGrams, 'g'),
        const Divider(),
        _buildNutrientRow('Sódio', dri.sodiumMg, 'mg'),
      ],
    );
  }

  // =================================================================
  // ✨ NOVO WIDGET AUXILIAR
  // =================================================================
  Widget _buildNutrientRow(String label, double value, String unit, {bool isSubItem = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isSubItem ? 16.0 : 0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isSubItem ? 14 : 16)),
          Text(
            '${value.toStringAsFixed(unit == 'kcal' ? 0 : 1)} $unit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSubItem ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
