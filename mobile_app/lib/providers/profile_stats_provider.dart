import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../core/providers.dart';

final profileStatsProvider = StreamProvider((ref) {
  final uid = ref.read(authProvider).currentUser!.uid;
  final db = ref.read(firestoreProvider);

  return _createCombinedStatsStream(db, uid);
});

Stream<Map<String, int>> _createCombinedStatsStream(
  dynamic db,
  String uid,
) {
  final controller = StreamController<Map<String, int>>();

  final courtsStream = db
      .collection('courts')
      .where('createdBy', isEqualTo: uid)
      .snapshots();

  final commentsStream = db
      .collection('comments')
      .where('userId', isEqualTo: uid)
      .snapshots();

  final favoritesStream = db
      .collection('favorites')
      .where('userId', isEqualTo: uid)
      .snapshots();

  var courtsCount = 0;
  var commentsCount = 0;
  var favoritesCount = 0;

  void emitStats() {
    controller.add({
      'courts': courtsCount,
      'comments': commentsCount,
      'favorites': favoritesCount,
    });
  }

  final sub1 = courtsStream.listen((snapshot) {
    courtsCount = snapshot.docs.length;
    emitStats();
  }, onError: (e) => controller.addError(e));

  final sub2 = commentsStream.listen((snapshot) {
    commentsCount = snapshot.docs.length;
    emitStats();
  }, onError: (e) => controller.addError(e));

  final sub3 = favoritesStream.listen((snapshot) {
    favoritesCount = snapshot.docs.length;
    emitStats();
  }, onError: (e) => controller.addError(e));

  controller.onCancel = () {
    sub1.cancel();
    sub2.cancel();
    sub3.cancel();
    controller.close();
  };

  return controller.stream;
}