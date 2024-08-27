// import 'dart:html';
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hyperpay_plugin/flutter_hyperpay.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:developer' as dev;
//
// import 'package:hyperpay_plugin/model/custom_ui.dart';
// import 'package:hyperpay_plugin/model/custom_ui_stc.dart';
// import 'package:hyperpay_plugin/model/ready_ui.dart';

import 'package:hesa_wallet/constants/configs.dart';

class InAppPaymentSetting {

  // static String getShopperResultUrl(String? paymentId) {
  //
  //   return '$BASE_URL/payable-transactions/process?paymentId=$paymentId';
  // }
  // static  String shopperResultUrl=
  // InAppPaymentSetting.getShopperResultUrl(paymentId);
  //     'http://161.35.16.112:3001/payable-transactions/process';
  static const String shopperResultUrl= "com.testpayment.payment";
  // static const String shopperResultUrl= "unilink://hesawallet.com";
  static const String merchantId= "merchant.com.payments.hesawallet";
  static const String countryCode="SA";
  static const getLang ="en_US";
  // {
  //   if (Platform.isIOS) {
  //     return  "en"; // ar
  //   } else {
  //     return "en_US"; // ar_AR
  //   }
  // }
}