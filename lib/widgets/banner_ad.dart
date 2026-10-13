import 'package:flutter/material.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AdService.instance.buildBannerAd();
  }
}