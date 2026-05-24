import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_service.dart';

class WorkshopService {
  static final _db = Supabase.instance.client;

  // ── CREATE ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createWorkshop({
    required String name,
    required String city,
    required String address,
    required String description,
    required String handle,
    File? logo,
    File? cover,
    List<File> galleryImages = const [],
    List<String> services = const [],
    int yearsOfExperience = 0,
  }) async {
    final userId = _db.auth.currentUser!.id;

    // Upload images
    String? logoUrl;
    String? coverUrl;
    List<String> imageUrls = [];

    if (logo != null) {
      logoUrl = await StorageService.uploadImage(
        bucket: 'workshops',
        path: '$userId/logo.jpg',
        file: logo,
      );
    }
    if (cover != null) {
      coverUrl = await StorageService.uploadImage(
        bucket: 'workshops',
        path: '$userId/cover.jpg',
        file: cover,
      );
    }
    for (int i = 0; i < galleryImages.length; i++) {
      final url = await StorageService.uploadImage(
        bucket: 'workshops',
        path: '$userId/gallery_$i.jpg',
        file: galleryImages[i],
      );
      imageUrls.add(url);
    }

    final data = await _db.from('workshops').insert({
      'owner_id': userId,
      'name': name,
      'city': city,
      'address': address,
      'description': description,
      'handle': handle,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'images': imageUrls,
      'services': services,
      'years_of_experience': yearsOfExperience,
    }).select().single();

    // Mark user as workshop owner
    await _db.from('profiles').update({'has_workshop': true}).eq('id', userId);

    return data;
  }

  // ── READ (All public workshops) ─────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchPublicWorkshops({
    String? cityFilter,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _db
        .from('workshops')
        .select('*, profiles!workshops_owner_id_fkey(name, username, profile_image_url)');

    if (cityFilter != null && cityFilter.isNotEmpty) {
      query = query.eq('city', cityFilter);
    }

    return await query
        .order('rating', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ── READ (Single workshop with posts & reviews) ─────────────────────────

  static Future<Map<String, dynamic>?> fetchWorkshopById(String workshopId) async {
    return await _db
        .from('workshops')
        .select('''
          *,
          profiles!workshops_owner_id_fkey(name, username, profile_image_url),
          posts(*, profiles!posts_author_id_fkey(name, username, profile_image_url)),
          reviews(*, profiles!reviews_reviewer_id_fkey(name, username, profile_image_url))
        ''')
        .eq('id', workshopId)
        .maybeSingle();
  }

  // ── READ (Current user's own workshop) ──────────────────────────────────

  static Future<Map<String, dynamic>?> fetchMyWorkshop() async {
    final userId = _db.auth.currentUser!.id;
    return await _db
        .from('workshops')
        .select()
        .eq('owner_id', userId)
        .maybeSingle();
  }

  // ── UPDATE ──────────────────────────────────────────────────────────────

  static Future<void> updateWorkshop({
    required String workshopId,
    required Map<String, dynamic> updates,
  }) async {
    await _db.from('workshops').update(updates).eq('id', workshopId);
  }

  // ── DELETE ──────────────────────────────────────────────────────────────

  static Future<void> deleteWorkshop(String workshopId) async {
    await _db.from('workshops').delete().eq('id', workshopId);
  }

  // ── FOLLOW / UNFOLLOW ─────────────────────────────────────────────────

  static Future<void> followWorkshop(String workshopId) async {
    final userId = _db.auth.currentUser!.id;
    await _db.from('follows').insert({
      'follower_id': userId,
      'workshop_id': workshopId,
    });
  }

  static Future<void> unfollowWorkshop(String workshopId) async {
    final userId = _db.auth.currentUser!.id;
    await _db.from('follows')
        .delete()
        .eq('follower_id', userId)
        .eq('workshop_id', workshopId);
  }

  static Future<bool> isFollowing(String workshopId) async {
    final user = _db.auth.currentUser;
    if (user == null) return false;
    final data = await _db
        .from('follows')
        .select('id')
        .eq('follower_id', user.id)
        .eq('workshop_id', workshopId)
        .maybeSingle();
    return data != null;
  }
}
