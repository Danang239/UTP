import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileRepository {
  final _db = FirebaseFirestore.instance;

  /// Upload foto ke Supabase
  Future<String?> uploadProfileImage(String userId, Uint8List bytes) async {
    final storage = Supabase.instance.client.storage;

    final path = "profile_images/$userId.jpg";

    await storage.from('profile').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: "image/jpeg",
          ),
        );

    return storage.from('profile').getPublicUrl(path);
  }

  /// Update Firestore
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection('users').doc(userId).update(data);
  }
}
