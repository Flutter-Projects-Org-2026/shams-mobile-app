import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/public_workshop_model.dart';
import '../models/workshop_data.dart';
import '../services/workshop_service.dart';
import '../services/post_service.dart';

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
  WorkshopProvider() {
    fetchPublicWorkshops();
  }

  Future<void> fetchPublicWorkshops() async {
    try {
      final data = await WorkshopService.fetchPublicWorkshops();
      final List<PublicWorkshopModel> loaded = [];
      for (final item in data) {
        final isFollowing = await WorkshopService.isFollowing(item['id']);
        var model = PublicWorkshopModel.fromSupabase(
          item,
          isFollowing: isFollowing,
        );
        if (_myWorkshop != null && item['id'] == _myWorkshop!.id) {
          final logoPath = _myWorkshop!.profileImage?.path ?? _myWorkshop!.logoUrl ?? model.logoPath;
          final coverImagePath = _myWorkshop!.coverImage?.path ?? _myWorkshop!.coverUrl ?? model.coverImagePath;
          model = model.copyWith(
            name: _myWorkshop!.name,
            handle: '@${_myWorkshop!.username}',
            city: _myWorkshop!.city,
            description: _myWorkshop!.description,
            logoPath: logoPath,
            coverImagePath: coverImagePath,
            yearsOfExperience: _myWorkshop!.yearsOfExperience,
            posts: List.from(_posts),
          );
        }
        loaded.add(model);
      }
      _publicWorkshops.clear();
      _publicWorkshops.addAll(loaded);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching public workshops from database: $e');
    }
  }
  // ── My Workshop Details (for Owner's Dashboard) ──────────────────────────
  WorkshopData? _myWorkshop;
  int _myWorkshopFollowersCount = 0;

  WorkshopData? get myWorkshop => _myWorkshop;
  int get myWorkshopFollowersCount => _myWorkshopFollowersCount;

  Future<void> fetchMyWorkshop(String userId, String username) async {
    try {
      final data = await Supabase.instance.client
          .from('workshops')
          .select()
          .eq('owner_id', userId)
          .maybeSingle();

      if (data != null) {
        final workshopId = data['id'] ?? '';

        // Fetch real followers count from the follows table
        try {
          final followersRes = await Supabase.instance.client
              .from('follows')
              .select('id')
              .eq('workshop_id', workshopId);
          _myWorkshopFollowersCount = followersRes.length;
        } catch (e) {
          debugPrint('Error fetching followers count: $e');
        }

        final workshop = WorkshopData(
          id: workshopId,
          ownerId: userId,
          name: data['name'] ?? '',
          username: (data['handle'] ?? username).toString().replaceAll('@', ''),
          city: data['city'] ?? '',
          description: data['description'] ?? '',
          yearsOfExperience: data['years_of_experience'] as int? ?? 0,
          logoUrl: data['logo_url'],
          coverUrl: data['cover_url'],
          galleryUrls: List<String>.from(data['images'] ?? []),
        );
        setMyWorkshop(workshop);
      }
    } catch (e) {
      debugPrint('Error fetching user workshop data: $e');
    }
  }

  Future<void> fetchMyWorkshopPosts(String workshopId) async {
    try {
      final data = await PostService.fetchWorkshopPosts(workshopId: workshopId);
      final List<PostModel> loaded = [];
      for (final item in data) {
        final commentsData = await PostService.fetchComments(item['id']);
        final comments = commentsData.map((c) => CommentModel.fromSupabase(c)).toList();
        loaded.add(PostModel.fromSupabase(item, comments: comments));
      }
      _posts.clear();
      _posts.addAll(loaded);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching my workshop posts: $e');
    }
  }

  void setMyWorkshop(WorkshopData data) {
    _myWorkshop = data;
    
    final index = _publicWorkshops.indexWhere((w) => w.id == data.id);
    final logoPath = data.profileImage?.path ?? data.logoUrl ?? 'assets/images/logo/shams logo.png';
    final coverImagePath = data.coverImage?.path ?? data.coverUrl ?? 'assets/images/post image.jpg';
    
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
          ownerId: data.ownerId,
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

  final List<PostModel> _posts = [];

  // ── Public Workshops Directory ─────────────────────────────────────────────

  final List<PublicWorkshopModel> _publicWorkshops = [];

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

  /// Returns the workshop owned by [ownerId], or null if not found.
  PublicWorkshopModel? getWorkshopByOwnerId(String ownerId) {
    try {
      return _publicWorkshops.firstWhere((w) => w.ownerId == ownerId);
    } catch (_) {
      return null;
    }
  }

  /// Toggle the follow state for the workshop with [workshopId].
  Future<void> toggleFollow(String workshopId) async {
    final index = _publicWorkshops.indexWhere((w) => w.id == workshopId);
    if (index != -1) {
      final currentlyFollowing = _publicWorkshops[index].isFollowing;
      _publicWorkshops[index] = _publicWorkshops[index].copyWith(
        isFollowing: !currentlyFollowing,
      );
      notifyListeners();

      try {
        if (currentlyFollowing) {
          await WorkshopService.unfollowWorkshop(workshopId);
        } else {
          await WorkshopService.followWorkshop(workshopId);
        }
      } catch (e) {
        debugPrint('Error toggling follow in database: $e');
        // Revert on failure
        _publicWorkshops[index] = _publicWorkshops[index].copyWith(
          isFollowing: currentlyFollowing,
        );
        notifyListeners();
      }
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
