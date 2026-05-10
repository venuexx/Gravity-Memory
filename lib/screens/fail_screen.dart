import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/gm_button.dart';

class FailScreen extends StatelessWidget {
  final int levelId;
  const FailScreen({super.key, required this.levelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'OOPS!',
                style: AppTextStyles.title(size: 40, color: AppColors.danger),
              ),
              const SizedBox(height: 10),
              Text(
                'WRONG PATH',
                style: AppTextStyles.body(size: 16, color: AppColors.white),
              ),
              const SizedBox(height: 30),
              const Icon(Icons.sentiment_very_dissatisfied, color: AppColors.greyLight, size: 72),
              const Spacer(),
              GmButton(
                label: 'RETRY',
                icon: Icons.refresh,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.game,
                  arguments: levelId,
                ),
              ),
              const SizedBox(height: 14),
              GmButton(
                label: 'WATCH AD · CONTINUE',
                icon: Icons.play_circle_outline,
                filled: false,
                onTap: () {
                  // Reklam sistemi ileride eklenecek
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.game,
                    arguments: levelId,
                  );
                },
              ),
              const SizedBox(height: 14),
              GmButton(
                label: 'HOME',
                icon: Icons.home_outlined,
                filled: false,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.mainMenu,
                  (r) => false,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
