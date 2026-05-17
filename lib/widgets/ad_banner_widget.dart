import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

String get _bannerAdUnitId => Platform.isAndroid
    ? 'ca-app-pub-8402438164252136/3998291659'
    : 'ca-app-pub-8402438164252136/3998291659';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> with RouteAware {
  BannerAd? _ad;
  BannerAd? _loadingAd;
  bool _loaded = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _loadAd();
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
    _loadAd();
  }

  void _loadAd() {
    if (_loadingAd != null) return;
    _retryTimer?.cancel();

    final ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          final newAd = loadedAd as BannerAd;
          if (!mounted) { newAd.dispose(); return; }
          debugPrint('AdBanner: loaded');
          _ad?.dispose();
          setState(() {
            _ad = newAd;
            _loaded = true;
            _loadingAd = null;
          });
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          if (!mounted) return;
          debugPrint('AdBanner: failed to load — ${error.message}');
          setState(() { _loadingAd = null; });
          if (_ad == null) {
            _retryTimer = Timer(const Duration(seconds: 30), _loadAd);
          }
        },
      ),
    );
    _loadingAd = ad;
    ad.load();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    AdBannerWidget.routeObserver.unsubscribe(this);
    _loadingAd?.dispose();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
