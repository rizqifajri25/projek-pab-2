import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../features/auth/auth_screen.dart';
import '../features/detail/court_detail_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/posting/post_court_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/search/search_screen.dart';
import '../providers/user_provider.dart';
import '../repositories/providers.dart';

bool _accountDialogOpen = false;

final routerProvider = Provider<GoRouter>((ref) => GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const AuthGate()),
      GoRoute(path: '/login', builder: (_, __) => const AuthScreen()),
      ShellRoute(builder: (_, __, child) => MobileScaffold(child: child), routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/post', builder: (_, __) => const PostCourtScreen()),
        GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
        GoRoute(path: '/court/:id', builder: (_, state) => CourtDetailScreen(courtId: state.pathParameters['id']!)),
      ]),
    ]));

class MobileScaffold extends ConsumerWidget {
  const MobileScaffold({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentUserProvider, (previous, next) {
      next.whenData((user) {
        if ((user == null || user.status != 'active') && !_accountDialogOpen) {
          _accountDialogOpen = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              _accountDialogOpen = false;
              return;
            }
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                icon: const Icon(Icons.block, color: Colors.red),
                title: Text(user == null ? 'Akun tidak tersedia' : 'Akun dinonaktifkan'),
                content: Text(user == null
                    ? 'Akun Anda telah dihapus oleh admin. Tekan tombol di bawah untuk keluar.'
                    : 'Akun Anda saat ini berstatus ${user.status}. Tekan tombol di bawah untuk keluar dari akun.'),
                actions: [
                  FilledButton(
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).logout();
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                      _accountDialogOpen = false;
                      if (context.mounted) context.go('/login');
                    },
                    child: const Text('Keluar dari akun'),
                  ),
                ],
              ),
            );
          });
        }
      });
    });

    final location = GoRouterState.of(context).matchedLocation;
    final routes = ['/home', '/search', '/post', '/favorites', '/profile'];
    final index = routes.indexWhere(location.startsWith);
    return Scaffold(
        // gradient background container
        body: Container(
          decoration: BoxDecoration(gradient: ref.watch(darkModeProvider) ? AppTheme.darkGradient : AppTheme.appGradient),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: index < 0 ? 0 : index,
              onDestinationSelected: (i) => context.go(routes[i]),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                NavigationDestination(icon: Icon(Icons.add_location_alt_outlined), selectedIcon: Icon(Icons.add_location_alt), label: 'Posting'),
                NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favorit'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
              ],
            ),
          ),
        ),
    );
  }
}
