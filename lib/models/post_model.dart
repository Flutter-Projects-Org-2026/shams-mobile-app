import 'user_model.dart';
import 'comment_model.dart';

/// PostModel — نموذج بيانات منشور الورشة
///
/// Used by [WorkshopProvider] and all workshop-related screens.
class PostModel {
  /// Unique identifier (timestamp-based for dummy data)
  final String id;

  /// The workshop ID this post belongs to
  final String? workshopId;

  /// The written description / body of the post
  final String textDetails;

  /// List of image paths — either asset paths or local File paths
  final List<String> images;

  /// Whether the images are local device files (vs. asset bundle paths)
  final bool isLocalFile;

  /// Formatted views count string, e.g. "45.8K"
  final String viewsCount;

  /// Human-readable relative time, e.g. "منذ يومين"
  final String createdAt;

  /// Whether this post is pinned / highlighted at the top of the profile
  final bool isHighlighted;

  /// The author of the post
  final UserModel? author;

  /// Number of likes
  final int likesCount;

  /// Whether the current user liked this post
  final bool isLiked;

  /// List of comments on this post
  final List<CommentModel> comments;

  const PostModel({
    required this.id,
    this.workshopId,
    required this.textDetails,
    this.images = const [],
    this.isLocalFile = false,
    this.viewsCount = '0',
    required this.createdAt,
    this.isHighlighted = false,
    this.author,
    this.likesCount = 0,
    this.isLiked = false,
    this.comments = const [],
  });

  /// Returns a copy of this model with the provided fields overridden.
  PostModel copyWith({
    String? id,
    String? workshopId,
    String? textDetails,
    List<String>? images,
    bool? isLocalFile,
    String? viewsCount,
    String? createdAt,
    bool? isHighlighted,
    UserModel? author,
    int? likesCount,
    bool? isLiked,
    List<CommentModel>? comments,
  }) {
    return PostModel(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      textDetails: textDetails ?? this.textDetails,
      images: images ?? this.images,
      isLocalFile: isLocalFile ?? this.isLocalFile,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      author: author ?? this.author,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workshopId': workshopId,
      'textDetails': textDetails,
      'images': images,
      'isLocalFile': isLocalFile,
      'viewsCount': viewsCount,
      'createdAt': createdAt,
      'isHighlighted': isHighlighted,
      'author': author?.toMap(),
      'likesCount': likesCount,
      'isLiked': isLiked,
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      workshopId: map['workshopId'],
      textDetails: map['textDetails'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isLocalFile: map['isLocalFile'] ?? false,
      viewsCount: map['viewsCount'] ?? '0',
      createdAt: map['createdAt'] ?? '',
      isHighlighted: map['isHighlighted'] ?? false,
      author: map['author'] != null ? UserModel.fromMap(map['author']) : null,
      likesCount: map['likesCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      comments: (map['comments'] as List<dynamic>?)
              ?.map((c) => CommentModel.fromMap(c as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static String _timeAgo(String isoString) {
    try {
      final parsed = DateTime.parse(isoString);
      final diff = DateTime.now().difference(parsed);
      if (diff.inDays > 7) {
        return '${parsed.year}-${parsed.month}-${parsed.day}';
      } else if (diff.inDays >= 1) {
        return 'منذ ${diff.inDays} يوم';
      } else if (diff.inHours >= 1) {
        return 'منذ ${diff.inHours} ساعة';
      } else if (diff.inMinutes >= 1) {
        return 'منذ ${diff.inMinutes} دقيقة';
      } else {
        return 'الآن';
      }
    } catch (_) {
      return isoString;
    }
  }

  factory PostModel.fromSupabase(
    Map<String, dynamic> map, {
    bool isLiked = false,
    List<CommentModel> comments = const [],
  }) {
    final authorMap = map['profiles'];
    final author = authorMap != null ? UserModel.fromMap(authorMap) : null;
    final viewsVal = map['views_count'] ?? 0;
    
    return PostModel(
      id: map['id'] ?? '',
      workshopId: map['workshop_id'],
      textDetails: map['text_details'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isLocalFile: false,
      viewsCount: viewsVal > 1000 ? '${(viewsVal / 1000).toStringAsFixed(1)}K' : '$viewsVal',
      createdAt: _timeAgo(map['created_at'] ?? ''),
      isHighlighted: map['is_highlighted'] ?? false,
      author: author,
      likesCount: map['likes_count'] ?? 0,
      isLiked: isLiked,
      comments: comments,
    );
  }
}
