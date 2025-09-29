import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/features/auth/data/state/session_providers.dart';
import 'package:go_router/go_router.dart';

class EnsureAuth extends ConsumerStatefulWidget {
  final Widget child;
  final String loginRoute; // ex: '/login'
  const EnsureAuth({super.key, required this.child, required this.loginRoute});

  @override
  ConsumerState<EnsureAuth> createState() => _EnsureAuthState();
}

class _EnsureAuthState extends ConsumerState<EnsureAuth> {
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _revalidate();
  }

  Future<void> _revalidate() async {
    setState(() => _checking = true);
    final ok = await ref.read(sessionControllerProvider.notifier).revalidate();
    if (!ok && mounted) context.go(widget.loginRoute);
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    if (_checking || session.flow == SessionFlow.booting) {
      return const SizedBox.shrink(); // seu loader global cobre a tela
    }
    if (session.flow == SessionFlow.unauthenticated) {
      // Se chegou sem auth, redireciona
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(widget.loginRoute);
      });
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}
