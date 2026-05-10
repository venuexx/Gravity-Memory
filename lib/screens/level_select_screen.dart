import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/game_data.dart';
import '../core/save_service.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final save = context.watch<SaveService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.greyDark, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: AppColors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELECT LEVEL',
                          style: AppTextStyles.title(size: 20)),
                      Text(
                        '${save.unlockedLevels.length} / ${kAllLevels.length} unlocked',
                        style: AppTextStyles.label(
                            size: 11, color: AppColors.greyLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── Progress bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: save.unlockedLevels.length / kAllLevels.length,
                  minHeight: 3,
                  backgroundColor: AppColors.greyDark,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ── Grid ──
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.88,
                ),
                itemCount: kAllLevels.length,
                itemBuilder: (_, i) {
                  final level = kAllLevels[i];
                  final unlocked = save.isUnlocked(level.id);
                  final stars = save.starsForLevel(level.id);
                  return _LevelCell(
                    levelId: level.id,
                    unlocked: unlocked,
                    stars: stars,
                    onTap: unlocked
                        ? () => Navigator.pushNamed(
                              context,
                              AppRoutes.game,
                              arguments: level.id,
                            )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCell extends StatelessWidget {
  final int levelId;
  final bool unlocked;
  final int stars;
  final VoidCallback? onTap;

  const _LevelCell({
    required this.levelId,
    required this.unlocked,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = stars > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.card : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? const Color(0xFF2ECC71) : AppColors.greyDark,
            width: isCompleted ? 1.5 : 1,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withAlpha(30),
                    blurRadius: 8,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!unlocked)
              const Icon(Icons.lock, color: AppColors.greyDark, size: 22)
            else
              Text(
                '$levelId',
                style: AppTextStyles.title(
                  size: 28,
                  color: isCompleted ? AppColors.accent : AppColors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
