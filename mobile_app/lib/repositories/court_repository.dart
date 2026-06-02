import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/comment.dart';
import '../models/court.dart';
import '../models/report.dart';

class CourtRepository {
  CourtRepository(this.db, this.storage);
  final FirebaseFirestore db;
  final FirebaseStorage storage;
  final _uuid = const Uuid();

  Stream<List<Court>> approvedCourts() => db.collection('courts').where('status', isEqualTo: 'approved').orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map(Court.fromDoc).toList());
  Stream<Court> court(String id) => db.collection('courts').doc(id).snapshots().map(Court.fromDoc);
  Stream<List<Court>> search(String q) => approvedCourts().map((items) => items.where((c) => '${c.name} ${c.address} ${c.facilities.join(' ')}'.toLowerCase().contains(q.toLowerCase())).toList());
  Future<void> createCourt(Court court, File? image) async {
    var imageUrl = court.imageUrl;
    if (image != null) {
      final ref = storage.ref('courts/${court.courtId}.jpg');
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    }
    await db.collection('courts').doc(court.courtId).set(Court(courtId: court.courtId, name: court.name, description: court.description, address: court.address, latitude: court.latitude, longitude: court.longitude, imageUrl: imageUrl, facilities: court.facilities, createdBy: court.createdBy).toMap());
  }
  Stream<List<CourtComment>> comments(String courtId) => db.collection('comments').where('courtId', isEqualTo: courtId).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map(CourtComment.fromDoc).toList());
  Future<void> addComment(String courtId, String userId, String text) async {
    final id = _uuid.v4();
    final batch = db.batch();
    batch.set(db.collection('comments').doc(id), CourtComment(commentId: id, courtId: courtId, userId: userId, comment: text).toMap());
    batch.update(db.collection('courts').doc(courtId), {'commentsCount': FieldValue.increment(1)});
    await batch.commit();
  }
  Future<void> updateComment(String id, String text) => db.collection('comments').doc(id).update({'comment': text});
  Future<void> deleteComment(String courtId, String id) async {
    final batch = db.batch();
    batch.delete(db.collection('comments').doc(id));
    batch.update(db.collection('courts').doc(courtId), {'commentsCount': FieldValue.increment(-1)});
    await batch.commit();
  }
  Stream<bool> isFavorite(String userId, String courtId) => db.collection('favorites').where('userId', isEqualTo: userId).where('courtId', isEqualTo: courtId).snapshots().map((s) => s.docs.isNotEmpty);
  Stream<List<Court>> favorites(String userId) => db.collection('favorites').where('userId', isEqualTo: userId).snapshots().asyncMap((s) async {
    final ids = s.docs.map((d) => d['courtId'] as String).toList();
    final courts = <Court>[];
    for (final id in ids) {
      final doc = await db.collection('courts').doc(id).get();
      if (doc.exists) courts.add(Court.fromDoc(doc));
    }
    return courts;
  });
  Future<void> toggleFavorite(String userId, String courtId, bool active) async {
    final existing = await db.collection('favorites').where('userId', isEqualTo: userId).where('courtId', isEqualTo: courtId).get();
    final batch = db.batch();
    if (active) {
      for (final doc in existing.docs) { batch.delete(doc.reference); }
      batch.update(db.collection('courts').doc(courtId), {'favoritesCount': FieldValue.increment(-1)});
    } else {
      batch.set(db.collection('favorites').doc(_uuid.v4()), {'favoriteId': _uuid.v4(), 'userId': userId, 'courtId': courtId, 'createdAt': FieldValue.serverTimestamp()});
      batch.update(db.collection('courts').doc(courtId), {'favoritesCount': FieldValue.increment(1)});
    }
    await batch.commit();
  }
  Future<void> report(AppReport report) => db.collection('reports').doc(report.reportId).set(report.toMap());
}
