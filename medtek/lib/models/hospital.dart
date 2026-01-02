class Hospital {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Hospital({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
