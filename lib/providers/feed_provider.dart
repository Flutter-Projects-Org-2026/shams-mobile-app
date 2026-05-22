import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/public_workshop_model.dart';

class FeedProvider extends ChangeNotifier {
  final List<PostModel> _posts = [];

  List<PostModel> get posts => _posts;

  /// Aggregates all initial posts from the public workshops in WorkshopProvider.
  /// Uses a smart merge to avoid duplicate posts and prevent overwriting
  /// user interaction states (likes, comments, etc.).
  void initializeFromWorkshops(List<PublicWorkshopModel> workshops) {
    bool changed = false;
    for (final workshop in workshops) {
      for (final post in workshop.posts) {
        final exists = _posts.any((p) => p.id == post.id);
        if (!exists) {
          final fullPost = post.copyWith(
            workshopId: workshop.id,
            author: workshop.toUserModel(),
          );
          _posts.add(fullPost);
          changed = true;
        }
      }
    }
    if (changed) {
      notifyListeners();
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

  void toggleLike(String postId) {
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
    }
  }

  void addComment(String postId, CommentModel newComment) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final updatedComments = List<CommentModel>.from(post.comments)
        ..add(newComment);

      _posts[index] = post.copyWith(comments: updatedComments);
      notifyListeners();
    }
  }

  void deleteComment(String postId, String commentId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final updated = post.comments.where((c) => c.id != commentId).toList();
      _posts[index] = post.copyWith(comments: updated);
      notifyListeners();
    }
  }

  /// Toggles the like state for a single comment inside [postId].
  void toggleCommentLike(String postId, String commentId) {
    final pi = _posts.indexWhere((p) => p.id == postId);
    if (pi == -1) return;
    final post = _posts[pi];
    final updatedComments = post.comments.map((c) {
      if (c.id != commentId) return c;
      return c.copyWith(
        isLiked: !c.isLiked,
        likesCount: c.isLiked ? c.likesCount - 1 : c.likesCount + 1,
      );
    }).toList();
    _posts[pi] = post.copyWith(comments: updatedComments);
    notifyListeners();
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
  /// Implemented as a delete for local state; the DB integration will use a
  /// "hidden_posts" table instead.
  void hidePost(String postId) => deletePost(postId);
}
