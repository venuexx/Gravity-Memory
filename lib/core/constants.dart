import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF111111);
  static const surface = Color(0xFF1E1E1E);
  static const card = Color(0xFF252525);
  static const accent = Color(0xFFF5C518);
  static const accentDark = Color(0xFFB8931A);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFF666666);
  static const greyLight = Color(0xFF888888);
  static const greyDark = Color(0xFF333333);
  static const danger = Color(0xFFE53935);
  static const tileVisible = Color(0xFF3A3A3A);
  static const tilePath = Color(0xFF4A4A4A);
  static const tileWall = Color(0xFF1A1A1A);
  static const playerColor = Color(0xFFFFFFFF);
  static const exitColor = Color(0xFFF5C518);
}

class AppTextStyles {
  static const String fontFamily = 'RobotoMono';

  static TextStyle title({double size = 32, Color color = AppColors.white}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 2,
      );

  static TextStyle body({double size = 16, Color color = AppColors.white}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 1,
      );

  static TextStyle label({double size = 14, Color color = AppColors.grey}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 1.5,
      );
}

class AppDimensions {
  static const double buttonHeight = 62.0;
  static const double buttonRadius = 6.0;
  static const double cardRadius = 10.0;
  static const double tileSize = 36.0;
  static const double tileSizeSmall = 28.0;
  static const double padding = 24.0;
  static const double paddingSmall = 16.0;
}

class AppRoutes {
  static const String splash = '/splash';
  static const String mainMenu = '/';
  static const String levelSelect = '/level-select';
  static const String game = '/game';
  static const String success = '/success';
  static const String fail = '/fail';
  static const String settings = '/settings';
  static const String shop = '/shop';
  static const String leaderboard = '/leaderboard';
}
