class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String userType; // 'patient', 'doctor', 'rider', etc.
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.userType,
    required this.createdAt,
  });

  /// Build from JSON returned by your Node/Postgres API.
  /// Example JSON:
  /// {
  ///   "id": 1,
  ///   "name": "John",
  ///   "email": "john@example.com",
  ///   "phone": "9999999999",
  ///   "photo_url": null,
  ///   "role": "patient",
  ///   "created_at": "2025-11-29T18:20:00.000Z"
  /// }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photo_url'] as String?,
      userType: (json['role'] ?? json['user_type'] ?? 'patient').toString(),
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? '') as String,
      ) ??
          DateTime.now(),
    );
  }

  /// Convert to JSON for sending to backend (if needed).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo_url': photoUrl,
      'role': userType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
