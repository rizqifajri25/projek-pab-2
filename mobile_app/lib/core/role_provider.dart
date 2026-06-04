import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'providers.dart';

final roleProvider =
    FutureProvider<String>((ref) async {

  final user =
      ref.watch(authProvider)
          .currentUser;

  if (user == null) {
    return 'guest';
  }

  final doc =
      await ref
          .watch(
              firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .get();

  return doc.data()?['role']
      ?? 'user';
});