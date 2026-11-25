import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/child_age.dart';
import '../../widgets/page_body.dart';
import '../animals/find_animal_screen.dart';
import '../media/offline_media_screen.dart';
import 'coming_soon_screen.dart';

enum Activity {
  songs(Icons.music_note_rounded, Color(0xFFFFDFE8), Color(0xFF96264A)),
  lullabies(Icons.nightlight_round, Color(0xFFE9DFFF), Color(0xFF5F3E9F)),
  stories(Icons.auto_stories_rounded, Color(0xFFFFE7B8), Color(0xFF805000)),
  games(Icons.extension_rounded, Color(0xFFCEEFE0), Color(0xFF1C674D)),
  colors(Icons.palette_rounded, Color(0xFFDDEEFF), Color(0xFF204D84));

  const Activity(this.icon, this.surface, this.ink);

  final IconData icon;
  final Color surface;
  final Color ink;

  String title(AppLocalizations strings) => switch (this) {
    songs => strings.songs,
    lullabies => strings.lullabies,
    stories => strings.stories,
    games => strings.games,
    colors => strings.colorsVideo,
  };

  String hint(AppLocalizations strings) => switch (this) {
    songs => strings.songsHint,
    lullabies => strings.lullabiesHint,
    stories => strings.storiesHint,
    games => strings.gamesHint,
    colors => strings.colorsVideoHint,
  };
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.ageGroup,
    required this.onOpenSettings,
    super.key,
  });

  final AgeGroup ageGroup;
  final VoidCallback onOpenSettings;

  void _openActivity(BuildContext context, Activity activity) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => switch (activity) {
          Activity.games => FindAnimalScreen(ageGroup: ageGroup),
          Activity.songs => const OfflineMediaScreen(media: OfflineMedia.happy),
          Activity.lullabies => const OfflineMediaScreen(media: OfflineMedia.bedtime),
          Activity.colors => const OfflineMediaScreen(media: OfflineMedia.colors),
          Activity.stories => ComingSoonScreen(
            title: activity.title(AppLocalizations.of(context)!),
            icon: activity.icon,
            onPlay: () => Navigator.of(context).pushReplacement<void, void>(
              MaterialPageRoute<void>(
                builder: (_) => FindAnimalScreen(ageGroup: ageGroup),
              ),
            ),
          ),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            tooltip: strings.parentSettings,
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeBanner(strings: strings, ageGroup: ageGroup),
            const SizedBox(height: 28),
            Text(
              strings.chooseActivity,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final width = constraints.maxWidth;
                final tileWidth = width >= 520 ? (width - gap) / 2 : width;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final activity in Activity.values)
                      SizedBox(
                        width: tileWidth,
                        child: _ActivityTile(
                          activity: activity,
                          onTap: () => _openActivity(context, activity),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.strings, required this.ageGroup});

  final AppLocalizations strings;
  final AgeGroup ageGroup;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5634A5), Color(0xFF752B83)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFFFDE8A),
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            strings.homeGreeting,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.homeIntro,
            style: textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFFDE8A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                ageGroup.label(strings),
                style: textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF40235E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.onTap});

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: activity.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                foregroundColor: activity.ink,
                child: Icon(activity.icon, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title(strings),
                      style: textTheme.titleMedium?.copyWith(
                        color: activity.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      activity.hint(strings),
                      style: textTheme.bodyMedium?.copyWith(color: activity.ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: activity.ink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
