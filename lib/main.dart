// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/features/auth/data/state/session_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Logger depende do tipo AuthState para logar mudanças de auth
import 'package:handscore/features/auth/data/state/auth_providers.dart';

// Router/tema
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// UI auxiliares
import 'package:handscore/core/ui/global_loading.dart';
import 'package:handscore/core/ui/splash_gate.dart';

// i18n
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// (opcional) log de providers em debug — aqui filtramos só o auth
class _Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? prev,
    Object? next,
    ProviderContainer container,
  ) {
    if (provider.name?.toString().contains('authControllerProvider') == true ||
        provider.runtimeType.toString().contains('AuthController')) {
      final state = next as AuthState;
      // ignore: avoid_print
      print(
        '[auth] flow=${state.flow}'
        '${state.error != null ? ' error="${state.error}"' : ''}'
        '${state.selectedChannel != null ? ' channel=${state.selectedChannel}' : ''}'
        '${state.challengeId != null ? ' challengeId=${state.challengeId}' : ''}',
      );
    }
  }
}

/// Chaves para persistência
const _kThemeModeKey = 'theme_mode'; // valores: 'light' | 'dark' | 'system'

ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://localhost:8686/api',
  );

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kThemeModeKey);
  final initialMode = _themeModeFromString(saved);

  runApp(
    ProviderScope(
      observers: [_Logger()],
      child: HandScoreApp(prefs: prefs, initialMode: initialMode),
    ),
  );
}

class HandScoreApp extends StatefulWidget {
  const HandScoreApp({
    super.key,
    required this.prefs,
    required this.initialMode,
  });

  final SharedPreferences prefs;
  final ThemeMode initialMode;

  @override
  State<HandScoreApp> createState() => _HandScoreAppState();
}

class _HandScoreAppState extends State<HandScoreApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late ThemeMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  Future<void> _persistMode(ThemeMode mode) async {
    await widget.prefs.setString(_kThemeModeKey, _themeModeToString(mode));
  }

  Future<void> _toggleTheme() async {
    final next = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() => _mode = next);
    await _persistMode(next);
  }

  Future<void> _setSystemTheme() async {
    setState(() => _mode = ThemeMode.system);
    await _persistMode(ThemeMode.system);
    _scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(content: Text('Tema: seguindo o sistema')),
    );
  }

  Widget _buildThemeIcon(BuildContext context) {
    final isSystem = _mode == ThemeMode.system;
    final IconData baseIcon = isSystem
        ? Icons.brightness_auto
        : (_mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode);
    final Widget iconWidget = Icon(baseIcon);

    if (!isSystem) return iconWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'A',
              style: TextStyle(fontSize: 8, color: Colors.white, height: 1),
            ),
          ),
        ),
      ],
    );
  }

  String _tooltipText(BuildContext context) {
    if (_mode == ThemeMode.system) {
      final systemIsDark =
          MediaQuery.of(context).platformBrightness == Brightness.dark;
      return 'Seguindo o sistema: ${systemIsDark ? 'Escuro' : 'Claro'} (toque: alterna; segure: Sistema)';
    }
    return _mode == ThemeMode.dark
        ? 'Tema atual: Escuro (toque: Claro; segure: Sistema)'
        : 'Tema atual: Claro (toque: Escuro; segure: Sistema)';
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

      // snackbar global
      scaffoldMessengerKey: _scaffoldMessengerKey,

      builder: (ctx, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) {
                return SplashGate(
                  useVideo: false,
                  minDuration: const Duration(milliseconds: 1500),
                  child: Consumer(
                    builder: (context, ref, _) {
                      ref.listenManual(
                        sessionControllerProvider,
                        (_, __) {},
                      ); // força inicialização
                      // dispara bootstrap 1x
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(sessionControllerProvider.notifier)
                            .bootstrap();
                      });

                      return Stack(
                        children: [
                          if (child != null) child,
                          const GlobalLoadingOverlay(),
                          // FAB ...
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
