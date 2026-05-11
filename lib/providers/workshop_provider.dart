import 'package:flutter/material.dart';
import '../models/post_model.dart';

/// WorkshopProvider — state manager for the workshop's post list.
///
/// Initialized with 3 realistic dummy posts so the dashboard looks
/// populated immediately. All CRUD operations call [notifyListeners]
/// so every [Consumer<WorkshopProvider>] rebuilds automatically.
class WorkshopProvider extends ChangeNotifier {
  // ── Dummy seed data ────────────────────────────────────────────────────────

  final List<PostModel> _posts = [
    PostModel(
      id: 'post_001',
      textDetails:
          'تركيب منظومة طاقة شمسية بقدرة 10 كيلوواط لمنزل سكني في صنعاء. '
          'تشمل 24 لوحاً شمسياً، بطاريات ليثيوم، ومحول عاكس عالي الكفاءة.',
      images: ['assets/images/post image.jpg'],
      isLocalFile: false,
      viewsCount: '45.8K',
      createdAt: 'منذ يومين',
      isHighlighted: true,
    ),
    PostModel(
      id: 'post_002',
      textDetails:
          'صيانة دورية شاملة لمحطة طاقة شمسية صناعية — تنظيف الألواح، '
          'فحص كابلات الربط، واختبار كفاءة الإنتاج بأجهزة قياس معتمدة.',
      images: ['assets/images/post image.jpg'],
      isLocalFile: false,
      viewsCount: '12.3K',
      createdAt: 'منذ 4 أيام',
      isHighlighted: false,
    ),
    PostModel(
      id: 'post_003',
      textDetails:
          'تصميم وتنفيذ نظام مضخة مياه شمسية للمزارع بسعة 5000 لتر/ساعة — '
          'حل مستدام يُقلّل فاتورة الكهرباء بنسبة 80٪.',
      images: ['assets/images/post image.jpg'],
      isLocalFile: false,
      viewsCount: '8.1K',
      createdAt: 'منذ أسبوع',
      isHighlighted: false,
    ),
  ];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Unmodifiable view of the posts list.
  List<PostModel> get posts => List.unmodifiable(_posts);

  /// Total number of published posts.
  int get postCount => _posts.length;

  /// Add a new post at the top of the list.
  void addPost(PostModel newPost) {
    _posts.insert(0, newPost);
    notifyListeners();
  }

  /// Replace the post with the same [id] with [updatedPost].
  /// If no matching post is found, the list is unchanged.
  void updatePost(PostModel updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  /// Remove the post with the given [postId].
  void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }
}
