import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_pos/app.dart';

// Signing in or out passes through several screens faster than the fade, so
// more than one screen is fading out at once.
class _One extends StatelessWidget {
  const _One();

  @override
  Widget build(BuildContext context) => const Text('one');
}

class _Two extends StatelessWidget {
  const _Two();

  @override
  Widget build(BuildContext context) => const Text('two');
}

class _Home extends StatelessWidget {
  const _Home({super.key});

  @override
  Widget build(BuildContext context) => const Text('home');
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  @override
  Widget build(BuildContext context) => const Text('counter');
}

Widget _app(Object identity, Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: ScreenSwitcher(identity: identity, child: child),
    );

void main() {
  // Welcome -> loading -> home: two unkeyed screens fading out together while
  // the keyed home screen comes in. This is what showed the red error page.
  testWidgets('signing in faster than the fade does not crash', (tester) async {
    const home = ValueKey<String>('home');
    await tester.pumpWidget(_app(_One, const _One()));
    await tester.pumpWidget(_app(_Two, const _Two()));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(_app(home, const _Home(key: home)));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(find.text('one'), findsNothing);
    expect(find.text('two'), findsNothing);
  });

  testWidgets('a screen coming back during the fade does not crash', (tester) async {
    await tester.pumpWidget(_app(_One, const _One()));
    await tester.pumpWidget(_app(_Two, const _Two()));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(_app(_One, const _One()));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(_app(_Two, const _Two()));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(find.text('two'), findsOneWidget);
    expect(find.text('one'), findsNothing);
  });

  testWidgets('the same screen keeps its state on rebuild', (tester) async {
    await tester.pumpWidget(_app(_Counter, const _Counter()));
    final state = tester.state(find.byType(_Counter));
    await tester.pumpWidget(_app(_Counter, const _Counter()));
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(_Counter)), same(state));
  });
}
