/// PostModel — نموذج بيانات منشور الورشة
///
/// Used by [WorkshopProvider] and all workshop-related screens.
class PostModel {
  /// Unique identifier (timestamp-based for dummy data)
  final String id;

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

  const PostModel({
    required this.id,
    required this.textDetails,
    this.images = const [],
    this.isLocalFile = false,
    this.viewsCount = '0',
    required this.createdAt,
    this.isHighlighted = false,
  });

  /// Returns a copy of this model with the provided fields overridden.
  PostModel copyWith({
    String? id,
    String? textDetails,
    List<String>? images,
    bool? isLocalFile,
    String? viewsCount,
    String? createdAt,
    bool? isHighlighted,
  }) {
    return PostModel(
      id: id ?? this.id,
      textDetails: textDetails ?? this.textDetails,
      images: images ?? this.images,
      isLocalFile: isLocalFile ?? this.isLocalFile,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}
