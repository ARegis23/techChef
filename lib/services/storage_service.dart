// =================================================================
// 📁 ARQUIVO: lib/services/storage_service.dart
// =================================================================
// 🖼️ Serviço para gerir o upload de imagens, agora compatível com a Web.

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    } catch (e) {
      print("Erro ao escolher imagem: $e");
      return null;
    }
  }

  // Função de upload atualizada para a nova estrutura de pastas
  Future<String?> uploadProfilePicture({
    required String adminId,
    required String profileId,
    required XFile file,
  }) async {
    try {
      // O caminho agora é: profile_pictures/ID_DO_ADMIN/ID_DO_PERFIL/profile.jpg
      final ref = _storage.ref('profile_pictures').child(adminId).child(profileId).child('profile.jpg');
      
      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(await file.readAsBytes());
      } else {
        uploadTask = ref.putFile(File(file.path));
      }
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Erro no upload da imagem: $e");
      return null;
    }
  }
}
