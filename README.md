# Donyaye Koochooloo · دنیای کوچولوها

A Persian-first, offline Android app for children ages 1–10. The home
screen defaults to Persian (RTL). Open the gear icon to choose an age or switch
to English. Settings apply for the current session only; the parent screen is a
separate settings area, not a parental lock.

**Find the Animal** is a four-round game with two choices for ages 1–3,
three for ages 4–6, and four for ages 7–10. Children ages 1–6 also get a
picture clue, so they can play without reading.
The songs and lullabies screens each play an original instrumental melody offline.
**Colors** has a short offline animation with names in both app languages.
Educational stories still have a placeholder screen.
The app uses system emoji and Material icons and has no accounts, backend, ads,
analytics, or stored child profile.

## Get the debug APK

The **Android Debug APK** workflow runs on pushes to `develop` and pull
requests targeting `develop`. Once the workflow also exists on the repository’s
default branch, it can be run manually from **Actions → Android Debug APK →
Run workflow**; select `develop` in the branch picker.

Open the successful run and download **donyaye-koochooloo-debug-apk** under
**Artifacts**. Extract `app-debug.apk` from the ZIP and install it on the tablet.
Android may ask you to allow installs from the app you used to open the APK.
This is a debug build for testing, not a production release.

## Project layout and verification

- `lib/features/` contains the home, parent settings, and game screens.
- `lib/models/` defines the age bands. `lib/widgets/` contains shared layout.
- `lib/l10n/` contains the Persian and English ARB translations. Flutter
  generates the localization Dart files; edit the ARBs, not the generated files.
- `test/` covers age grouping, language and layout direction, activity
  navigation, and gameplay.

No local Flutter SDK is required on the Termux tablet. The workflow runs the
following commands with stable Flutter on a GitHub-hosted runner. The explicit
Dart name works even though the repository directory contains hyphens.

```sh
flutter create --template=app --empty --platforms=android \
  --project-name=donyaye_koochooloo --org=com.donyayekoochooloo \
  --no-pub --no-overwrite .
flutter pub get
flutter gen-l10n
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
```

Android platform files are generated, with the custom launcher icons tracked in
`android/app/src/main/res/`.
