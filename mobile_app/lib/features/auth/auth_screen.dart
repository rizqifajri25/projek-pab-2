import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../repositories/providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(authStateProvider).when(
        data: (user) {
          WidgetsBinding.instance.addPostFrameCallback((_) => context.go(user == null ? '/login' : '/home'));
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      );
}

class AuthScreen extends ConsumerStatefulWidget { const AuthScreen({super.key}); @override ConsumerState<AuthScreen> createState() => _AuthScreenState(); }
class _AuthScreenState extends ConsumerState<AuthScreen> {
  final name = TextEditingController(), email = TextEditingController(), password = TextEditingController();
  bool register = false, loading = false;
  Future<void> submit() async {
    setState(() => loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      if (register) { await repo.register(name: name.text.trim(), email: email.text.trim(), password: password.text); } else { await repo.login(email.text.trim(), password.text); }
      if (mounted) context.go('/home');
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); } finally { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Card(margin: const EdgeInsets.all(24), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.sports_tennis, size: 64, color: Color(0xFF0D9488)), Text('PadelFinder', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 24),
    if (register) TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
    const SizedBox(height: 12), TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
    const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => ref.read(authRepositoryProvider).resetPassword(email.text.trim()), child: const Text('Reset password'))),
    FilledButton(onPressed: loading ? null : submit, child: Text(register ? 'Register' : 'Login')), TextButton(onPressed: () => setState(() => register = !register), child: Text(register ? 'Sudah punya akun? Login' : 'Belum punya akun? Register')),
  ])))));
}
