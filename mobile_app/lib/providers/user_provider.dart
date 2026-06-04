import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../models/app_user.dart';

final currentUserProvider =
    StreamProvider<AppUser?>((ref) {
  final auth =
      ref.watch(authProvider);

  final user =
      auth.currentUser;

  if (user == null) {
    return Stream.value(null);
  }

  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map(
        (doc) => doc.exists
            ? AppUser.fromDoc(doc)
            : null,
      );
});