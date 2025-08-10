// =================================================================
// 📁 ARQUIVO: lib/services/storage_service.dart
// =================================================================
// 🖼️ Serviço para gerir o upload e a exclusão de imagens.

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

  Future<String?> uploadProfilePicture({
    required String adminId,
    required String profileId,
    required XFile file,
  }) async {
    try {
      final ref = _storage.ref('profile_pictures').child(adminId).child(profileId).child('profile.jpg');
      
      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(await file.readAsBytes());
      } else {
        uploadTask = ref.putFile(File(file.path));
      }
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erro no upload da imagem: $e");
      return null;
    }
  }

  // NOVO MÉTODO: Exclui uma imagem do Storage usando a sua URL.
  Future<void> deleteImageByUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignora o erro se o ficheiro não for encontrado (pode já ter sido excluído)
      if (e is FirebaseException && e.code == 'object-not-found') {
        print("Ficheiro não encontrado no Storage, pode já ter sido excluído.");
      } else {
        print("Erro ao excluir imagem do Storage: $e");
      }
    }
  }
}
