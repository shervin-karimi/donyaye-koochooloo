import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/page_body.dart';

enum OfflineMedia {
  happy(
    'happy.mp3',
    Icons.music_note_rounded,
    Color(0xFFFFDFE8),
    Color(0xFF96264A),
  ),
  bedtime(
    'bedtime.mp3',
    Icons.bedtime_rounded,
    Color(0xFFE9DFFF),
    Color(0xFF5F3E9F),
  ),
  colors(
    'colors.mp4',
    Icons.palette_rounded,
    Color(0xFFDDEEFF),
    Color(0xFF204D84),
  );

  const OfflineMedia(this.file, this.icon, this.surface, this.ink);

  final String file;
  final IconData icon;
  final Color surface;
  final Color ink;

  String title(AppLocalizations strings) => switch (this) {
    happy => strings.happyMusic,
    bedtime => strings.bedtimeMusic,
    colors => strings.colorsVideo,
  };
}

class OfflineMediaScreen extends StatefulWidget {
  const OfflineMediaScreen({required this.media, super.key});

  final OfflineMedia media;

  @override
  State<OfflineMediaScreen> createState() => _OfflineMediaScreenState();
}

class _OfflineMediaScreenState extends State<OfflineMediaScreen> {
  VideoPlayerController? _controller;
  bool _busy = false;
  bool _failed = false;

  Future<void> _toggle() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      if (_controller?.value.hasError ?? false) {
        final failed = _controller;
        _controller = null;
        await failed?.dispose();
        if (!mounted) return;
      }
      // Android's Media3 backend also plays the audio-only MP3 assets.
      final controller = _controller ??= VideoPlayerController.asset(
        'assets/media/${widget.media.file}',
      );
      if (!controller.value.isInitialized) await controller.initialize();
      if (!mounted) return;
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        if (controller.value.isCompleted) {
          await controller.seekTo(Duration.zero);
        }
        if (mounted) await controller.play();
      }
    } catch (_) {
      final failed = _controller;
      _controller = null;
      if (mounted) setState(() => _failed = true);
      await failed?.dispose();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    _controller = null;
    unawaited(controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.media.title(strings)),
      ),
      body: PageBody(
        child: controller == null
            ? _content(strings)
            : ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, _, _) => _content(strings, controller),
              ),
      ),
    );
  }

  Widget _content(
    AppLocalizations strings, [
    VideoPlayerController? controller,
  ]) {
    final value = controller?.value;
    final initialized = value?.isInitialized ?? false;
    final playing = value?.isPlaying ?? false;
    final media = widget.media;
    final colors = [
      strings.colorRed,
      strings.colorBlue,
      strings.colorYellow,
      strings.colorGreen,
    ];
    // Each of the four color scenes lasts three seconds.
    final scene = ((value?.position.inMilliseconds ?? 0) ~/ 3000).clamp(0, 3);
    return Column(
      children: [
        if (media == OfflineMedia.colors) ...[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: initialized
                      ? VideoPlayer(controller!)
                      : const ColoredBox(
                          color: Color(0xFFDDEEFF),
                          child: Icon(Icons.palette_rounded, size: 90),
                        ),
                ),
              ),
            ),
          ),
          if (initialized)
            Text(
              colors[scene],
              style: Theme.of(context).textTheme.headlineMedium,
            ),
        ] else ...[
          const SizedBox(height: 28),
          CircleAvatar(
            radius: 86,
            backgroundColor: media.surface,
            foregroundColor: media.ink,
            child: Icon(media.icon, size: 90),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size(160, 64)),
          onPressed: _busy ? null : _toggle,
          icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
          label: Text(playing ? strings.mediaPause : strings.mediaPlay),
        ),
        if (_failed || (value?.hasError ?? false)) Text(strings.mediaError),
      ],
    );
  }
}
