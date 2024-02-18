// ignore_for_file: constant_identifier_names
import 'dart:io';
import 'package:deep_linking/deep_linking.dart';

class AppDeepLinking {
  // static const NEO_NFT_NAME = "unilink://hesawallet.com";
  static const NEO_NFT_NAME = "unilink://neonft.com";
  initDeeplink() {
    DeepLinking().getDeepLinkStream.listen((event) {
      print(event);
      print(event?.queryParameters);
    });
  }

  openNftApp(Map<String, dynamic>? data) async {
    bool result =
    await DeepLinking().launchApp(appUri:  NEO_NFT_NAME, data: data);
    if (!result) {
      if (Platform.isAndroid) {
        DeepLinking().openAndroidPlayStore(appID: "com.facebook.katana");
      } else {
        DeepLinking().openiOSAppStore(appID: "284882215s");
      }
    }
  }
}