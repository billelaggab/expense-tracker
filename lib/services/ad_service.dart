import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  AdService._internal();
  static final AdService instance = AdService._internal();

  // Test ad unit IDs (replace with real IDs in production)
  static String get _bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Banner test ID
    }
    // TODO: Replace with actual banner ad unit ID
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/BANNER_ID';
  }

  static String get _interstitialAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Interstitial test ID
    }
    // TODO: Replace with actual interstitial ad unit ID
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/INTERSTITIAL_ID';
  }

  static String get _androidAppId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544~3347511713';
    }
    // TODO: Replace with actual Android app ID
    return 'ca-app-pub-XXXXXXXXXXXXXXXX~ANDROID_ID';
  }

  static String get _iOSAppId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544~1458002511';
    }
    // TODO: Replace with actual iOS app ID
    return 'ca-app-pub-XXXXXXXXXXXXXXXX~IOS_ID';
  }

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  int _transactionsSinceLastInterstitial = 0;
  static const int _interstitialFrequency = 4; // Show every 4 transactions

  void initialize() {
    MobileAds.instance.initialize();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => debugPrint('BannerAd loaded'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => debugPrint('BannerAd opened'),
        onAdClosed: (Ad ad) => debugPrint('BannerAd closed'),
      ),
    );
  }

  void loadBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = createBannerAd()..load();
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  Widget buildBannerAd() {
    if (_bannerAd == null) {
      loadBannerAd();
      return const SizedBox(
        width: double.infinity,
        height: 50,
      );
    }
    return AdWidget(ad: _bannerAd!);
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          debugPrint('InterstitialAd loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failedToLoad: $error');
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            debugPrint('InterstitialAd onAdShowedFullScreenContent'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('InterstitialAd onAdDismissedFullScreenContent');
          ad.dispose();
          _isInterstitialLoaded = false;
          loadInterstitialAd(); // Pre-load next interstitial
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('InterstitialAd onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          _isInterstitialLoaded = false;
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      debugPrint('InterstitialAd not ready');
      loadInterstitialAd(); // Try to load if not ready
    }
  }

  void incrementTransactionCounter() {
    _transactionsSinceLastInterstitial++;
    if (_transactionsSinceLastInterstitial >= _interstitialFrequency) {
      _transactionsSinceLastInterstitial = 0;
      showInterstitialAd();
    }
  }

  void resetTransactionCounter() {
    _transactionsSinceLastInterstitial = 0;
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}