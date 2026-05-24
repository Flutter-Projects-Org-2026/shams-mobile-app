import 'post_model.dart';
import 'review_model.dart';
import 'user_model.dart';

/// PublicWorkshopModel — نموذج بيانات الورشة العامة
///
/// Represents a publicly listed workshop visible in [WorkshopsListScreen]
/// and [WorkshopProfile]. Managed by [WorkshopProvider].
class PublicWorkshopModel {
  /// Unique identifier
  final String id;

  /// Workshop owner user ID
  final String ownerId;

  /// Display name of the workshop
  final String name;

  /// @handle of the workshop
  final String handle;

  /// City / province
  final String city;

  /// Star rating (0–5)
  final double rating;

  /// Number of reviews
  final int reviewCount;

  /// Short description of the workshop
  final String description;

  /// Asset or network path to the logo
  final String logoPath;

  /// Asset or network path to the cover image
  final String coverImagePath;

  /// Whether the current user follows this workshop
  final bool isFollowing;

  /// Work-log posts displayed on the profile
  final List<PostModel> posts;

  // ── Domain-specific fields ────────────────────────────────────────────────

  /// Services offered (from [ShamsConstants.solarServiceTypes])
  final List<String> serviceTypes;

  /// Contact phone number
  final String? phone;

  /// WhatsApp number (may differ from phone)
  final String? whatsapp;

  /// Years of experience
  final int yearsOfExperience;

  /// Whether this workshop is platform-verified
  final bool isVerified;

  /// User reviews for this workshop
  final List<ReviewModel> reviews;

  const PublicWorkshopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.handle,
    required this.city,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.description = '',
    this.logoPath = 'assets/images/logo/shams logo.png',
    this.coverImagePath = 'assets/images/post image.jpg',
    this.isFollowing = false,
    this.posts = const [],
    this.serviceTypes = const [],
    this.phone,
    this.whatsapp,
    this.yearsOfExperience = 0,
    this.isVerified = false,
    this.reviews = const [],
  });

  PublicWorkshopModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? handle,
    String? city,
    double? rating,
    int? reviewCount,
    String? description,
    String? logoPath,
    String? coverImagePath,
    bool? isFollowing,
    List<PostModel>? posts,
    List<String>? serviceTypes,
    String? phone,
    String? whatsapp,
    int? yearsOfExperience,
    bool? isVerified,
    List<ReviewModel>? reviews,
  }) {
    return PublicWorkshopModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      logoPath: logoPath ?? this.logoPath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      isFollowing: isFollowing ?? this.isFollowing,
      posts: posts ?? this.posts,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isVerified: isVerified ?? this.isVerified,
      reviews: reviews ?? this.reviews,
    );
  }

  factory PublicWorkshopModel.fromSupabase(
    Map<String, dynamic> map, {
    bool isFollowing = false,
    List<PostModel> posts = const [],
    List<ReviewModel> reviews = const [],
  }) {
    return PublicWorkshopModel(
      id: map['id'] ?? '',
      ownerId: map['owner_id'] ?? '',
      name: map['name'] ?? '',
      handle: map['handle'] ?? '',
      city: map['city'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviews_count'] as int? ?? 0,
      description: map['description'] ?? '',
      logoPath: map['logo_url'] ?? 'assets/images/logo/shams logo.png',
      coverImagePath: map['cover_url'] ?? 'assets/images/post image.jpg',
      isFollowing: isFollowing,
      posts: posts,
      serviceTypes: List<String>.from(map['services'] ?? []),
      phone: map['phone'],
      whatsapp: map['whatsapp'],
      yearsOfExperience: map['years_of_experience'] as int? ?? 0,
      isVerified: map['is_verified'] ?? false,
      reviews: reviews,
    );
  }

  /// Converts this workshop to a [UserModel] suitable for use in chat participants.
  UserModel toUserModel() {
    return UserModel(
      id: ownerId,
      name: name,
      email: '${handle.replaceFirst('@', '')}@shams.com',
      profileImageUrl: logoPath,
    );
  }
}
