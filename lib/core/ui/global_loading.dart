import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final globalLoadingProvider =
    StateNotifierProvider<GlobalLoadingController, int>(
      (ref) => GlobalLoadingController(),
    );

class GlobalLoadingController extends StateNotifier<int> {
  GlobalLoadingController() : super(0);
  void begin() => state = state + 1;
  void end() => state = state > 0 ? state - 1 : 0;
}

/// Overlay global que cobre a tela toda e bloqueia interação.
class GlobalLoadingOverlay extends ConsumerWidget {
  const GlobalLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(globalLoadingProvider);
    if (pending <= 0) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      type: MaterialType.transparency,
      child: IgnorePointer(
        ignoring: false,
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 120),
          child: Stack(
            children: [
              // Fundo escuro (70% opaco)
              const Positioned.fill(
                child: ColoredBox(color: Color(0xB3000000)),
              ),

              // Conteúdo central
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: AspectRatio(
                                aspectRatio: 1.5 / 3,
                                child: Image.asset(
                                  'assets/branding/loading.gif',
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
