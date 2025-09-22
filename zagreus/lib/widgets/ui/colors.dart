import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagColours {
  /// List of Zagreus colours in order that the should appear in a list.
  ///
  /// Use [byListIndex] to fetch the colour at the any index
  static const _LIST_COLOR_ICONS = [
    blue,
    accent,
    red,
    orange,
    purple,
    blueGrey,
  ];

  /// Core accent colour
  static const Color accent = Color(0xFF236969);
  
  /// Dark mode accent colour
  static const Color accentDark = Color(0xFF236969);
  
  /// Light mode accent colour
  static const Color accentLight = Color(0xFF5AD2BE);
  
  // Dark Mode Colors
  static const Color primaryDark = Color(0xFF232534);
  static const Color secondaryDark = Color(0xFF1A1B28);
  
  // Light Mode Colors
  // Using softer whites to reduce eye strain
  static const Color primaryLight = Color(0xFFF2F2F2);  // Soft off-white for both
  static const Color secondaryLight = Color(0xFFF2F2F2);  // Soft off-white for both
  
  /// Zagreus app black background - RGB(35, 37, 52)
  static const Color zagreusBackground = Color(0xFF232534);

  /// Core primary colour (background)
  static const Color primary = Color(0xFF232534);

  /// Core secondary colour (appbar, bottom bar, etc.),
  static const Color secondary = Color(0xFF1A1B28);

  static const Color blue = Color(0xFF00A8E8);
  static const Color blueGrey = Color(0xFF848FA5);
  static const Color grey = Color(0xFFBBBBBB);
  static const Color orange = Color(0xFFFF9000);
  static const Color purple = Color(0xFF9649CB);
  static const Color red = Color(0xFFF71735);

  /// Shades of White
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  /// Returns the correct colour for a graph by what layer it is on the graph canvas.
  Color byGraphLayer(int index) {
    switch (index) {
      case 0:
        return ZagColours.accent;
      case 1:
        return ZagColours.purple;
      case 2:
        return ZagColours.blue;
      default:
        return byListIndex(index);
    }
  }

  /// Return the correct colour for a list.
  /// If the index is greater than the list of colour's length, uses modulus to loop list.
  Color byListIndex(int index) {
    return _LIST_COLOR_ICONS[index % _LIST_COLOR_ICONS.length];
  }
  
  /// Get theme-aware primary color
  static Color primaryColor(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return isLight ? primaryLight : primaryDark;
  }
  
  /// Get theme-aware secondary color
  static Color secondaryColor(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return isLight ? secondaryLight : secondaryDark;
  }
  
  /// Get theme-aware accent color
  static Color accentColor(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return isLight ? accentLight : accentDark;
  }
}

extension ZagColor on Color {
  Color disabled([bool condition = true]) {
    if (condition) return this.withOpacity(ZagUI.OPACITY_DISABLED);
    return this;
  }

  Color enabled([bool condition = true]) {
    if (condition) return this;
    return this.withOpacity(ZagUI.OPACITY_DISABLED);
  }

  Color selected([bool condition = true]) {
    if (condition) return this.withOpacity(ZagUI.OPACITY_SELECTED);
    return this;
  }

  Color dimmed() => this.withOpacity(ZagUI.OPACITY_DIMMED);
}
