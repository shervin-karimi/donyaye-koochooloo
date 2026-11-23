import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/page_body.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    required this.title,
    required this.icon,
    required this.onPlay,
    super.key,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PageBody(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Icon(icon, color: theme.colorScheme.primary, size: 72),
            const SizedBox(height: 16),
            Text(
              strings.comingSoon,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(strings.comingSoonHint, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: onPlay, child: Text(strings.findAnimal)),
          ],
        ),
      ),
    );
  }
}
