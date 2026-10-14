import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  AdService._internal();
  static final AdService instance = AdService._internal();

  // Test ad unit IDs (replace with real IDs in production)
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Banner test ID
    }
    // TODO: Replace with actual banner ad unit ID
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/BANNER_ID';
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Interstitial test ID
    }
    // TODO: Replace with actual interstitial ad unit ID
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/INTERSTITIAL_ID';
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  int _transactionsSinceLastInterstitial = 0;
  static const int _interstitialFrequency = 4; // Show every 4 transactions
  bool _isDisposed = false;

  void initialize() async {
    await MobileAds.instance.initialize();

    // Set test device ID to ensure ads load in development
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['96A39D6D32901C7064299B0E208A0AC0']),
    );

    loadInterstitialAd(); // Pre-load interstitial on initialization
  }

  void loadInterstitialAd() {
    if (_isDisposed) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (_isDisposed) {
            ad.dispose();
            return;
          }
          _interstitialAd?.dispose(); // Dispose any existing ad
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
    if (_isDisposed) return;
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            debugPrint('InterstitialAd onAdShowedFullScreenContent'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('InterstitialAd onAdDismissedFullScreenContent');
          ad.dispose();
          _isInterstitialLoaded = false;
          if (!_isDisposed) {
            loadInterstitialAd(); // Pre-load next interstitial
          }
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('InterstitialAd onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          _isInterstitialLoaded = false;
          if (!_isDisposed) {
            loadInterstitialAd(); // Try to load if failed
          }
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
    if (_isDisposed) return;
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
    _isDisposed = true;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
  }
}