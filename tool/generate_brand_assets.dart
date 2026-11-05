// Renders every app icon, launch image and logo export from the painters in
// lib/ui/widgets/brand.dart, so the artwork has one source. After changing
// those painters, run from the project root:
//
//   flutter test tool/generate_brand_assets.dart
//
// It runs under `flutter test` because that gives a Dart VM with the Flutter
// rendering engine, without needing a device.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_pos/core/theme/tokens.dart';
import 'package:tindahan_pos/ui/widgets/brand.dart';

typedef Painter = void Function(Canvas canvas, Size size);

Future<void> writePng(String path, int width, int height, Painter painter) async {
  final recorder = ui.PictureRecorder();
  painter(Canvas(recorder), Size(width.toDouble(), height.toDouble()));
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(Uint8List.sublistView(data!));
}

/// Paints the mark centred, its width [share] of the canvas width.
void paintMark(Canvas canvas, Size size, double share, StoreMarkPainter mark) {
  final width = size.width * share;
  final height = width / StoreMarkPainter.aspectRatio;
  canvas.save();
  canvas.translate((size.width - width) / 2, (size.height - height) / 2);
  mark.paint(canvas, Size(width, height));
  canvas.restore();
}

/// Square full-bleed icon: the platform applies its own mask.
Painter fullBleedIcon(double share) => (canvas, size) {
      canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.primary);
      paintMark(canvas, size, share, const StoreMarkPainter(colors: MarkColors.onMint));
    };

/// Rounded tile on transparent, for places that show the file as it is.
void roundedIcon(Canvas canvas, Size size) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width * 0.22)),
    Paint()
      ..color = AppColors.primary
      ..isAntiAlias = true,
  );
  paintMark(canvas, size, 0.66, const StoreMarkPainter(colors: MarkColors.onMint));
}

/// The store before it opens: what the loading screen starts from.
void closedStore(Canvas canvas, Size size) =>
    const StoreMarkPainter(awning: 0, lights: 0).paint(canvas, size);

void lockup(Canvas canvas, Size size) {
  final markHeight = size.height;
  final markWidth = markHeight * StoreMarkPainter.aspectRatio;
  const StoreMarkPainter().paint(canvas, Size(markWidth, markHeight));
  final wordHeight = markHeight * AppLogo.wordRatio;
  canvas.save();
  canvas.translate(markWidth + markHeight * AppLogo.gapRatio, (markHeight - wordHeight) / 2);
  WordmarkPainter().paint(canvas, Size(wordHeight * WordmarkPainter.aspectRatio, wordHeight));
  canvas.restore();
}

const Map<String, double> androidDensities = {
  'mdpi': 1,
  'hdpi': 1.5,
  'xhdpi': 2,
  'xxhdpi': 3,
  'xxxhdpi': 4,
};

/// The loading screen's store-front height, in logical pixels.
const double launchMarkHeight = 120;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render brand assets', () async {
    // Logo exports for print and the web. Not bundled in the app.
    const logoHeight = 900;
    final logoWidth = (logoHeight *
            (StoreMarkPainter.aspectRatio + AppLogo.gapRatio + AppLogo.wordRatio * WordmarkPainter.aspectRatio))
        .ceil();
    await writePng('assets/brand/logo.png', logoWidth, logoHeight, lockup);
    await writePng(
      'assets/brand/mark.png',
      2048,
      (2048 / StoreMarkPainter.aspectRatio).round(),
      (canvas, size) => const StoreMarkPainter().paint(canvas, size),
    );
    await writePng('assets/brand/app-icon.png', 1024, 1024, fullBleedIcon(0.62));

    // Android.
    const res = 'android/app/src/main/res';
    for (final MapEntry(key: density, value: scale) in androidDensities.entries) {
      await writePng('$res/mipmap-$density/ic_launcher.png', (48 * scale).round(), (48 * scale).round(), roundedIcon);
      final foreground = (108 * scale).round();
      await writePng(
        '$res/mipmap-$density/ic_launcher_foreground.png',
        foreground,
        foreground,
        // The adaptive-icon safe zone is the middle 66 of 108 dp.
        (canvas, size) => paintMark(canvas, size, 0.5, const StoreMarkPainter(colors: MarkColors.onMint)),
      );
      await writePng(
        '$res/drawable-$density/launch_mark.png',
        (launchMarkHeight * StoreMarkPainter.aspectRatio * scale).round(),
        (launchMarkHeight * scale).round(),
        closedStore,
      );
    }

    // iOS. Icons must be opaque, and the sizes come from the file names.
    const ios = 'ios/Runner/Assets.xcassets';
    final iconName = RegExp(r'Icon-App-([\d.]+)x[\d.]+@(\d)x\.png$');
    for (final file in Directory('$ios/AppIcon.appiconset').listSync().whereType<File>()) {
      final match = iconName.firstMatch(file.path);
      if (match == null) continue;
      final pixels = (double.parse(match[1]!) * int.parse(match[2]!)).round();
      await writePng(file.path, pixels, pixels, fullBleedIcon(0.62));
    }
    for (final (suffix, scale) in const [('', 1), ('@2x', 2), ('@3x', 3)]) {
      await writePng(
        '$ios/LaunchImage.imageset/LaunchImage$suffix.png',
        (launchMarkHeight * StoreMarkPainter.aspectRatio * scale).round(),
        (launchMarkHeight * scale).round(),
        closedStore,
      );
    }

    // Web.
    await writePng('web/favicon.png', 64, 64, roundedIcon);
    await writePng('web/icons/Icon-192.png', 192, 192, roundedIcon);
    await writePng('web/icons/Icon-512.png', 512, 512, roundedIcon);
    // Maskable icons keep the mark inside the middle 80 % safe circle.
    await writePng('web/icons/Icon-maskable-192.png', 192, 192, fullBleedIcon(0.56));
    await writePng('web/icons/Icon-maskable-512.png', 512, 512, fullBleedIcon(0.56));
  });
}
