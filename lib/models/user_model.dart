class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final String? phone;
  final bool isVerified;
  final bool hasWorkshop;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.phone,
    this.isVerified = false,
    this.hasWorkshop = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? bio,
    String? phone,
    bool? isVerified,
    bool? hasWorkshop,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      hasWorkshop: hasWorkshop ?? this.hasWorkshop,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'phone': phone,
      'is_verified': isVerified,
      'has_workshop': hasWorkshop,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profile_image_url'],
      bio: map['bio'],
      phone: map['phone'],
      isVerified: map['is_verified'] ?? false,
      hasWorkshop: map['has_workshop'] ?? false,
    );
  }
}
