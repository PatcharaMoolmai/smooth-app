// Flutter imports:
import 'package:flutter/material.dart';

/// Color destination
enum ColorDestination {
  APP_BAR_FOREGROUND,
  APP_BAR_BACKGROUND,
  SURFACE_FOREGROUND,
  SURFACE_BACKGROUND,
  BUTTON_FOREGROUND,
  BUTTON_BACKGROUND,
}

class SmoothTheme {
  static const double ADDITIONAL_OPACITY_FOR_DARK = .3;

  /// Theme color tags
  static const String COLOR_TAG_BLUE = 'blue';
  static const String COLOR_TAG_GREEN = 'green';
  static const String COLOR_TAG_PINK = 'pink';
  static const String COLOR_TAG_CYAN = 'cyan';

  /// Theme material colors
  static const Map<String, MaterialColor> MATERIAL_COLORS =
      <String, MaterialColor>{
    COLOR_TAG_BLUE: Colors.blue,
    COLOR_TAG_GREEN: Colors.green,
    COLOR_TAG_PINK: Colors.pink,
    COLOR_TAG_CYAN: Colors.cyan,
  };

  /// Returns a shade of a [materialColor]
  ///
  /// For instance, if you want to display a red button,
  /// you'll use Colors.red as root color,
  /// the destination will be ColorDestination.BUTTON_BACKGROUND,
  /// and you'll specify the current ColorScheme.
  /// For the moment, the ColorScheme matters only for the light/dark switch.
  static Color getColor(
    final ColorScheme colorScheme,
    final MaterialColor materialColor,
    final ColorDestination colorDestination,
  ) {
    if (colorScheme.brightness == Brightness.light) {
      switch (colorDestination) {
        case ColorDestination.APP_BAR_BACKGROUND:
        case ColorDestination.SURFACE_FOREGROUND:
        case ColorDestination.BUTTON_BACKGROUND:
          return materialColor[800];
        case ColorDestination.APP_BAR_FOREGROUND:
        case ColorDestination.SURFACE_BACKGROUND:
        case ColorDestination.BUTTON_FOREGROUND:
          return materialColor[100];
      }
    }
    switch (colorDestination) {
      case ColorDestination.APP_BAR_BACKGROUND:
        return null;
      case ColorDestination.SURFACE_BACKGROUND:
      case ColorDestination.BUTTON_BACKGROUND:
        return materialColor[900].withOpacity(ADDITIONAL_OPACITY_FOR_DARK);
      case ColorDestination.APP_BAR_FOREGROUND:
      case ColorDestination.SURFACE_FOREGROUND:
      case ColorDestination.BUTTON_FOREGROUND:
        return materialColor[100];
    }
    throw Exception(
      'unknown brightness / destination:'
      ' ${colorScheme.brightness} / $colorDestination',
    );
  }

  static ThemeData getThemeData(
    final Brightness brightness,
    final String colorTag,
  ) {
    ColorScheme myColorScheme;
    if (brightness == Brightness.dark) {
      myColorScheme = const ColorScheme.dark();
    } else {
      final MaterialColor materialColor =
          MATERIAL_COLORS[colorTag] ?? MATERIAL_COLORS[COLOR_TAG_BLUE];
      myColorScheme = ColorScheme.light(
        primary: materialColor[600],
        primaryVariant: materialColor[900],
      );
    }

    return ThemeData(
      colorScheme: myColorScheme,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: myColorScheme.onSurface,
        unselectedItemColor: myColorScheme.onSurface,
      ),
      textTheme: _TEXT_THEME,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: myColorScheme.secondary,
        foregroundColor: myColorScheme.onSecondary,
      ),
      appBarTheme: AppBarTheme(
        color: brightness == Brightness.dark ? null : myColorScheme.primary,
      ),
    );
  }

  static const TextTheme _TEXT_THEME = TextTheme(
    headline1: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
    ),
    headline2: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
    headline3: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    ),
    headline4: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    bodyText2: TextStyle(
      fontSize: 14,
      letterSpacing: 0.5,
    ),
    subtitle1: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w200,
    ),
    subtitle2: TextStyle(
      fontSize: 12.0,
    ),
  );
}
