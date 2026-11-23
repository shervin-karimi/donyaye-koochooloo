import '../../l10n/app_localizations.dart';

enum Animal {
  cat('🐱'),
  rabbit('🐰'),
  frog('🐸'),
  dog('🐶'),
  lion('🦁'),
  owl('🦉');

  const Animal(this.emoji);

  final String emoji;

  String label(AppLocalizations strings) => switch (this) {
    cat => strings.animalCat,
    rabbit => strings.animalRabbit,
    frog => strings.animalFrog,
    dog => strings.animalDog,
    lion => strings.animalLion,
    owl => strings.animalOwl,
  };
}
