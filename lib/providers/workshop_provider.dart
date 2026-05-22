import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/public_workshop_model.dart';
import '../models/workshop_data.dart';

/// WorkshopProvider — state manager for all workshop data.
///
/// Manages:
///   • [_posts]           — the logged-in user's own workshop posts (dashboard).
///   • [_publicWorkshops] — the public directory of all workshops.
///   • [_myWorkshop]      — the logged-in user's own workshop data (details).
///
/// All mutations call [notifyListeners] so every context.watch() subscriber
/// rebuilds automatically. No Consumer widgets needed.
class WorkshopProvider extends ChangeNotifier {
  // ── My Workshop Details (for Owner's Dashboard) ──────────────────────────
  WorkshopData? _myWorkshop;

  WorkshopData? get myWorkshop => _myWorkshop;

  Future<void> fetchMyWorkshop(String userId, String username) async {
    try {
      final data = await Supabase.instance.client
          .from('workshops')
          .select()
          .eq('owner_id', userId)
          .maybeSingle();

      if (data != null) {
        final workshop = WorkshopData(
          id: userId,
          name: data['name'] ?? '',
          username: username.isEmpty ? (data['username'] ?? 'workshop') : username,
          city: data['city'] ?? '',
          description: data['description'] ?? '',
          yearsOfExperience: 0,
        );
        setMyWorkshop(workshop);
      }
    } catch (e) {
      debugPrint('Error fetching user workshop data: $e');
    }
  }

  void setMyWorkshop(WorkshopData data) {
    _myWorkshop = data;
    
    final index = _publicWorkshops.indexWhere((w) => w.id == data.id);
    final logoPath = data.profileImage?.path ?? 'assets/images/logo/shams logo.png';
    final coverImagePath = data.coverImage?.path ?? 'assets/images/post image.jpg';
    
    if (index != -1) {
      final existing = _publicWorkshops[index];
      _publicWorkshops[index] = existing.copyWith(
        name: data.name,
        handle: '@${data.username}',
        city: data.city,
        description: data.description,
        logoPath: logoPath,
        coverImagePath: coverImagePath,
        yearsOfExperience: data.yearsOfExperience,
      );
    } else {
      _publicWorkshops.insert(
        0,
        PublicWorkshopModel(
          id: data.id,
          name: data.name,
          handle: '@${data.username}',
          city: data.city,
          rating: 4.8,
          reviewCount: 1,
          description: data.description,
          logoPath: logoPath,
          coverImagePath: coverImagePath,
          isFollowing: false,
          posts: List.from(_posts),
          yearsOfExperience: data.yearsOfExperience,
        ),
      );
    }
    notifyListeners();
  }

  // ── My Workshop Posts (owner's dashboard) ──────────────────────────────────

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

  // ── Public Workshops Directory ─────────────────────────────────────────────

  final List<PublicWorkshopModel> _publicWorkshops = [
    PublicWorkshopModel(
      id: 'w1',
      name: 'مركز المجد للطاقة الشمسية',
      handle: '@al_majd_solar',
      city: 'تعز',
      rating: 4.5,
      reviewCount: 320,
      description:
          'متخصصون في تركيب وصيانة أنظمة الطاقة الشمسية لأكثر من 10 سنوات. '
          'نقدم حلولاً متكاملة للقطاعين السكني والتجاري.',
      logoPath: 'assets/images/logo/shams logo.png',
      coverImagePath: 'assets/images/post image.jpg',
      isFollowing: true,
      posts: [
        PostModel(
          id: 'w1_p1',
          textDetails:
              'صيانة شاملة لنظام ألواح شمسية بقدرة 10 كيلوواط مع تنظيف الألواح لزيادة الكفاءة.',
          images: ['assets/images/post image.jpg'],
          createdAt: 'منذ يومين',
        ),
        PostModel(
          id: 'w1_p2',
          textDetails:
              'فحص وتبديل محول العاكس (Inverter) لنظام طاقة شمسية منزلي واستعادة النظام للعمل.',
          images: ['assets/images/post image.jpg'],
          createdAt: 'الأسبوع الماضي',
        ),
        PostModel(
          id: 'w1_p3',
          textDetails:
              'حل مشكلة ضعف شحن البطاريات وتغيير التوصيلات التالفة لنظام الطاقة الشمسية.',
          images: ['assets/images/post image.jpg'],
          createdAt: 'منذ أسبوعين',
        ),
      ],
    ),
    PublicWorkshopModel(
      id: 'w2',
      name: 'نور المستقبل لأنظمة الطاقة',
      handle: '@future_light_energy',
      city: 'تعز',
      rating: 4.8,
      reviewCount: 510,
      description:
          'شركة رائدة في حلول الطاقة الشمسية المتجددة. '
          'نوفر أفضل الأنظمة بأسعار منافسة مع ضمان شامل.',
      logoPath: 'assets/images/logo/shams logo.png',
      coverImagePath: 'assets/images/post image.jpg',
      isFollowing: false,
      posts: [
        PostModel(
          id: 'w2_p1',
          textDetails:
              'تركيب منظومة طاقة شمسية بقدرة 5 كيلوواط في منزل سكني بتعز.',
          images: ['assets/images/post image.jpg'],
          createdAt: 'منذ 3 أيام',
        ),
        PostModel(
          id: 'w2_p2',
          textDetails:
              'توريد وتركيب بطاريات ليثيوم عالية الجودة لنظام طاقة شمسية.',
          images: ['assets/images/post image.jpg'],
          createdAt: 'منذ أسبوع',
        ),
      ],
    ),
    PublicWorkshopModel(
      id: 'w3',
      name: 'رواد الطاقة البديلة',
      handle: '@alt_energy_pioneers',
      city: 'صنعاء',
      rating: 4.9,
      reviewCount: 870,
      description:
          'من الرواد في مجال الطاقة البديلة باليمن. '
          'خبرة تمتد لأكثر من 15 عاماً في تصميم وتنفيذ المشاريع الكبرى.',
      logoPath: 'assets/images/logo/shams logo.png',
      coverImagePath: 'assets/images/post image.jpg',
      isFollowing: false,
      posts: [
        PostModel(
          id: 'w3_p1',
          textDetails:
              'تنفيذ مشروع طاقة شمسية ضخم لمصنع في صنعاء بقدرة 50 كيلوواط.',
          images: ['assets/images/post image.jpg'],
          createdAt: 'منذ يوم',
        ),
        PostModel(
          id: 'w3_p2',
          textDetails:
              'تركيب منظومة طاقة شمسية كاملة لمجمع سكني في صنعاء — 80 لوحاً شمسياً.',
          images: ['assets/images/post image.jpg'],
          createdAt: 'منذ 4 أيام',
        ),
      ],
    ),
    PublicWorkshopModel(
      id: 'w4',
      name: 'عدن للطاقة المتجددة',
      handle: '@aden_renewable',
      city: 'عدن',
      rating: 3.9,
      reviewCount: 145,
      description:
          'نقدم خدمات تركيب وصيانة أنظمة الطاقة الشمسية في عدن والمناطق المجاورة.',
      logoPath: 'assets/images/logo/shams logo.png',
      coverImagePath: 'assets/images/post image.jpg',
      isFollowing: false,
      posts: [
        PostModel(
          id: 'w4_p1',
          textDetails: 'تركيب نظام مضخة مياه شمسية لمزرعة في لحج.',
          images: ['assets/images/post image.jpg'],
          createdAt: 'منذ 5 أيام',
        ),
      ],
    ),
  ];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Unmodifiable view of the owner's posts list (for dashboard).
  List<PostModel> get posts => List.unmodifiable(_posts);

  /// Total number of published posts.
  int get postCount => _posts.length;

  /// Live list of all publicly listed workshops.
  List<PublicWorkshopModel> get publicWorkshops =>
      List.unmodifiable(_publicWorkshops);

  /// Returns the workshop with [id], or null if not found.
  PublicWorkshopModel? getWorkshopById(String id) {
    try {
      return _publicWorkshops.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Toggle the follow state for the workshop with [workshopId].
  void toggleFollow(String workshopId) {
    final index = _publicWorkshops.indexWhere((w) => w.id == workshopId);
    if (index != -1) {
      _publicWorkshops[index] = _publicWorkshops[index].copyWith(
        isFollowing: !_publicWorkshops[index].isFollowing,
      );
      notifyListeners();
    }
  }

  // ── Owner's Post Management (dashboard) ───────────────────────────────────

  /// Add a new post at the top of the owner's list.
  void addPost(PostModel newPost) {
    _posts.insert(0, newPost);
    if (_myWorkshop != null) {
      final index = _publicWorkshops.indexWhere((w) => w.id == _myWorkshop!.id);
      if (index != -1) {
        final currentW = _publicWorkshops[index];
        final updatedPosts = List<PostModel>.from(currentW.posts)..insert(0, newPost);
        _publicWorkshops[index] = currentW.copyWith(posts: updatedPosts);
      }
    }
    notifyListeners();
  }

  /// Replace the post with the same [id] with [updatedPost].
  /// If no matching post is found, the list is unchanged.
  void updatePost(PostModel updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
    }
    if (_myWorkshop != null) {
      final wIndex = _publicWorkshops.indexWhere((w) => w.id == _myWorkshop!.id);
      if (wIndex != -1) {
        final currentW = _publicWorkshops[wIndex];
        final pIndex = currentW.posts.indexWhere((p) => p.id == updatedPost.id);
        if (pIndex != -1) {
          final updatedPosts = List<PostModel>.from(currentW.posts);
          updatedPosts[pIndex] = updatedPost;
          _publicWorkshops[wIndex] = currentW.copyWith(posts: updatedPosts);
        }
      }
    }
    notifyListeners();
  }

  /// Remove the post with the given [postId].
  void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    if (_myWorkshop != null) {
      final wIndex = _publicWorkshops.indexWhere((w) => w.id == _myWorkshop!.id);
      if (wIndex != -1) {
        final currentW = _publicWorkshops[wIndex];
        final updatedPosts = List<PostModel>.from(currentW.posts)..removeWhere((p) => p.id == postId);
        _publicWorkshops[wIndex] = currentW.copyWith(posts: updatedPosts);
      }
    }
    notifyListeners();
  }
}
