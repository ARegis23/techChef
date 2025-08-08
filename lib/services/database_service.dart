// =================================================================
// 📁 ARQUIVO: lib/services/database_service.dart
// =================================================================
// 🗄️ Serviço para gerenciar todas as operações com o banco de dados Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Referência para a coleção de usuários
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // Salva ou atualiza os dados do usuário
  Future<void> updateUserData(String name, String email, {String theme = 'system'}) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'themePreference': theme,
    });
  }
  
  // NOVO MÉTODO: Salva apenas a preferência de tema
  Future<void> updateUserThemePreference(String themePreference) async {
    if (uid == null) return;
    return await userCollection.doc(uid).update({
      'themePreference': themePreference,
    });
  }

  // Obtém os dados do usuário a partir do Firestore
  Future<AppUser?> getUserData() async {
    try {
      DocumentSnapshot doc = await userCollection.doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    } catch(e) {
      print(e);
      return null;
    }
  }
}
