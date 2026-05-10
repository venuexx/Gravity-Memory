import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/save_service.dart';

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
            const SizedBox(height: 20),
            _ToggleRow(
              icon: Icons.volume_up_outlined,
              label: 'SOUND',
              value: save.sound,
              onChanged: save.setSound,
            ),
            _ToggleRow(
              icon: Icons.music_note_outlined,
              label: 'MUSIC',
              value: save.music,
              onChanged: save.setMusic,
            ),
            _ToggleRow(
              icon: Icons.phone_android_outlined,
              label: 'VIBRATION',
              value: save.vibration,
              onChanged: save.setVibration,
            ),
            _ToggleRow(
              icon: Icons.dark_mode_outlined,
              label: 'DARK THEME',
              value: save.darkTheme,
              onChanged: save.setDarkTheme,
            ),
            const Divider(color: AppColors.greyDark, height: 32),
            _LangRow(),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios,
                color: AppColors.white, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.greyLight, size: 22),
          const SizedBox(width: 16),
          Text(label, style: AppTextStyles.body(size: 14)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            inactiveTrackColor: AppColors.greyDark,
          ),
        ],
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.language_outlined,
              color: AppColors.greyLight, size: 22),
          const SizedBox(width: 16),
          Text('LANGUAGE', style: AppTextStyles.body(size: 14)),
          const Spacer(),
          Text(
            'ENGLISH  ›',
            style: AppTextStyles.label(size: 13, color: AppColors.greyLight),
          ),
        ],
      ),
    );
  }
}
