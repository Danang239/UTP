import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileRepository {
  final _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  // ==========================
  // UPLOAD FOTO KE SUPABASE
  // ==========================
  Future<String?> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
  }) async {
    try {
      final path = 'profile_images/$userId.jpg';

      await _supabase.storage.from('profile').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Ambil public URL
      final baseUrl =
          _supabase.storage.from('profile').getPublicUrl(path);

      // Cache busting supaya foto langsung update
      final publicUrl =
          '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      return publicUrl;
    } catch (e) {
      throw Exception('Upload foto gagal: $e');
    }
  }

  // ==========================
  // UPDATE USER FIRESTORE
  // ==========================
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Update profil gagal: $e');
    }
  }
}
