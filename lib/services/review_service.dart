import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  static final _db = Supabase.instance.client;

  static Future<Map<String, dynamic>> addReview({
    required String workshopId,
    required double rating,
    required String comment,
  }) async {
    final userId = _db.auth.currentUser!.id;
    return await _db.from('reviews').insert({
      'workshop_id': workshopId,
      'reviewer_id': userId,
      'rating': rating,
      'comment': comment,
    }).select('''
      *,
      profiles!reviews_reviewer_id_fkey(id, name, profile_image_url)
    ''').single();
  }

  static Future<List<Map<String, dynamic>>> fetchWorkshopReviews(
    String workshopId,
  ) async {
    return await _db
        .from('reviews')
        .select('''
          *,
          profiles!reviews_reviewer_id_fkey(id, name, profile_image_url)
        ''')
        .eq('workshop_id', workshopId)
        .order('created_at', ascending: false);
  }

  static Future<void> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  }) async {
    final updates = <String, dynamic>{};
    if (rating != null) updates['rating'] = rating;
    if (comment != null) updates['comment'] = comment;
    await _db.from('reviews').update(updates).eq('id', reviewId);
  }

  static Future<void> deleteReview(String reviewId) async {
    await _db.from('reviews').delete().eq('id', reviewId);
  }
}
