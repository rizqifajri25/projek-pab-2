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
import '../core/providers.dart';
import '../core/theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const AdminLoginScreen()),
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/users', builder: (_, __) => const UsersScreen()),
          GoRoute(path: '/courts', builder: (_, __) => const CourtsScreen()),
          GoRoute(path: '/comments', builder: (_, __) => const CommentsScreen()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const AdminProfileScreen()),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authState.maybeWhen(data: (user) => user != null, orElse: () => false);
      final loggingIn = state.uri.path == '/';

      if (!loggedIn && !loggingIn) {
        return '/';
      }
      if (loggedIn && loggingIn) {
        return '/dashboard';
      }
      return null;
    },
  );
});

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'path': '/dashboard', 'label': 'Dashboard', 'icon': Icons.dashboard_outlined, 'selectedIcon': Icons.dashboard},
      {'path': '/users', 'label': 'User', 'icon': Icons.people_outline, 'selectedIcon': Icons.people},
      {'path': '/courts', 'label': 'Lapangan', 'icon': Icons.sports_tennis_outlined, 'selectedIcon': Icons.sports_tennis},
      {'path': '/comments', 'label': 'Komentar', 'icon': Icons.comment_outlined, 'selectedIcon': Icons.comment},
      {'path': '/reports', 'label': 'Laporan', 'icon': Icons.flag_outlined, 'selectedIcon': Icons.flag},
      {'path': '/profile', 'label': 'Profil', 'icon': Icons.admin_panel_settings_outlined, 'selectedIcon': Icons.admin_panel_settings},
    ];

    final currentLocation = GoRouterState.of(context).matchedLocation;
    final currentIndex = items.indexWhere((item) => currentLocation.startsWith(item['path'] as String)).clamp(0, items.length - 1);

    return Container(
      decoration: const BoxDecoration(gradient: AdminTheme.appGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width > 900,
              selectedIndex: currentIndex,
              onDestinationSelected: (i) => context.go(items[i]['path'] as String),
              destinations: items
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item['icon'] as IconData),
                        selectedIcon: Icon(item['selectedIcon'] as IconData),
                        label: Text(item['label'] as String),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
