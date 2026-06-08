import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'PadelFinder Admin',
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.light,
        darkTheme: AdminTheme.dark,
        themeMode: ref.watch(adminDarkModeProvider) ? ThemeMode.dark : ThemeMode.light,
        routerConfig: ref.watch(routerProvider),
      );
}
