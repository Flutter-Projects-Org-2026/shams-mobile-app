import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static final _storage = Supabase.instance.client.storage;

  /// Uploads [file] to [bucket]/[path] and returns the public URL.
  static Future<String> uploadImage({
    required String bucket,
    required String path,
    required File file,
  }) async {
    await _storage.from(bucket).upload(
      path,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    return _storage.from(bucket).getPublicUrl(path);
  }

  /// Deletes a file from storage.
  static Future<void> deleteImage({
    required String bucket,
    required String path,
  }) async {
    await _storage.from(bucket).remove([path]);
  }
}
