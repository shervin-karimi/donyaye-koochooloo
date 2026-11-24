import 'package:donyaye_koochooloo/app.dart';
import 'package:donyaye_koochooloo/models/child_age.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _animal(String name) => find.byKey(ValueKey('animal-$name'));

void main() {
  test('each age from 1 through 10 maps to the right group', () {
    expect(
      [for (var age = 1; age <= 10; age++) AgeGroup.forAge(age)],
      [
        ...List.filled(3, AgeGroup.young),
        ...List.filled(3, AgeGroup.middle),
        ...List.filled(4, AgeGroup.older),
      ],
    );
    expect(AgeGroup.values.map((group) => group.animalChoices), [2, 3, 4]);
  });

  testWidgets('defaults to Persian RTL and opens offline media and stories', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DonyayeKoochoolooApp());
    await tester.pumpAndSettle();

    final title = find.text('دنیای کوچولوها');
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
    expect(find.text('۱ تا ۳ سال'), findsOneWidget);
    final originalPlayer = VideoPlayerPlatform.instance;
    final player = _TestMediaPlayer();
    VideoPlayerPlatform.instance = player;
    addTearDown(() => VideoPlayerPlatform.instance = originalPlayer);

    for (final (category, heading, asset) in [
      ('آهنگ‌های کودکانه', 'آهنگ شاد', 'happy.mp3'),
      ('لالایی‌ها', 'آهنگ خواب', 'bedtime.mp3'),
      ('رنگ‌ها', 'رنگ‌ها', 'colors.mp4'),
    ]) {
      await _tap(tester, find.text(category));
      expect(find.text(heading).hitTestable(), findsOneWidget);
      final play = find.widgetWithText(FilledButton, 'پخش');
      await _tap(tester, play);
      expect(player.asset, 'assets/media/$asset');
      expect(player.playing, isTrue);
      if (asset == 'colors.mp4') expect(find.text('قرمز'), findsOneWidget);

      await _tap(tester, find.widgetWithText(FilledButton, 'مکث'));
      expect(player.playing, isFalse);
      await _tap(tester, play);
      expect(player.playing, isTrue);
      await _tap(tester, find.byType(BackButton));
      expect(title, findsOneWidget);
    }
    await _tap(tester, find.text('قصه‌های آموزشی'));
    expect(find.text('به‌زودی!'), findsOneWidget);
    expect(find.text('حیوان رو پیدا کن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('parent settings switch language and set game difficulty', (
    tester,
  ) async {
    await tester.pumpWidget(const DonyayeKoochoolooApp());
    await tester.pumpAndSettle();
    await _tap(tester, find.byTooltip('تنظیمات والدین'));
    await _tap(tester, find.byKey(const ValueKey('age-10')));
    await _tap(tester, find.text('English'));
    await _tap(tester, find.text('انجام شد'));

    final title = find.text('Donyaye Koochooloo');
    expect(Directionality.of(tester.element(title)), TextDirection.ltr);
    expect(find.text('Ages 7–10'), findsOneWidget);
    await _tap(tester, find.text('Educational games'));
    expect(find.text('Can you find the cat?'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is FilledButton && widget.key != null,
      ),
      findsNWidgets(4),
    );
  });

  testWidgets('can retry a wrong answer, finish the game, and play again', (
    tester,
  ) async {
    await tester.pumpWidget(const DonyayeKoochoolooApp());
    await tester.pumpAndSettle();
    await _tap(tester, find.text('بازی‌های آموزشی'));

    await _tap(tester, _animal('rabbit'));
    expect(find.text('خوب تلاش کردی! یه حیوان دیگه رو انتخاب کن.'), findsOneWidget);
    expect(find.text('حیوان بعدی'), findsNothing);
    for (final name in ['cat', 'rabbit', 'frog', 'dog']) {
      await _tap(tester, _animal(name));
      expect(find.text('آفرین! پیداش کردی!'), findsOneWidget);
      final action = name == 'dog' ? 'پایان بازی' : 'حیوان بعدی';
      await _tap(tester, find.text(action));
    }
    expect(find.text('همهٔ حیوان‌ها رو پیدا کردی!'), findsOneWidget);
    await _tap(tester, find.text('دوباره بازی کن'));
    expect(find.text('می‌تونی گربه رو پیدا کنی؟'), findsOneWidget);
    expect(find.text('آفرین! پیداش کردی!'), findsNothing);
  });
}

class _TestMediaPlayer extends VideoPlayerPlatform {
  String? asset;
  bool playing = false;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    asset = dataSource.asset;
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => Stream.value(
    VideoEvent(
      eventType: VideoEventType.initialized,
      duration: const Duration(seconds: 12),
      size: asset!.endsWith('.mp3') ? Size.zero : const Size(320, 240),
    ),
  );

  @override
  Widget buildView(int playerId) => const SizedBox.shrink();

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Future<void> play(int playerId) async => playing = true;

  @override
  Future<void> pause(int playerId) async => playing = false;

  @override
  Future<void> dispose(int playerId) async => asset = null;
}
