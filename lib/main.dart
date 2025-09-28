// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// i18n
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// (opcional) log de providers em debug
class _Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? prev,
    Object? next,
    ProviderContainer container,
  ) {
    assert(() {
      // ignore: avoid_print
      print('[provider] ${provider.name ?? provider.runtimeType} => $next');
      return true;
    }());
    super.didUpdateProvider(provider, prev, next, container);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://localhost:8686/api',
  );
  runApp(
    ProviderScope(
      observers: [_Logger()], // remova em produção se quiser
      child: const HandScoreApp(),
    ),
  );
}

class HandScoreApp extends StatefulWidget {
  const HandScoreApp({super.key});

  @override
  State<HandScoreApp> createState() => _HandScoreAppState();
}

class _HandScoreAppState extends State<HandScoreApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  ThemeMode _mode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HandScore',
      themeMode: _mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,

      // i18n
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,

      // snackbar global (para erros de auth, etc.)
      scaffoldMessengerKey: _scaffoldMessengerKey,

      builder: (ctx, child) {
        return Stack(
          children: [
            if (child != null) child,
            Positioned(
              right: 16,
              bottom: 96,
              child: FloatingActionButton.small(
                onPressed: _toggleTheme,
                child: Icon(
                  _mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
