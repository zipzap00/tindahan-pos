import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_pos/core/l10n/language.dart';
import 'package:tindahan_pos/core/l10n/strings_en.dart';
import 'package:tindahan_pos/core/theme/tokens.dart';
import 'package:tindahan_pos/ui/screens/auth/status_screens.dart';
import 'package:tindahan_pos/ui/widgets/brand.dart';
import 'package:tindahan_pos/ui/widgets/layout.dart';

Widget _app(Widget home, {bool disableAnimations = false}) {
  return LanguageScope(
    controller: LanguageController(AppLanguage.en),
    child: MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: home,
    ),
  );
}

StoreMarkPainter _mark(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(of: find.byType(AppLogoMark), matching: find.byType(CustomPaint)),
  );
  return paint.painter! as StoreMarkPainter;
}

void main() {
  group('loading screen', () {
    testWidgets('starts from the closed store and finishes open', (tester) async {
      await tester.pumpWidget(_app(const SplashScreen()));
      expect(_mark(tester).awning, 0);
      expect(_mark(tester).lights, 0);

      await tester.pump(SplashScreen.openingDuration);
      await tester.pump();
      expect(_mark(tester).awning, 1);
      expect(_mark(tester).lights, 1);
    });

    testWidgets('shows the open store at once when animations are off', (tester) async {
      await tester.pumpWidget(_app(const SplashScreen(), disableAnimations: true));
      expect(_mark(tester).awning, 1);
      expect(_mark(tester).lights, 1);
    });

    testWidgets('keeps the store front centred, where the launch images put it', (tester) async {
      await tester.pumpWidget(_app(const SplashScreen()));
      final screen = tester.getCenter(find.byType(Scaffold));
      expect(tester.getCenter(find.byType(AppLogoMark)), screen);
      expect(tester.getSize(find.byType(AppLogoMark)).height, SplashScreen.markHeight);
    });

    testWidgets('announces the opening message', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const SplashScreen()));
      expect(find.bySemanticsLabel(const EnStrings().openingStore), findsOneWidget);
      handle.dispose();
    });
  });

  group('logo', () {
    testWidgets('has the app name for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const Scaffold(body: Center(child: AppLogo()))));
      expect(find.bySemanticsLabel(const EnStrings().appName), findsOneWidget);
      handle.dispose();
    });

    testWidgets('keeps its proportions at any height', (tester) async {
      await tester.pumpWidget(_app(const Scaffold(body: Center(child: AppLogo(height: 100)))));
      final mark = tester.getSize(find.byType(AppLogoMark));
      final word = tester.getSize(find.byType(AppWordmark));
      expect(mark.width / mark.height, closeTo(StoreMarkPainter.aspectRatio, 0.001));
      expect(word.height, closeTo(100 * AppLogo.wordRatio, 0.001));
    });
  });

  group('AppViewport', () {
    Future<Size> sizeSeenAt(WidgetTester tester, double width) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.reset);
      late Size seen;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => AppViewport(child: child!),
          home: Builder(
            builder: (context) {
              seen = MediaQuery.sizeOf(context);
              return const SizedBox.expand();
            },
          ),
        ),
      );
      return seen;
    }

    testWidgets('leaves a phone screen alone', (tester) async {
      expect((await sizeSeenAt(tester, 390)).width, 390);
    });

    testWidgets('holds a wide window to one column', (tester) async {
      expect((await sizeSeenAt(tester, 1280)).width, AppSpace.maxContentWidth);
    });
  });
}
