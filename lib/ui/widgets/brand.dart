import 'package:flutter/material.dart';

import '../../core/l10n/language.dart';
import '../../core/theme/tokens.dart';

/// The Tindahan logo (store front + word). Sized by height; the width
/// follows the image's aspect ratio. Screen readers hear the app name.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      height: height,
      width: height * AppAssets.logoAspectRatio,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: context.s.appName,
    );
  }
}
