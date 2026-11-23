import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/child_age.dart';
import '../../widgets/page_body.dart';
import 'animal.dart';

class FindAnimalScreen extends StatefulWidget {
  const FindAnimalScreen({required this.ageGroup, super.key});

  final AgeGroup ageGroup;

  @override
  State<FindAnimalScreen> createState() => _FindAnimalScreenState();
}

class _FindAnimalScreenState extends State<FindAnimalScreen> {
  static const _targets = [Animal.cat, Animal.rabbit, Animal.frog, Animal.dog];

  int _round = 0;
  Animal? _selected;
  late List<Animal> _choices = _choicesFor(_targets.first);

  List<Animal> _choicesFor(Animal target) => [
    for (var offset = 0; offset < widget.ageGroup.animalChoices; offset++)
      Animal.values[(target.index + offset) % Animal.values.length],
  ]..shuffle();

  void _goToRound(int round) {
    setState(() {
      _round = round;
      _selected = null;
      if (round < _targets.length) _choices = _choicesFor(_targets[round]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final finished = _round == _targets.length;
    return Scaffold(
      appBar: AppBar(title: Text(strings.findAnimal)),
      body: PageBody(
        child: finished
            ? Column(
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.emoji_events_rounded,
                    color: theme.colorScheme.primary,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      strings.gameComplete,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => _goToRound(0),
                    child: Text(strings.playAgain),
                  ),
                ],
              )
            : _buildRound(context, strings),
      ),
    );
  }

  Widget _buildRound(BuildContext context, AppLocalizations strings) {
    final theme = Theme.of(context);
    final target = _targets[_round];
    final correct = _selected == target;
    return Column(
      children: [
        Text(
          strings.roundProgress(_round + 1, _targets.length),
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: LinearProgressIndicator(
            value: (_round + (correct ? 1 : 0)) / _targets.length,
          ),
        ),
        const SizedBox(height: 20),
        if (widget.ageGroup != AgeGroup.older) ...[
          ExcludeSemantics(
            child: Text(target.emoji, style: const TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          strings.findAnimalPrompt(target.label(strings)),
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            final columns = constraints.maxWidth >= 560 ? _choices.length : 2;
            final width = ((constraints.maxWidth - gap * (columns - 1)) / columns)
                .floorToDouble();
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final animal in _choices)
                  SizedBox(
                    width: width,
                    child: FilledButton.tonal(
                      key: ValueKey('animal-${animal.name}'),
                      onPressed: correct
                          ? null
                          : () => setState(() => _selected = animal),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 96),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Semantics(
                        label: animal.label(strings),
                        excludeSemantics: true,
                        child: Text(
                          animal.emoji,
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        if (_selected != null) ...[
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              correct ? strings.correctAnswer : strings.wrongAnswer,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (correct) ...[
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => _goToRound(_round + 1),
            child: Text(
              _round + 1 == _targets.length
                  ? strings.finishGame
                  : strings.nextRound,
            ),
          ),
        ],
      ],
    );
  }
}
