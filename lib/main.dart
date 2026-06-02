import 'package:flutter/material.dart';

void main() => runApp(const PadelFinderWorkspaceApp());

class PadelFinderWorkspaceApp extends StatelessWidget {
  const PadelFinderWorkspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PadelFinder Workspace',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488))),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'PadelFinder source code is available in mobile_app/ and admin_panel/.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
