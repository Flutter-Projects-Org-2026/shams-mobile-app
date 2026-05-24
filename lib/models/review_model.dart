import 'user_model.dart';

/// ReviewModel — نموذج بيانات التقييم
///
/// Represents a single user review for a workshop.
/// Managed as part of [PublicWorkshopModel.reviews].
class ReviewModel {
  /// Unique review identifier
  final String id;

  /// The user who submitted the review
  final UserModel reviewer;

  /// Rating from 1.0 to 5.0
  final double rating;

  /// Written review comment
  final String comment;

  /// When the review was posted
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.reviewer,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  ReviewModel copyWith({
    String? id,
    UserModel? reviewer,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      reviewer: reviewer ?? this.reviewer,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reviewer': reviewer.toMap(),
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      reviewer: UserModel.fromMap(map['reviewer'] ?? {}),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  factory ReviewModel.fromSupabase(Map<String, dynamic> map) {
    final reviewerMap = map['profiles'] ?? {};
    return ReviewModel(
      id: map['id'] ?? '',
      reviewer: UserModel.fromMap(reviewerMap),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}
