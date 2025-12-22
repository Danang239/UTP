import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileRepository {
  final _db = FirebaseFirestore.instance;

  // ==========================
  // UPLOAD FOTO VIA BACKEND
  // ==========================
  Future<String> uploadProfileImage({
    required String userId,
    required String role,
    Uint8List? bytes,
    File? file,
  }) async {
    final uri = Uri.parse('http://localhost:3000/upload/profile');
    final request = http.MultipartRequest('POST', uri);

    request.fields['userId'] = userId;
    request.fields['role'] = role;

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes!,
          filename: '$userId.jpg',
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file!.path,
        ),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Upload gagal: $body');
    }

    final data = jsonDecode(body);
    return data['url'];
  }

  // ==========================
  // UPDATE FIRESTORE
  // ==========================
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection('users').doc(userId).update(data);
  }
}
