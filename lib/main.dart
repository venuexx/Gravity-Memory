import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/constants.dart';
import 'core/save_service.dart';
import 'screens/main_menu_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/game_screen.dart';
import 'screens/success_screen.dart';
import 'screens/fail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'widgets/ad_banner_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final saveService = SaveService();
  await saveService.init();
  runApp(
    ChangeNotifierProvider.value(
      value: saveService,
      child: const GravityMemoryApp(),
    ),
  );
}

class GravityMemoryApp extends StatelessWidget {
  const GravityMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gravity Memory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.accent,
        ),
        fontFamily: 'RobotoMono',
      ),
      initialRoute: AppRoutes.mainMenu,
      navigatorObservers: [AdBannerWidget.routeObserver],
      routes: {
        AppRoutes.mainMenu: (_) => const MainMenuScreen(),
        AppRoutes.levelSelect: (_) => const LevelSelectScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.shop: (_) => const ShopScreen(),
        AppRoutes.leaderboard: (_) => const LeaderboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.game) {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (_) => GameScreen(
                levelId: args['levelId'] as int,
                resumeRow: args['resumeRow'] as int?,
                resumeCol: args['resumeCol'] as int?,
                resumeTime: args['resumeTime'] as int?,
                resumeMoves: args['resumeMoves'] as int?,
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => GameScreen(levelId: args as int),
          );
        }
        if (settings.name == AppRoutes.success) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => SuccessScreen(
              levelId: args['levelId'],
              timeSeconds: args['timeSeconds'],
              moves: args['moves'],
            ),
          );
        }
        if (settings.name == AppRoutes.fail) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => FailScreen(
              levelId: args['levelId'] as int,
              resumeRow: args['resumeRow'] as int,
              resumeCol: args['resumeCol'] as int,
              resumeTime: args['resumeTime'] as int,
              resumeMoves: args['resumeMoves'] as int,
            ),
          );
        }
        return null;
      },
    );
  }
}
