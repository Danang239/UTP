import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class VillaRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ⚠️ SESUAIKAN jika backend beda host
  static const String _baseUrl = 'http://localhost:3000';

  // =====================================================
  // UPLOAD FOTO / VIDEO VILLA (KE BACKEND → SUPABASE)
  // =====================================================
  Future<String> uploadVillaImage({
    required String ownerId,
    required String villaId,
    Uint8List? bytes, // WEB
    File? file, // MOBILE
  }) async {
    final uri = Uri.parse('$_baseUrl/upload/villa');

    final request = http.MultipartRequest('POST', uri)
      ..fields['ownerId'] = ownerId
      ..fields['villaId'] = villaId;

    if (kIsWeb) {
      if (bytes == null) {
        throw Exception('Image bytes kosong (web)');
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: '$villaId.jpg',
        ),
      );
    } else {
      if (file == null) {
        throw Exception('File kosong (mobile)');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Upload villa gagal: $responseBody');
    }

    final json = jsonDecode(responseBody);
    return json['url'];
  }

  // =====================================================
  // CREATE VILLA
  // =====================================================
  Future<void> createVilla({
    required String villaId,
    required String ownerId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection('villas').doc(villaId).set({
      ...data,
      'owner_id': ownerId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // =====================================================
  // UPDATE VILLA
  // =====================================================
  Future<void> updateVilla({
    required String villaId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection('villas').doc(villaId).update({
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // =====================================================
  // DELETE VILLA
  // =====================================================
  Future<void> deleteVilla(String villaId) async {
    await _db.collection('villas').doc(villaId).delete();
  }
}
