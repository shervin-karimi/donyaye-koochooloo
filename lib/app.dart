import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';
import 'features/parents/parent_settings_screen.dart';
import 'l10n/app_localizations.dart';
import 'models/child_age.dart';

class DonyayeKoochoolooApp extends StatefulWidget {
  const DonyayeKoochoolooApp({super.key});

  @override
  State<DonyayeKoochoolooApp> createState() => _DonyayeKoochoolooAppState();
}

class _DonyayeKoochoolooAppState extends State<DonyayeKoochoolooApp> {
  // Session-only preferences. No child data is written to disk or sent anywhere.
  ParentSettings _settings = (age: 3, locale: const Locale('fa'));

  Future<void> _openSettings(BuildContext context) async {
    final settings = await Navigator.of(context).push<ParentSettings>(
      MaterialPageRoute<ParentSettings>(
        builder: (_) => ParentSettingsScreen(initialSettings: _settings),
      ),
    );
    if (!mounted || settings == null) return;
    setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: _settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6542B6)),
        scaffoldBackgroundColor: const Color(0xFFFFFAF4),
      ),
      home: Builder(
        builder: (context) => HomeScreen(
          ageGroup: AgeGroup.forAge(_settings.age),
          onOpenSettings: () => _openSettings(context),
        ),
      ),
    );
  }
}
