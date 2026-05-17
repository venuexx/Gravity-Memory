import 'package:flutter/material.dart';
import '../core/constants.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Policy',
                      style: AppTextStyles.title(size: 18, color: AppColors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Effective: May 17, 2026',
                      style: AppTextStyles.label(size: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 20),
                    _section('Information We Collect',
                      'Gravity Memory does not collect, store, or share any personal information. '
                      'No account, registration, or login is required to use this app.'),
                    _section('Advertising',
                      'This app uses Google AdMob to display advertisements. AdMob may collect '
                      'device advertising IDs, IP addresses, and usage data to serve personalized '
                      'or contextual ads. You can opt out of personalized ads in your device settings.'),
                    _section('Third Party Services',
                      'Google AdMob and Google Play Services are used by this application. '
                      'Each service operates under its own privacy policy.'),
                    _section('Data Retention',
                      'No personal data is collected or retained by us. Ad networks may retain '
                      'data according to their own privacy policies.'),
                    _section('Children',
                      'This app is not directed at children under 13. We do not knowingly collect '
                      'any information from children.'),
                    _section('Changes',
                      'This policy may be updated as needed. Changes will be reflected with '
                      'an updated effective date.'),
                    _section('Contact',
                      'For questions about privacy, contact:\ngravitymemory@venuex.com'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body(size: 14, color: AppColors.accent),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: AppTextStyles.body(size: 13, color: AppColors.grey),
          ),
        ],
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
                'PRIVACY',
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
