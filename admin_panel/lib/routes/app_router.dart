import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/admin_login_screen.dart';
import '../features/comments/comments_screen.dart';
import '../features/courts/courts_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/profile/admin_profile_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/users/users_screen.dart';
final routerProvider = Provider((_) => GoRouter(routes: [GoRoute(path: '/', builder: (_,__) => const AdminLoginScreen()), ShellRoute(builder: (_,__,child)=>AdminShell(child: child), routes: [GoRoute(path: '/dashboard', builder: (_,__)=>const DashboardScreen()), GoRoute(path: '/users', builder: (_,__)=>const UsersScreen()), GoRoute(path: '/courts', builder: (_,__)=>const CourtsScreen()), GoRoute(path: '/comments', builder: (_,__)=>const CommentsScreen()), GoRoute(path: '/reports', builder: (_,__)=>const ReportsScreen()), GoRoute(path: '/profile', builder: (_,__)=>const AdminProfileScreen())]) ]));
class AdminShell extends StatelessWidget { const AdminShell({super.key, required this.child}); final Widget child; @override Widget build(BuildContext context){ final items = {'/dashboard':'Dashboard','/users':'User','/courts':'Lapangan','/comments':'Komentar','/reports':'Laporan','/profile':'Profil'}; return Scaffold(body: Row(children: [NavigationRail(extended: MediaQuery.sizeOf(context).width > 900, selectedIndex: items.keys.toList().indexWhere(GoRouterState.of(context).matchedLocation.startsWith).clamp(0, 5), onDestinationSelected: (i)=>context.go(items.keys.elementAt(i)), destinations: items.values.map((e)=>NavigationRailDestination(icon: const Icon(Icons.circle_outlined), selectedIcon: const Icon(Icons.circle), label: Text(e))).toList()), const VerticalDivider(width: 1), Expanded(child: child)])); }}
