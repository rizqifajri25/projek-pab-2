import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/comment.dart';
import '../models/court.dart';
import '../models/report.dart';
import '../services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';

class CourtRepository {
  CourtRepository(this.db);

  final FirebaseFirestore db;

  final _uuid = const Uuid();

Stream<List<Court>>
approvedCourts() {

  return db
      .collection('courts')
      .where(
        'status',
        isEqualTo: 'approved',
      )
      .orderBy(
        'createdAt',
        descending: true,
      )
      .snapshots()
      .map(
        (s) => s.docs
            .map(Court.fromDoc)
            .toList(),
      );
}
  Stream<Court> court(String id) => db.collection('courts').doc(id).snapshots().map(Court.fromDoc);
  Stream<List<Court>> search(String q) => approvedCourts().map((items) => items.where((c) => '${c.name} ${c.address} ${c.facilities.join(' ')}'.toLowerCase().contains(q.toLowerCase())).toList());
  Future<void> createCourt(
  Court court,
  XFile? image) async {
    var imageUrl = court.imageUrl;
    if (image != null) {
      imageUrl =
      await CloudinaryService.uploadImage(image)
      ?? '';
    }
    await db.collection('courts').doc(court.courtId).set(Court(courtId: court.courtId, name: court.name, description: court.description, address: court.address, latitude: court.latitude, longitude: court.longitude, imageUrl: imageUrl, facilities: court.facilities, createdBy: court.createdBy).toMap());
  }
  Stream<List<CourtComment>> comments(String courtId) => db.collection('comments').where('courtId', isEqualTo: courtId).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map(CourtComment.fromDoc).toList());
  Future<void> addReview(String courtId, String userId, String text, int rating) async {
    final cleanedText = text.trim();
    if (cleanedText.isEmpty) {
      throw Exception('Komentar tidak boleh kosong');
    }
    if (rating < 1 || rating > 5) {
      throw Exception('Rating harus 1 sampai 5 bintang');
    }

    final userDoc = await db.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};
    final id = _uuid.v4();
    final courtRef = db.collection('courts').doc(courtId);
    final courtDoc = await courtRef.get();
    final currentSum = (courtDoc.data()?['ratingSum'] as num?)?.toInt() ?? 0;
    final currentCount = (courtDoc.data()?['ratingsCount'] as num?)?.toInt() ?? 0;
    final nextSum = currentSum + rating;
    final nextCount = currentCount + 1;

    final batch = db.batch();
    batch.set(
      db.collection('comments').doc(id),
      CourtComment(
        commentId: id,
        courtId: courtId,
        userId: userId,
        userName: userData['name'] ?? userData['email'] ?? 'User',
        userPhotoUrl: userData['photoUrl'],
        comment: cleanedText,
        rating: rating,
      ).toMap(),
    );
    batch.set(
      courtRef,
      {
        'commentsCount': FieldValue.increment(1),
        'ratingSum': FieldValue.increment(rating),
        'ratingsCount': FieldValue.increment(1),
        'averageRating': nextSum / nextCount,
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> addComment(String courtId, String userId, String text) =>
      addReview(courtId, userId, text, 5);
  Future<void> updateComment(String id, String text) => db.collection('comments').doc(id).update({'comment': text});
  Future<void> deleteComment(String courtId, String id) async {
    final commentRef = db.collection('comments').doc(id);
    final commentDoc = await commentRef.get();
    final rating = (commentDoc.data()?['rating'] as num?)?.toInt() ?? 0;
    final courtRef = db.collection('courts').doc(courtId);
    final courtDoc = await courtRef.get();
    final currentSum = (courtDoc.data()?['ratingSum'] as num?)?.toInt() ?? 0;
    final currentCount = (courtDoc.data()?['ratingsCount'] as num?)?.toInt() ?? 0;
    final nextSum = (currentSum - rating).clamp(0, 1 << 31);
    final nextCount = (currentCount - (rating > 0 ? 1 : 0)).clamp(0, 1 << 31);
    final batch = db.batch();
    batch.delete(commentRef);
    batch.set(
      courtRef,
      {
        'commentsCount': FieldValue.increment(-1),
        if (rating > 0) 'ratingSum': FieldValue.increment(-rating),
        if (rating > 0) 'ratingsCount': FieldValue.increment(-1),
        'averageRating': nextCount == 0 ? 0 : nextSum / nextCount,
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }
  Stream<bool> isFavorite(String userId, String courtId) => db.collection('favorites').where('userId', isEqualTo: userId).where('courtId', isEqualTo: courtId).snapshots().map((s) => s.docs.isNotEmpty);
  Stream<int> favoriteCount(
    String courtId,
  ) {
    return db
        .collection('favorites')
        .where(
          'courtId',
          isEqualTo: courtId,
        )
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.length,
        );
  }
  Stream<List<Court>> favorites(String userId) => db.collection('favorites').where('userId', isEqualTo: userId).snapshots().asyncMap((s) async {
    final ids = s.docs
    .map((d) => d['courtId'] as String)
    .toSet()
    .toList();
    final courts = <Court>[];
    for (final id in ids) {
      final doc = await db.collection('courts').doc(id).get();
      if (doc.exists) courts.add(Court.fromDoc(doc));
    }
    return courts;
  });

Future<void> toggleFavorite(
  String userId,
  String courtId,
) async {

  final favoriteId = '${userId}_$courtId';

  final favoriteRef =
      db.collection('favorites').doc(favoriteId);

  final favoriteDoc =
      await favoriteRef.get();

  if (favoriteDoc.exists) {

    await favoriteRef.delete();

  } else {

    await favoriteRef.set({
      'favoriteId': favoriteId,
      'userId': userId,
      'courtId': courtId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
  Future<void> report(AppReport report) => db.collection('reports').doc(report.reportId).set(report.toMap());
}
