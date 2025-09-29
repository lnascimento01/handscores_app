import 'dart:async';
import 'package:flutter/material.dart';
// Se quiser vídeo, descomente e configure o player.
// import 'package:video_player/video_player.dart';

class SplashGate extends StatefulWidget {
  const SplashGate({
    super.key,
    required this.child,
    this.minDuration = const Duration(milliseconds: 1500),
    this.useVideo = false,
  });

  final Widget child;
  final Duration minDuration;
  final bool useVideo; // true para usar assets/branding/splash.mp4

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _done = false;
  Timer? _timer;

  // VideoPlayerController? _video;

  @override
  void initState() {
    super.initState();
    // Inicie qualquer bootstrap async aqui se necessário.
    _timer = Timer(widget.minDuration, () {
      if (mounted) setState(() => _done = true);
    });

    // Vídeo (opcional)
    // if (widget.useVideo) {
    //   _video = VideoPlayerController.asset('assets/branding/splash.mp4')
    //     ..initialize().then((_) {
    //       setState(() {});
    //       _video?.setLooping(false);
    //       _video?.play();
    //     })
    //     ..addListener(() {
    //       if (_video!.value.position >= (_video!.value.duration - const Duration(milliseconds: 50))) {
    //         if (mounted) setState(() => _done = true);
    //       }
    //     });
    // }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto splash ativo, cobre tela; depois libera child
    return Stack(
      children: [
        // app real
        widget.child,

        // splash
        if (!_done)
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset('assets/branding/logo_full.png'),
              ),
            ),
          ),
      ],
    );
  }
}
