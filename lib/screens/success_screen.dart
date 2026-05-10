import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/game_data.dart';
import '../widgets/gm_button.dart';

class SuccessScreen extends StatelessWidget {
  final int levelId;
  final int timeSeconds;
  final int moves;

  const SuccessScreen({
    super.key,
    required this.levelId,
    required this.timeSeconds,
    required this.moves,
  });

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasNext = levelId < kAllLevels.length;

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
                'LEVEL $levelId',
                style: AppTextStyles.label(size: 14, color: AppColors.greyLight),
              ),
              const SizedBox(height: 8),
              Text(
                'COMPLETED!',
                style: AppTextStyles.title(size: 28, color: AppColors.accent),
              ),
              const SizedBox(height: 30),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A2A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2ECC71), width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF2ECC71),
                  size: 40,
                ),
              ),
              const Spacer(),
              _StatRow(label: 'TIME', value: _formatTime(timeSeconds)),
              const SizedBox(height: 12),
              _StatRow(label: 'MOVES', value: '$moves'),
              const Spacer(),
              if (hasNext)
                GmButton(
                  label: 'NEXT LEVEL',
                  icon: Icons.arrow_forward,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.game,
                    arguments: levelId + 1,
                  ),
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

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          label == 'TIME' ? Icons.timer_outlined : Icons.swap_vert,
          color: AppColors.greyLight,
          size: 18,
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.label(size: 13)),
        const Spacer(),
        Text(value, style: AppTextStyles.body(size: 15)),
      ],
    );
  }
}
