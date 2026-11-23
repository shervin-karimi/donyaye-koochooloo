import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/child_age.dart';
import '../../widgets/page_body.dart';

typedef ParentSettings = ({int age, Locale locale});

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({required this.initialSettings, super.key});

  final ParentSettings initialSettings;

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  late int _age = widget.initialSettings.age;
  late Locale _locale = widget.initialSettings.locale;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final numbers = NumberFormat.decimalPattern(strings.localeName);
    return Scaffold(
      appBar: AppBar(title: Text(strings.parentSettings)),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.childAge, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(strings.childAgeHint),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var age = 1; age <= 10; age++)
                  ChoiceChip(
                    key: ValueKey('age-$age'),
                    label: Text(numbers.format(age)),
                    selected: _age == age,
                    onSelected: (_) => setState(() => _age = age),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(AgeGroup.forAge(_age).label(strings)),
            const SizedBox(height: 28),
            Text(strings.language, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (locale, label) in const [
                  (Locale('fa'), 'فارسی'),
                  (Locale('en'), 'English'),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: _locale == locale,
                    onSelected: (_) => setState(() => _locale = locale),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                (age: _age, locale: _locale),
              ),
              child: Text(strings.saveSettings),
            ),
          ],
        ),
      ),
    );
  }
}
