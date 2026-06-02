import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import 'admin_repository.dart';
final adminRepositoryProvider = Provider((ref) => AdminRepository(ref.watch(authProvider), ref.watch(firestoreProvider)));
