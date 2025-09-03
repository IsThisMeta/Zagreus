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
    if (themeMode == 'light') {
      return _lightTheme();
    }
    return isAMOLEDTheme ? _pureBlackTheme() : _midnightTheme();
  }

  static bool get isAMOLEDTheme => ZagreusDatabase.THEME_AMOLED.read();
  static bool get useBorders => ZagreusDatabase.THEME_AMOLED_BORDER.read();
  static String get themeMode => ZagreusDatabase.THEME_MODE.read();

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

  /// Light theme
  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      canvasColor: ZagColours.primaryLight,
      primaryColor: ZagColours.secondaryLight,
      highlightColor: ZagColours.accentLight.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      cardColor: ZagColours.secondaryLight,
      hoverColor: ZagColours.accentLight.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      splashColor: ZagColours.accentLight.withOpacity(ZagUI.OPACITY_SPLASH),
      dialogTheme: DialogThemeData(
        backgroundColor: ZagColours.secondaryLight,
      ),
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(ZagUI.BORDER_RADIUS)),
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: ZagUI.FONT_SIZE_SUBHEADER,
        ),
        preferBelow: true,
      ),
      unselectedWidgetColor: Colors.black54,
      textTheme: _lightTextTheme,
      textButtonTheme: _lightTextButtonThemeData,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  SystemUiOverlayStyle get overlayStyle {
    bool isLight = themeMode == 'light';
    return SystemUiOverlayStyle(
      systemNavigationBarColor: isLight
          ? ZagColours.secondaryLight
          : (ZagreusDatabase.THEME_AMOLED.read()
              ? Colors.black
              : ZagColours.secondary),
      systemNavigationBarDividerColor: isLight
          ? ZagColours.secondaryLight
          : (ZagreusDatabase.THEME_AMOLED.read()
              ? Colors.black
              : ZagColours.secondary),
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
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

  TextTheme get _lightTextTheme {
    const textStyle = TextStyle(color: Colors.black87);
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

  TextButtonThemeData get _lightTextButtonThemeData {
    return TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all<Color>(
          ZagColours.accentLight.withOpacity(ZagUI.OPACITY_SPLASH),
        ),
      ),
    );
  }
}
