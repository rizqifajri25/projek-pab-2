import 'package:cloud_firestore/cloud_firestore.dart';

class Court {
  const Court({required this.courtId, required this.name, required this.description, required this.address, required this.latitude, required this.longitude, required this.imageUrl, required this.facilities, required this.createdBy, this.status = 'pending', this.favoritesCount = 0, this.commentsCount = 0, this.ratingSum = 0, this.ratingsCount = 0, this.averageRating = 0, this.createdAt});
  final String courtId, name, description, address, imageUrl, createdBy, status;
  final double latitude, longitude;
  final List<String> facilities;
  final int favoritesCount, commentsCount, ratingSum, ratingsCount;
  final double averageRating;
  final DateTime? createdAt;

  factory Court.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Court(
      courtId: d['courtId'] ?? doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      address: d['address'] ?? '',
      latitude: (d['latitude'] ?? 0).toDouble(),
      longitude: (d['longitude'] ?? 0).toDouble(),
      imageUrl: d['imageUrl'] ?? '',
      facilities: List<String>.from(d['facilities'] ?? const []),
      createdBy: d['createdBy'] ?? '',
      status: d['status'] ?? 'pending',
      favoritesCount: d['favoritesCount'] ?? 0,
      commentsCount: d['commentsCount'] ?? 0,
      ratingSum: (d['ratingSum'] as num?)?.toInt() ?? 0,
      ratingsCount: (d['ratingsCount'] as num?)?.toInt() ?? 0,
      averageRating: (d['averageRating'] as num?)?.toDouble() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'courtId': courtId,
        'name': name,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
        'facilities': facilities,
        'createdBy': createdBy,
        'status': status,
        'favoritesCount': favoritesCount,
        'commentsCount': commentsCount,
        'ratingSum': ratingSum,
        'ratingsCount': ratingsCount,
        'averageRating': averageRating,
        'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
      };
}
