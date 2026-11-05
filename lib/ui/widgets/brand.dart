import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/language.dart';
import '../../core/theme/tokens.dart';

/// The Tindahan brand, drawn as vector paths rather than shipped as an image,
/// so it stays sharp at every size and pixel density. The app icons and launch
/// images are rendered from these same painters by
/// `tool/generate_brand_assets.dart`, so there is one source of the artwork.

/// Colours of the store-front mark.
class MarkColors {
  const MarkColors({
    required this.frame,
    required this.stripeA,
    required this.stripeB,
    required this.coin,
    required this.peso,
    required this.lightsOff,
    this.awningOff = AppColors.brandOff,
  });

  /// On the light canvas: a deep mint store with mint and sky stripes.
  static const MarkColors onLight = MarkColors(
    frame: AppColors.brandDeep,
    stripeA: AppColors.primary,
    stripeB: AppColors.info,
    coin: AppColors.onPrimary,
    peso: AppColors.brandDeep,
    lightsOff: AppColors.primary,
  );

  /// On a mint tile (the app icon), where mint parts would disappear.
  static const MarkColors onMint = MarkColors(
    frame: AppColors.onPrimary,
    stripeA: AppColors.info,
    stripeB: AppColors.onPrimary,
    coin: AppColors.primary,
    peso: AppColors.onPrimary,
    lightsOff: AppColors.brandPale,
  );

  /// Rail and store body.
  final Color frame;
  final Color stripeA;
  final Color stripeB;

  /// The coin in the hatch and the peso sign on it.
  final Color coin;
  final Color peso;

  /// Coin colour before the store opens. The peso sign fades in from it.
  final Color lightsOff;

  /// The rolled-up awning's outline, so the closed store still reads as a store
  /// while it waits (on the web that can be several seconds).
  final Color awningOff;
}

/// Sari-sari store front: rail, five-stripe awning, and a soft body with a
/// peso coin in the hatch.
///
/// [awning] and [lights] run 0 to 1. The loading screen animates them to open
/// the store; at 1 and 1 this is the finished logo.
class StoreMarkPainter extends CustomPainter {
  const StoreMarkPainter({this.colors = MarkColors.onLight, this.awning = 1, this.lights = 1});

  /// The artwork's own coordinates. Everything below is in these units.
  static const double artWidth = 260;
  static const double artHeight = 236;
  static const double aspectRatio = artWidth / artHeight;

  static const int _stripes = 5;

  /// How many stripes' worth of the timeline each stripe takes to unroll.
  static const double _unrollSpan = 2;

  final MarkColors colors;
  final double awning;
  final double lights;

  static Path _stripe(int index) {
    const topLeft = 30.0;
    const topWidth = 200.0 / _stripes;
    const bottomLeft = 5.0;
    const bottomWidth = 250.0 / _stripes;
    const top = 14.0;
    const bottom = 92.0;
    const scallop = 25.0;
    return Path()
      ..moveTo(topLeft + topWidth * index, top)
      ..lineTo(topLeft + topWidth * (index + 1), top)
      ..lineTo(bottomLeft + bottomWidth * (index + 1), bottom)
      ..arcToPoint(
        Offset(bottomLeft + bottomWidth * index, bottom),
        radius: const Radius.elliptical(bottomWidth / 2, scallop),
      )
      ..close();
  }

  void _paintStripe(Canvas canvas, int index, Paint paint, Paint off) {
    final total = (_stripes - 1 + _unrollSpan) * awning.clamp(0.0, 1.0);
    final progress = ((total - index) / _unrollSpan).clamp(0.0, 1.0);
    if (progress < 1) canvas.drawPath(_stripe(index), off);
    if (progress <= 0) return;
    canvas.save();
    // Unroll downwards from the rail, with a small settle at the end.
    canvas.translate(0, 14);
    canvas.scale(1, progress >= 1 ? 1 : Curves.easeOutBack.transform(progress));
    canvas.translate(0, -14);
    canvas.drawPath(_stripe(index), paint);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / artWidth, size.height / artHeight);
    canvas.save();
    canvas.translate((size.width - artWidth * scale) / 2, (size.height - artHeight * scale) / 2);
    canvas.scale(scale);

    final lit = lights.clamp(0.0, 1.0);
    Paint fill(Color color) => Paint()
      ..color = color
      ..isAntiAlias = true;

    // The body goes first: the awning's scallops hang over it.
    final frame = fill(colors.frame);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(26, 76, 234, 236), const Radius.circular(26)),
      frame,
    );

    final stripeA = fill(colors.stripeA);
    final stripeB = fill(colors.stripeB);
    final awningOff = fill(colors.awningOff);
    for (var i = 0; i < _stripes; i++) {
      _paintStripe(canvas, i, i.isEven ? stripeA : stripeB, awningOff);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(20, 0, 240, 24), const Radius.circular(12)),
      frame,
    );

    canvas.drawCircle(_coinCentre, _coinRadius, fill(Color.lerp(colors.lightsOff, colors.coin, lit)!));
    canvas.drawPath(
      _pesoSign,
      Paint()
        ..color = Color.lerp(colors.lightsOff, colors.peso, lit)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  static const Offset _coinCentre = Offset(130, 170);
  static const double _coinRadius = 44;

  /// ₱ as strokes: stem, bowl and two bars.
  static final Path _pesoSign = Path()
    ..moveTo(114, 202)
    ..lineTo(114, 140)
    ..lineTo(130, 140)
    ..arcToPoint(const Offset(130, 184), radius: const Radius.circular(22))
    ..lineTo(114, 184)
    ..moveTo(100, 153)
    ..lineTo(162, 153)
    ..moveTo(100, 171)
    ..lineTo(162, 171);

  @override
  bool shouldRepaint(StoreMarkPainter oldDelegate) =>
      oldDelegate.awning != awning || oldDelegate.lights != lights || oldDelegate.colors != colors;
}

/// "TINDAHAN" as rounded strokes, so the word scales with the mark. Letters
/// are single-line skeletons; the round pen gives them their weight.
class WordmarkPainter extends CustomPainter {
  WordmarkPainter({Color? color}) : color = color ?? AppColors.ink;

  static const double _capHeight = 100;
  static const double _pen = 22;
  static const double _top = _pen / 2;
  static const double _bottom = _capHeight - _pen / 2;
  static const double _gap = 42;
  static const double _gapAfterSlant = 34;

  final Color color;

  static final (Path, double) _word = _buildWord();

  /// Width divided by height of the finished word.
  static double get aspectRatio => (_word.$2 + _pen) / _capHeight;

  static (Path, double) _buildWord() {
    final path = Path();
    var x = 0.0;

    void line(double x1, double y1, double x2, double y2) {
      path
        ..moveTo(x + x1, y1)
        ..lineTo(x + x2, y2);
    }

    void letterT() {
      line(0, _top, 62, _top);
      line(31, _top, 31, _bottom);
      x += 62 + _gap;
    }

    void letterI() {
      line(0, _top, 0, _bottom);
      x += _gap;
    }

    void letterN() {
      path
        ..moveTo(x, _bottom)
        ..lineTo(x, _top)
        ..lineTo(x + 60, _bottom)
        ..lineTo(x + 60, _top);
      x += 60 + _gap;
    }

    void letterD() {
      path
        ..moveTo(x, _top)
        ..lineTo(x, _bottom)
        ..lineTo(x + 20, _bottom)
        ..cubicTo(x + 82, _bottom, x + 82, _top, x + 20, _top)
        ..close();
      x += 66 + _gap;
    }

    void letterA({required double gapAfter}) {
      const halfWidth = 35.0;
      path
        ..moveTo(x, _bottom)
        ..lineTo(x + halfWidth, _top)
        ..lineTo(x + halfWidth * 2, _bottom);
      line(14, 64, halfWidth * 2 - 14, 64);
      x += halfWidth * 2 + gapAfter;
    }

    void letterH() {
      line(0, _top, 0, _bottom);
      line(60, _top, 60, _bottom);
      line(0, _capHeight / 2, 60, _capHeight / 2);
      x += 60 + _gap;
    }

    letterT();
    letterI();
    letterN();
    letterD();
    letterA(gapAfter: _gapAfterSlant);
    letterH();
    letterA(gapAfter: _gapAfterSlant);
    letterN();
    return (path, x - _gap);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / _capHeight;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(_pen / 2, 0);
    canvas.drawPath(
      _word.$1,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _pen
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(WordmarkPainter oldDelegate) => oldDelegate.color != color;
}

/// The store-front mark alone, sized by height.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.height = 32, this.awning = 1, this.lights = 1});

  final double height;
  final double awning;
  final double lights;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * StoreMarkPainter.aspectRatio,
      child: CustomPaint(painter: StoreMarkPainter(awning: awning, lights: lights)),
    );
  }
}

/// The word alone, sized by height.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.height = 16});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * WordmarkPainter.aspectRatio,
      child: CustomPaint(painter: WordmarkPainter()),
    );
  }
}

/// The Tindahan logo: store front and word, sized by the store front's height.
/// Screen readers hear the app name.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 32});

  /// Word height and gap as a share of the store front's height, kept with the
  /// logo so every size has the same proportions.
  static const double wordRatio = 0.44;
  static const double gapRatio = 0.3;

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: context.s.appName,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogoMark(height: height),
          SizedBox(width: height * gapRatio),
          AppWordmark(height: height * wordRatio),
        ],
      ),
    );
  }
}

/// Scalloped awning edge, the brand's one decorative shape. Always an odd
/// number of stripes, so both ends match.
class AwningBandPainter extends CustomPainter {
  AwningBandPainter({this.solid = AppColors.primary, Color? accent}) : accent = accent ?? AppColors.surface;

  static const double _targetStripeWidth = 44;

  final Color solid;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    var stripes = (size.width / _targetStripeWidth).round();
    if (stripes.isEven) stripes += 1;
    final width = size.width / stripes;
    final scallop = math.min(width / 2, size.height * 0.45);
    final bottom = size.height - scallop;
    for (var i = 0; i < stripes; i++) {
      final left = i * width;
      canvas.drawPath(
        Path()
          ..moveTo(left, 0)
          ..lineTo(left + width, 0)
          ..lineTo(left + width, bottom)
          ..arcToPoint(Offset(left, bottom), radius: Radius.elliptical(width / 2, scallop))
          ..close(),
        Paint()
          ..color = i.isEven ? solid : accent
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(AwningBandPainter oldDelegate) =>
      oldDelegate.solid != solid || oldDelegate.accent != accent;
}

/// A panel with the awning along its top edge, like a shop front. Keep it to
/// one per screen: it marks the screen's main statement.
class AwningPanel extends StatelessWidget {
  const AwningPanel({
    super.key,
    required this.child,
    this.color = AppColors.primaryTint,
    this.borderRadius = AppRadius.frame,
    this.awningHeight = 28,
    this.padding = const EdgeInsets.all(AppSpace.xl),
  });

  final Widget child;
  final Color color;
  final BorderRadius borderRadius;
  final double awningHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: color,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: awningHeight, child: CustomPaint(painter: AwningBandPainter())),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
