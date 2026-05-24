import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_service.dart';

class PostService {
  static final _db = Supabase.instance.client;

  // ── CREATE ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createPost({
    required String workshopId,
    required String textDetails,
    List<File> images = const [],
    bool isHighlighted = false,
  }) async {
    final userId = _db.auth.currentUser!.id;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Upload images
    List<String> imageUrls = [];
    for (int i = 0; i < images.length; i++) {
      final url = await StorageService.uploadImage(
        bucket: 'posts',
        path: '$userId/${timestamp}_$i.jpg',
        file: images[i],
      );
      imageUrls.add(url);
    }

    return await _db.from('posts').insert({
      'workshop_id': workshopId,
      'author_id': userId,
      'text_details': textDetails,
      'images': imageUrls,
      'is_highlighted': isHighlighted,
    }).select('''
      *,
      profiles!posts_author_id_fkey(id, name, username, profile_image_url, is_verified)
    ''').single();
  }

  // ── READ (Global feed — paginated) ──────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    // Fetch posts NOT hidden by the current user
    final posts = await _db
        .from('posts')
        .select('''
          *,
          profiles!posts_author_id_fkey(id, name, username, profile_image_url, is_verified),
          workshops!posts_workshop_id_fkey(id, name, handle, logo_url)
        ''')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    // Fetch hidden post IDs for this user
    final hiddenRows = await _db
        .from('hidden_posts')
        .select('post_id')
        .eq('user_id', currentUserId);

    final hiddenIds = hiddenRows.map((r) => r['post_id'] as String).toSet();

    // Filter out hidden posts
    final visiblePosts = posts.where((p) => !hiddenIds.contains(p['id'])).toList();

    return visiblePosts;
  }

  static void _incrementPostsViews(List<String> postIds) async {
    if (postIds.isEmpty) return;
    try {
      for (final id in postIds) {
        final post = await _db.from('posts').select('views_count').eq('id', id).maybeSingle();
        if (post != null) {
          final current = post['views_count'] as int? ?? 0;
          await _db.from('posts').update({'views_count': current + 1}).eq('id', id);
        }
      }
    } catch (e) {
      print('Error incrementing posts views: $e');
    }
  }

  // ── READ (Workshop-specific posts) ──────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchWorkshopPosts({
    required String workshopId,
    int limit = 20,
    int offset = 0,
  }) async {
    final posts = await _db
        .from('posts')
        .select('''
          *,
          profiles!posts_author_id_fkey(id, name, username, profile_image_url)
        ''')
        .eq('workshop_id', workshopId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    // Increment views for these posts asynchronously
    final postIds = posts.map((p) => p['id'] as String).toList();
    _incrementPostsViews(postIds);

    return posts;
  }

  // ── UPDATE ──────────────────────────────────────────────────────────────

  static Future<void> updatePost({
    required String postId,
    String? textDetails,
    bool? isHighlighted,
  }) async {
    final updates = <String, dynamic>{};
    if (textDetails != null) updates['text_details'] = textDetails;
    if (isHighlighted != null) updates['is_highlighted'] = isHighlighted;

    await _db.from('posts').update(updates).eq('id', postId);
  }

  // ── DELETE ──────────────────────────────────────────────────────────────

  static Future<void> deletePost(String postId) async {
    await _db.from('posts').delete().eq('id', postId);
  }

  // ── LIKE / UNLIKE ─────────────────────────────────────────────────────

  static Future<bool> toggleLike(String postId) async {
    final userId = _db.auth.currentUser!.id;
    final existing = await _db
        .from('post_likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      // Unlike
      await _db.from('post_likes').delete().eq('id', existing['id']);
      return false; // now unliked
    } else {
      // Like
      await _db.from('post_likes').insert({
        'post_id': postId,
        'user_id': userId,
      });

      // Trigger notification asynchronously
      _createLikeNotification(postId, userId);

      return true; // now liked
    }
  }

  static void _createLikeNotification(String postId, String likerId) async {
    try {
      final post = await _db.from('posts').select('author_id, text_details').eq('id', postId).single();
      final authorId = post['author_id'] as String?;
      
      // Don't send notification if the user likes their own post
      if (authorId == null || authorId == likerId) return;

      final likerProfile = await _db.from('profiles').select('name').eq('id', likerId).maybeSingle();
      final likerName = likerProfile?['name'] ?? 'مستخدم شمس';
      
      final textSnippet = post['text_details'] as String? ?? '';
      final truncatedText = textSnippet.length > 30 
          ? '${textSnippet.substring(0, 30)}...' 
          : textSnippet;

      await _db.from('notifications').insert({
        'user_id': authorId,
        'title': 'إعجاب جديد',
        'message': 'قام $likerName بالإعجاب بمنشورك: "$truncatedText"',
        'type': 'like',
        'target_id': postId,
      });
    } catch (e) {
      print('Error creating like notification: $e');
    }
  }

  /// Check if the current user liked a set of posts (batch check).
  static Future<Set<String>> fetchLikedPostIds(List<String> postIds) async {
    final userId = _db.auth.currentUser!.id;
    final rows = await _db
        .from('post_likes')
        .select('post_id')
        .eq('user_id', userId)
        .inFilter('post_id', postIds);
    return rows.map((r) => r['post_id'] as String).toSet();
  }

  // ── COMMENTS ──────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    return await _db
        .from('comments')
        .select('''
          *,
          profiles!comments_user_id_fkey(id, name, username, profile_image_url)
        ''')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
  }

  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String text,
  }) async {
    final userId = _db.auth.currentUser!.id;
    return await _db.from('comments').insert({
      'post_id': postId,
      'user_id': userId,
      'text': text,
    }).select('''
      *,
      profiles!comments_user_id_fkey(id, name, username, profile_image_url)
    ''').single();
  }

  static Future<void> deleteComment(String commentId) async {
    await _db.from('comments').delete().eq('id', commentId);
  }

  // ── COMMENT LIKE / UNLIKE ─────────────────────────────────────────────

  static Future<bool> toggleCommentLike(String commentId) async {
    final userId = _db.auth.currentUser!.id;
    final existing = await _db
        .from('comment_likes')
        .select('id')
        .eq('comment_id', commentId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _db.from('comment_likes').delete().eq('id', existing['id']);
      return false;
    } else {
      await _db.from('comment_likes').insert({
        'comment_id': commentId,
        'user_id': userId,
      });
      return true;
    }
  }

  // ── SAVE / UNSAVE ─────────────────────────────────────────────────────

  static Future<void> savePost(String postId) async {
    final userId = _db.auth.currentUser!.id;
    await _db.from('saved_posts').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }

  static Future<void> unsavePost(String postId) async {
    final userId = _db.auth.currentUser!.id;
    await _db.from('saved_posts')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }

  // ── HIDE ──────────────────────────────────────────────────────────────

  static Future<void> hidePost(String postId) async {
    final userId = _db.auth.currentUser!.id;
    await _db.from('hidden_posts').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }
}
