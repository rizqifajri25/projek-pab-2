import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import 'auth_repository.dart';
import 'court_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(authProvider), ref.watch(firestoreProvider)));
final courtRepositoryProvider = Provider(
  (ref) => CourtRepository(
    ref.watch(firestoreProvider),
  ),
);
