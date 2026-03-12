import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../core/config/supabase_config.dart';

/// Uploads portfolio media (images/videos) and profile photos via Supabase Edge Function.
/// The Edge Function verifies the Firebase token and uploads to Storage.
class PortfolioStorageDataSource {
  PortfolioStorageDataSource({String? functionUrl})
      : _functionUrl =
            functionUrl ??
            '${SupabaseConfig.url}/functions/v1/portfolio-upload';

  final String _functionUrl;

  /// Uploads a file and returns its public download URL.
  /// [userId] is the creative user's ID (used client-side for display only;
  /// the Edge Function extracts uid from the token).
  Future<String> uploadPortfolioMedia(
    XFile file,
    String userId, {
    required bool isVideo,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final bytes = await file.readAsBytes();
    final fileName = file.name.isNotEmpty ? file.name : 'upload';
    final request = http.MultipartRequest('POST', Uri.parse(_functionUrl))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['isVideo'] = isVideo.toString()
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception(
        body.isNotEmpty ? body : 'Upload failed: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final url = json['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('No URL in response');
    }
    return url;
  }

  /// Uploads a profile photo and returns its public URL.
  /// Path: users/{uid}/profile/avatar.{ext} (overwrites previous).
  Future<String> uploadProfilePhoto(XFile file, String userId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final bytes = await file.readAsBytes();
    final fileName = file.name.isNotEmpty ? file.name : 'avatar.jpg';
    final request = http.MultipartRequest('POST', Uri.parse(_functionUrl))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['type'] = 'profile'
      ..fields['isVideo'] = 'false'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception(
        body.isNotEmpty ? body : 'Upload failed: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final url = json['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('No URL in response');
    }
    return url;
  }
}
