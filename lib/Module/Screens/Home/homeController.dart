import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../Helper/adHelper.dart';

class HomeController extends GetxController {
  
  bool isload = false;
  @override
  void onInit() {
    // TODO: implement onInit
    bannerAds();
    super.onInit();
  }

  getbanner() {}
  bannerAds() {
    // TODO: Add _bannerAd
  BannerAd? bannerAd;
    isload = true;
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    );
   // bannerAd!.load();
    isload = false;
    update();
  }
}
