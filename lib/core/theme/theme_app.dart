import 'package:flutter/material.dart';

import 'dark.dart' as dark_theme;
import 'light.dart' as light_theme;

class ThemeApp {
  ThemeApp._();

  static ThemeData get lightTheme => light_theme.lightTheme;
  static ThemeData get darkTheme => dark_theme.darkTheme;
}
