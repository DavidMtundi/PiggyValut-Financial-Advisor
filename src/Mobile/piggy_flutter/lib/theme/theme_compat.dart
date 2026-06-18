import 'package:flutter/material.dart';

/// Material 2 style getters for legacy Piggy UI code on Material 3 Flutter.
extension LegacyTextTheme on TextTheme {
  TextStyle? get headline1 => displayLarge;
  TextStyle? get headline2 => displayMedium;
  TextStyle? get headline3 => displaySmall;
  TextStyle? get headline4 => headlineMedium;
  TextStyle? get headline5 => headlineSmall;
  TextStyle? get headline6 => titleLarge;
  TextStyle? get subtitle1 => titleMedium;
  TextStyle? get subtitle2 => titleSmall;
  TextStyle? get bodyText1 => bodyLarge;
  TextStyle? get bodyText2 => bodyMedium;
  TextStyle? get caption => bodySmall;
  TextStyle? get button => labelLarge;
  TextStyle? get overline => labelSmall;
}

extension LegacyThemeData on ThemeData {
  Color get backgroundColor => colorScheme.surface;
  Color get accentColor => colorScheme.secondary;
  Color get buttonColor => colorScheme.primary;
  Color get errorColor => colorScheme.error;
  TextTheme get accentTextTheme => primaryTextTheme;
}
