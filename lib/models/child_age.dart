import '../l10n/app_localizations.dart';

enum AgeGroup {
  young(1, 3, 2),
  middle(4, 6, 3),
  older(7, 10, 4);

  const AgeGroup(this.minAge, this.maxAge, this.animalChoices);

  final int minAge;
  final int maxAge;
  final int animalChoices;

  static AgeGroup forAge(int age) =>
      values.firstWhere((group) => age >= group.minAge && age <= group.maxAge);

  String label(AppLocalizations strings) => switch (this) {
    young => strings.ageGroupYoung,
    middle => strings.ageGroupMiddle,
    older => strings.ageGroupOlder,
  };
}
