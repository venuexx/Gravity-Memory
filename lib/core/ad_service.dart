import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  RewardedAd? rewardedAd;
  bool _loading = false;

  static String get _adUnitId => Platform.isAndroid
      ? 'ca-app-pub-8402438164252136/9208210134'
      : 'ca-app-pub-8402438164252136/9208210134';

  void preload() {
    if (rewardedAd != null || _loading) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          rewardedAd = null;
          _loading = false;
        },
      ),
    );
  }

  void disposeAd() {
    rewardedAd?.dispose();
    rewardedAd = null;
    _loading = false;
  }
}
