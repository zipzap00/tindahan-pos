import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material theme built only from DESIGN.md tokens (light transactional track).
///
/// DESIGN.md defines no red or amber. Errors and warnings therefore stay in
/// ink and are always paired with an icon and words, never colour alone.
ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.aloe10,
    onSecondary: AppColors.ink,
    tertiary: AppColors.pistachio10,
    onTertiary: AppColors.ink,
    error: AppColors.ink,
    onError: AppColors.onPrimary,
    surface: AppColors.canvasLight,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.hairlineLight,
    outlineVariant: AppColors.hairlineLight,
    surfaceContainerHighest: AppColors.canvasCream,
  );

  final textTheme = TextTheme(
    displayLarge: AppType.displayMd,
    displayMedium: AppType.displayMobile,
    headlineLarge: AppType.headingXl,
    headlineMedium: AppType.headingLg,
    headlineSmall: AppType.headingMd,
    titleLarge: AppType.headingMd,
    titleMedium: AppType.bodyStrong,
    titleSmall: AppType.caption,
    bodyLarge: AppType.bodyMd,
    bodyMedium: AppType.bodyMd,
    bodySmall: AppType.caption,
    labelLarge: AppType.bodyMd,
    labelMedium: AppType.caption,
    labelSmall: AppType.micro,
  );

  const inputBorder = OutlineInputBorder(
    borderRadius: AppRadius.input,
    borderSide: BorderSide(color: AppColors.hairlineLight),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppType.family,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.canvasCream,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.canvasCream,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppType.headingMd,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.hairlineLight, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.canvasLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: AppColors.ink)),
      focusedErrorBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      labelStyle: AppType.caption.copyWith(color: AppColors.textSmall),
      floatingLabelStyle: AppType.caption.copyWith(color: AppColors.ink),
      hintStyle: AppType.bodyMd.copyWith(color: AppColors.textSecondary),
      helperStyle: AppType.micro,
      errorStyle: AppType.micro.copyWith(color: AppColors.ink),
      prefixStyle: AppType.bodyMd,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.canvasLight,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.aloe10,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(AppType.micro.copyWith(color: AppColors.ink)),
      iconTheme: const WidgetStatePropertyAll(IconThemeData(color: AppColors.ink, size: 24)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.canvasLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      showDragHandle: true,
      dragHandleColor: AppColors.shade30,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.canvasLight,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      titleTextStyle: AppType.headingMd,
      contentTextStyle: AppType.bodyMd,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: AppType.bodyMd.copyWith(color: AppColors.onPrimary),
      behavior: SnackBarBehavior.floating,
      shape: const StadiumBorder(),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.ink),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.onPrimary : AppColors.shade50,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.ink : AppColors.shade30,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: AppType.bodyStrong,
      subtitleTextStyle: AppType.caption,
      iconColor: AppColors.ink,
      minVerticalPadding: 12,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.canvasLight,
      surfaceTintColor: Colors.transparent,
      textStyle: AppType.bodyMd,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
    ),
  );
}
