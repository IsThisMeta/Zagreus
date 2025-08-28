import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zagreus/core.dart';

class ZagTheme {
  /// Initialize the theme by setting the system navigation and system colours.
  void initialize() {
    //Set system UI overlay style (navbar, statusbar)
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }

  /// Returns the active [ThemeData] by checking the theme database value.
  ThemeData activeTheme() {
    return isAMOLEDTheme ? _pureBlackTheme() : _midnightTheme();
  }

  static bool get isAMOLEDTheme => ZagreusDatabase.THEME_AMOLED.read();
  static bool get useBorders => ZagreusDatabase.THEME_AMOLED_BORDER.read();

  /// Midnight theme (Default)
  ThemeData _midnightTheme() {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      canvasColor: ZagColours.primary,
      primaryColor: ZagColours.secondary,
      highlightColor: ZagColours.accent.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      cardColor: ZagColours.secondary,
      hoverColor: ZagColours.accent.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      splashColor: ZagColours.accent.withOpacity(ZagUI.OPACITY_SPLASH),
      dialogTheme: DialogThemeData(
        backgroundColor: ZagColours.secondary,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: ZagColours.secondary,
          borderRadius: BorderRadius.all(Radius.circular(ZagUI.BORDER_RADIUS)),
        ),
        textStyle: TextStyle(
          color: ZagColours.grey,
          fontSize: ZagUI.FONT_SIZE_SUBHEADER,
        ),
        preferBelow: true,
      ),
      unselectedWidgetColor: Colors.white,
      textTheme: _sharedTextTheme,
      textButtonTheme: _sharedTextButtonThemeData,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// AMOLED/Pure black theme
  ThemeData _pureBlackTheme() {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      canvasColor: Colors.black,
      primaryColor: Colors.black,
      highlightColor: ZagColours.accent.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      cardColor: Colors.black,
      hoverColor: ZagColours.accent.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      splashColor: ZagColours.accent.withOpacity(ZagUI.OPACITY_SPLASH),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.black,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.all(
            Radius.circular(ZagUI.BORDER_RADIUS),
          ),
          border: useBorders ? Border.all(color: ZagColours.white10) : null,
        ),
        textStyle: const TextStyle(
          color: ZagColours.grey,
          fontSize: ZagUI.FONT_SIZE_SUBHEADER,
        ),
        preferBelow: true,
      ),
      unselectedWidgetColor: Colors.white,
      textTheme: _sharedTextTheme,
      textButtonTheme: _sharedTextButtonThemeData,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  SystemUiOverlayStyle get overlayStyle {
    return SystemUiOverlayStyle(
      systemNavigationBarColor: ZagreusDatabase.THEME_AMOLED.read()
          ? Colors.black
          : ZagColours.secondary,
      systemNavigationBarDividerColor: ZagreusDatabase.THEME_AMOLED.read()
          ? Colors.black
          : ZagColours.secondary,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    );
  }

  TextTheme get _sharedTextTheme {
    const textStyle = TextStyle(color: Colors.white);
    return const TextTheme(
      displaySmall: textStyle,
      displayMedium: textStyle,
      displayLarge: textStyle,
      headlineSmall: textStyle,
      headlineMedium: textStyle,
      headlineLarge: textStyle,
      bodySmall: textStyle,
      bodyMedium: textStyle,
      bodyLarge: textStyle,
      titleSmall: textStyle,
      titleMedium: textStyle,
      titleLarge: textStyle,
      labelSmall: textStyle,
      labelMedium: textStyle,
      labelLarge: textStyle,
    );
  }

  TextButtonThemeData get _sharedTextButtonThemeData {
    return TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all<Color>(
          ZagColours.accent.withOpacity(ZagUI.OPACITY_SPLASH),
        ),
      ),
    );
  }
}
