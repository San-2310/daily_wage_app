class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // "worker" or "employer"
  final String? location; // Address or location string
  final double? latitude; // Latitude for geolocation
  final double? longitude; // Longitude for geolocation
  final double?
      averageRating; // The average rating (calculated based on ratings)
  final int ratingCount; // The number of ratings received

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.location,
    this.latitude,
    this.longitude,
    this.averageRating,
    this.ratingCount = 0,
  });

  // Convert Firestore document to AppUser
  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      location: data['location'] is String ? data['location'] : null,
      latitude: data['location'] is Map ? (data['location']['latitude'] ?? 0).toDouble() : null,
      longitude: data['location'] is Map ? (data['location']['longitude'] ?? 0).toDouble() : null,
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
    );
  }

  // Convert AppUser to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'location': location ?? {'latitude': latitude, 'longitude': longitude},
      'averageRating':
          averageRating ?? 0.0, // Default to 0.0 if no average rating
      'ratingCount': ratingCount,
    };
  }
}
