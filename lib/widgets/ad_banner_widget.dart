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
    // Başka ekrandan bu ekrana geri dönüldüğünde yeniden yükle
    _loadAd();
  }

  void _loadAd() {
    _retryTimer?.cancel();
    _ad?.dispose();
    if (mounted) setState(() { _loaded = false; _ad = null; });

    final ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (failedAd, _) {
          failedAd.dispose();
          if (!mounted) return;
          setState(() { _ad = null; _loaded = false; });
          // 5 saniye sonra tekrar dene
          _retryTimer = Timer(const Duration(seconds: 5), _loadAd);
        },
      ),
    );
    ad.load();
    if (mounted) setState(() => _ad = ad);
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    AdBannerWidget.routeObserver.unsubscribe(this);
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
