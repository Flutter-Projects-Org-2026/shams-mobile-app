import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';

class FeedProvider extends ChangeNotifier {
  final List<PostModel> _posts = [
    PostModel(
      id: 'p1',
      textDetails: 'تم الانتهاء اليوم من تركيب منظومة طاقة شمسية بقدرة 5 كيلو واط مع عاكس [مكس/JA] قياسي واط في صنعاء، تم استخدام الألواح الأداء ممتازة من غاز عبر.',
      images: ['assets/images/post image.jpg'],
      createdAt: 'منذ ساعتين',
      likesCount: 124,
      isLiked: false,
      author: const UserModel(
        id: 'u2',
        name: 'م. أحمد العمودي',
        email: 'ahmed@example.com',
        profileImageUrl: 'assets/images/logo/shams logo.png',
      ),
      comments: [
        CommentModel(
          id: 'c1',
          postId: 'p1',
          text: 'ممتاز! هذا النوع من المنظومات يعطي كفاءة عالية جداً في الصيف.',
          likesCount: 4,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          user: const UserModel(
            id: 'u3',
            name: 'م. سارة الهاشمي',
            email: 'sara@example.com',
            profileImageUrl: 'assets/images/logo/shams logo.png',
          ),
        ),
      ],
    ),
    PostModel(
      id: 'p2',
      textDetails: 'مشروع جديد في الرياض! تركيب ألواح شمسية على مبنى تجاري بقدرة 20 كيلو واط. النتائج مبهرة والكفاءة عالية جداً.',
      images: ['assets/images/post image.jpg'],
      createdAt: 'منذ يوم',
      likesCount: 89,
      isLiked: true,
      author: const UserModel(
        id: 'u3',
        name: 'م. سارة الهاشمي',
        email: 'sara@example.com',
        profileImageUrl: 'assets/images/logo/shams logo.png',
      ),
    ),
  ];

  List<PostModel> get posts => _posts;

  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newIsLiked = !post.isLiked;
      final newLikesCount = newIsLiked ? post.likesCount + 1 : post.likesCount - 1;
      
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
      final updatedComments = List<CommentModel>.from(post.comments)..add(newComment);
      
      _posts[index] = post.copyWith(
        comments: updatedComments,
      );
      notifyListeners();
    }
  }
}
