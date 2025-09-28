import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (ctx, st) => const NoTransitionPage(child: HomePage()),
    ),
    // Ex.: detalhes de jogo
    GoRoute(
      path: '/match/:id',
      name: 'match_details',
      pageBuilder: (ctx, st) {
        final id = st.pathParameters['id']!;
        return CustomTransitionPage(
          child: Scaffold(
            appBar: AppBar(title: Text('Partida $id')),
            body: const Center(child: Text('Detalhes da partida')),
          ),
          transitionsBuilder: (c, a, sA, child) => FadeTransition(opacity: a, child: child),
        );
      },
    ),
  ],
  errorPageBuilder: (ctx, st) => MaterialPage(child: Scaffold(body: Center(child: Text(st.error.toString())))),
);
