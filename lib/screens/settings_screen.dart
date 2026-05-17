import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/save_service.dart';
import '../core/music_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final save = context.watch<SaveService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            const SizedBox(height: 32),
            _ToggleCard(
              icon: Icons.volume_up_outlined,
              label: 'Sound Effects',
              subtitle: 'Move, timer and feedback sounds',
              value: save.sound,
              onChanged: (v) async {
                await save.setSound(v);
                MusicService.instance.soundEnabled = v;
              },
            ),
            const SizedBox(height: 12),
            _ToggleCard(
              icon: Icons.music_note_outlined,
              label: 'Background Music',
              subtitle: 'Menu and gameplay music',
              value: save.music,
              onChanged: (v) async {
                await save.setMusic(v);
                MusicService.instance.musicEnabled = v;
                if (v) {
                  MusicService.instance.playMenu();
                } else {
                  MusicService.instance.stop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.greyDark, width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _ToggleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? AppColors.accent.withAlpha(30) : AppColors.greyDark,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: value
                      ? AppColors.accent.withAlpha(25)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: value ? AppColors.accent : AppColors.grey,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.body(size: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.label(
                        size: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withAlpha(60),
                inactiveTrackColor: AppColors.greyDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
