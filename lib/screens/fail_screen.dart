import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants.dart';
import '../core/ad_service.dart';
import '../widgets/gm_button.dart';

class FailScreen extends StatefulWidget {
  final int levelId;
  final int resumeRow;
  final int resumeCol;
  final int resumeTime;
  final int resumeMoves;
  const FailScreen({
    super.key,
    required this.levelId,
    required this.resumeRow,
    required this.resumeCol,
    required this.resumeTime,
    required this.resumeMoves,
  });

  @override
  State<FailScreen> createState() => _FailScreenState();
}

class _FailScreenState extends State<FailScreen> {
  RewardedAd? _rewardedAd;
  bool _adLoading = false;

  @override
  void initState() {
    super.initState();
    // Önceden yüklenmiş reklamı kullan
    _rewardedAd = AdService.instance.rewardedAd;
  }

  void _watchAd() {
    final ad = _rewardedAd;
    if (ad == null) return;
    setState(() => _adLoading = true);
    bool _earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        AdService.instance.rewardedAd = null;
        AdService.instance.preload(); // Sonraki oyun için yeni reklam yükle
        if (!mounted) return;
        if (_earned) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.game,
            arguments: {
              'levelId': widget.levelId,
              'resumeRow': widget.resumeRow,
              'resumeCol': widget.resumeCol,
              'resumeTime': widget.resumeTime,
              'resumeMoves': widget.resumeMoves,
            },
          );
        } else {
          setState(() { _rewardedAd = null; _adLoading = false; });
        }
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        if (mounted) setState(() { _rewardedAd = null; _adLoading = false; });
      },
    );
    ad.show(
      onUserEarnedReward: (_, __) {
        _earned = true;
      },
    );
  }

  @override
  void dispose() {
    // Reklam AdService'e ait, burada dispose etme
    super.dispose();
  }

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
                  arguments: widget.levelId,
                ),
              ),
              if (_rewardedAd != null) ...[
                const SizedBox(height: 14),
                GmButton(
                  label: _adLoading ? 'LOADING...' : 'WATCH AD & CONTINUE',
                  icon: Icons.play_circle_outline,
                  filled: false,
                  onTap: _adLoading ? () {} : _watchAd,
                ),
              ],
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
