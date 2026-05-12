import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/game_data.dart';
import '../core/save_service.dart';
import '../core/music_service.dart';
import '../widgets/gm_button.dart';
import '../widgets/logo_widget.dart';
import '../widgets/ad_banner_widget.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    MusicService.instance.playMenu();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      AdBannerWidget.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    MusicService.instance.playMenu();
  }

  @override
  void dispose() {
    AdBannerWidget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final save = context.watch<SaveService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
                child: Center(child: AdBannerWidget()),
              ),
              const Spacer(flex: 3),
              const LogoWidget(),
              const Spacer(flex: 2),
              GmButton(
                label: 'PLAY',
                icon: Icons.play_arrow,
                labelSize: 20,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.levelSelect),
              ),
              const SizedBox(height: 16),
              Text(
                'LEVEL ${save.unlockedLevels.length} / ${kAllLevels.length}',
                style: AppTextStyles.label(size: 13, color: AppColors.greyLight),
              ),
              const SizedBox(height: 16),
              GmButton(
                label: 'SETTINGS',
                icon: Icons.settings_outlined,
                labelSize: 17,
                filled: false,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.settings),
              ),
              const Spacer(flex: 2),
              Opacity(
                opacity: 0.20,
                child: Text(
                  'Halil İbrahim Yıldırım',
                  style: AppTextStyles.label(size: 12, color: AppColors.white).copyWith(
                    letterSpacing: 3.5,
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
