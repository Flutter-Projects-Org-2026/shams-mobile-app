import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/public_workshop_model.dart';
import '../services/post_service.dart';

class FeedProvider extends ChangeNotifier {
  final List<PostModel> _posts = [];

  List<PostModel> get posts => _posts;

  FeedProvider() {
    fetchFeed();
  }

  /// Aggregates all initial posts from the public workshops in WorkshopProvider.
  /// Kept for backward compatibility with proxy provider in main.dart
  void initializeFromWorkshops(List<PublicWorkshopModel> workshops) {
    // Live fetching handles data, but we keep this method to avoid breaking main.dart
  }

  Future<void> fetchFeed() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      
      final data = await PostService.fetchFeed(currentUserId: user.id);
      
      // Batch fetch liked post IDs for the current user
      final postIds = data.map((p) => p['id'] as String).toList();
      final likedIds = postIds.isNotEmpty ? await PostService.fetchLikedPostIds(postIds) : <String>{};

      final List<PostModel> loaded = [];
      for (final item in data) {
        final commentsData = await PostService.fetchComments(item['id']);
        final comments = commentsData.map((c) => CommentModel.fromSupabase(c)).toList();
        
        loaded.add(PostModel.fromSupabase(
          item,
          isLiked: likedIds.contains(item['id']),
          comments: comments,
        ));
      }
      _posts.clear();
      _posts.addAll(loaded);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching feed from Supabase: $e');
    }
  }

  /// Returns the post with [id], or null if not found.
  PostModel? getPostById(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newIsLiked = !post.isLiked;
      final newLikesCount = newIsLiked
          ? post.likesCount + 1
          : post.likesCount - 1;

      _posts[index] = post.copyWith(
        isLiked: newIsLiked,
        likesCount: newLikesCount,
      );
      notifyListeners();

      try {
        await PostService.toggleLike(postId);
      } catch (e) {
        debugPrint('Error toggling post like in database: $e');
        // Revert
        _posts[index] = post.copyWith(
          isLiked: !newIsLiked,
          likesCount: post.likesCount,
        );
        notifyListeners();
      }
    }
  }

  Future<void> addComment(String postId, CommentModel newComment) async {
    try {
      final commentMap = await PostService.addComment(postId: postId, text: newComment.text);
      final addedComment = CommentModel.fromSupabase(commentMap);

      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final updatedComments = List<CommentModel>.from(post.comments)
          ..add(addedComment);

        _posts[index] = post.copyWith(comments: updatedComments);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding comment to Supabase: $e');
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final updated = post.comments.where((c) => c.id != commentId).toList();
      _posts[index] = post.copyWith(comments: updated);
      notifyListeners();

      try {
        await PostService.deleteComment(commentId);
      } catch (e) {
        debugPrint('Error deleting comment from database: $e');
      }
    }
  }

  /// Toggles the like state for a single comment inside [postId].
  Future<void> toggleCommentLike(String postId, String commentId) async {
    final pi = _posts.indexWhere((p) => p.id == postId);
    if (pi == -1) return;
    final post = _posts[pi];
    
    final commentIndex = post.comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = post.comments[commentIndex];
    final newIsLiked = !comment.isLiked;
    final newLikesCount = newIsLiked ? comment.likesCount + 1 : comment.likesCount - 1;

    final updatedComments = List<CommentModel>.from(post.comments);
    updatedComments[commentIndex] = comment.copyWith(
      isLiked: newIsLiked,
      likesCount: newLikesCount,
    );
    _posts[pi] = post.copyWith(comments: updatedComments);
    notifyListeners();

    try {
      await PostService.toggleCommentLike(commentId);
    } catch (e) {
      debugPrint('Error toggling comment like in database: $e');
      // Revert
      updatedComments[commentIndex] = comment;
      _posts[pi] = post.copyWith(comments: updatedComments);
      notifyListeners();
    }
  }

  /// Inserts [post] at the top of the feed (newest-first).
  void addPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  /// Replaces the post with the same [id] with [updatedPost].
  /// No-op if the post is not found (e.g. it belongs to another source).
  void updatePost(PostModel updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  /// Permanently removes [postId] from the feed.
  void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  /// Hides [postId] from the local feed without deleting it server-side.
  Future<void> hidePost(String postId) async {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();

    try {
      await PostService.hidePost(postId);
    } catch (e) {
      debugPrint('Error hiding post in database: $e');
    }
  }
}
