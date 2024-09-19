import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:hyperpay_plugin/flutter_hyperpay.dart';
import 'package:hyperpay_plugin/model/ready_ui.dart';
import 'package:sizer/sizer.dart';
import '../constants/app_deep_linking.dart';
import '../constants/colors.dart';
import '../constants/configs.dart';
import '../constants/inapp_settings.dart';
import '../models/activity.dart';

class TransactionProvider with ChangeNotifier {
  late FToast fToast;
  var checkoutURL;
  var checkoutId;
  var tokenizedCheckoutId;
  var selectedCardTokenId;
  var selectedCardNum;
  var selectedCardLast4Digits;
  var selectedCardBrand;
  var logoFromNeo;
  var siteUrl;
  var selectedPaymentMethod='cards';
  bool showRedDot=false;

  // var decodedMetaData;

  removeSelectedCardNum(){
    selectedCardNum=null;
    notifyListeners();
  }

  Future<String> decodeMetaData({required String url}) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Successfully fetched data
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData.toString();
    } else {
      // Handle error
      print('Failed to fetch data. Status code: ${response.statusCode}');
      return "";
    }
  }

  List<ActivityModel> _activities = [];

  List<ActivityModel> get activities {
    return [..._activities];
  }
  int currentPage = 1;
  String calculateTimeDifference(String createdAtStr) {
    // Parse the createdAt timestamp and ensure it's in UTC
    DateTime createdAt = DateTime.parse(createdAtStr).toUtc();
    // Get the current time in UTC
    DateTime now = DateTime.now().toUtc();
    // Calculate the difference
    Duration difference = now.difference(createdAt);

    // Debug prints
    print('Created at: $createdAt');
    print('Now: $now');
    print('Difference: $difference');

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months m';
    } else {
      int years = (difference.inDays / 365).floor();
      return '$years y';
    }
  }



  // String calculateTimeDifference(DateTime createdAt) {
  //   DateTime now = DateTime.now();
  //   Duration difference = now.difference(createdAt);
  //
  //   if (difference.inSeconds < 60) {
  //     return '${difference.inSeconds}s';
  //   } else if (difference.inMinutes < 60) {
  //     return '${difference.inMinutes}m';
  //   } else if (difference.inHours < 24) {
  //     return '${difference.inHours}h';
  //   } else if (difference.inDays < 30) {
  //     return '${difference.inDays}d';
  //   } else if (difference.inDays < 365) {
  //     int months =
  //         now.month - createdAt.month + (12 * (now.year - createdAt.year));
  //     return '$months m';
  //   } else {
  //     int years = now.year - createdAt.year;
  //     return '$years y';
  //   }
  // }
  Future<AuthResult> getWalletActivities({
    required String accessToken,
    required BuildContext context,
    bool refresh = false,
  }) async {
    final url = Uri.parse(
      BASE_URL + '/user/wallet-activity?limit=10&page=1',
    );

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      },
    );

    final jsonData = json.decode(response.body);
    print('jsonData' + response.body);

    if (response.statusCode == 200) {
      if (jsonData != null) {
        final List<dynamic> extractedData = jsonData as List<dynamic>;
        print("extracted data" + extractedData.toString());
        final List<ActivityModel> loadedActivities =
        extractedData.map((prodData) {
          final metaData = prodData['metaData'];
          final bool containsCollection = prodData['transactionType']
              .toString()
              .toLowerCase()
              .contains('collection');
          return ActivityModel(
            transactionType: prodData['func'].toString(),
            transactionAmount: prodData['amount']['value'].toString(),
            tokenName: prodData['name'].toString(),
            image: prodData['image'].toString(),
            time:
            // calculateTimeDifference(
                prodData['timestamp'].toString(),
            // ),
            // time: calculateTimeDifference(DateTime.parse(prodData['timestamp'].toString())),
            siteURL: prodData['siteURL'].toString(),
            amountType: prodData['amount']['type'].toString(),
            id: prodData['id'].toString(),
            type: prodData['type'].toString(),
          );
        }).toList();

        _activities = loadedActivities;
        notifyListeners();

        return AuthResult.success;
      } else {
        print("Activity not found in response data");
        return AuthResult.failure;
      }
    } else {
      print("Failed to fetch wallet Activities: ${response.statusCode}");
      return AuthResult.failure;
    }
  }

  // Future<AuthResult> getWalletActivities({
  //   required String accessToken,
  //   required BuildContext context,
  //   bool refresh = false,
  // }) async {
  //   if (refresh) {
  //     currentPage = 1;
  //   }
  //   final url = Uri.parse(
  //     BASE_URL + '/user/wallet-activity?limit=10&page=1',
  //
  //     // BASE_URL + '/user/wallet-activity?limit=10&page=1'
  //   );
  //
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       // "Content-type": "application/json",
  //       "Accept": "application/json",
  //       'Authorization': 'Bearer $accessToken',
  //     },
  //   );
  //   // final dynamic responseBody = json.decode(response.body);
  //   // final jsonData = json.decode(response.body)['data'];
  //   final jsonData = json.decode(response.body);
  //   print('jsonData' + response.body);
  //   if (response.statusCode == 200) {
  //     if (jsonData != null) {
  //       final List<dynamic> extractedData = jsonData as List<dynamic>;
  //       print("extracted data" + extractedData.toString());
  //       final List<ActivityModel> loadedActivities =
  //           extractedData.map((prodData) {
  //         final metaData = prodData['metaData'];
  //         final bool containsCollection = prodData['transactionType']
  //             .toString()
  //             .toLowerCase()
  //             .contains('collection');
  //         return ActivityModel(
  //           transactionType: prodData['func'].toString(),
  //           transactionAmount: prodData['amount']['value'].toString(),
  //           tokenName: prodData['name'].toString(),
  //           // Fetching nameEn
  //           image: prodData['image'].toString(),
  //           time:
  //               calculateTimeDifference(DateTime.parse(prodData['timestamp'])),
  //           siteURL: prodData['siteURL'].toString(),
  //           amountType: prodData['amount']['type'].toString(),
  //           id: prodData['id'].toString(),
  //           type: prodData['type'].toString(),
  //         );
  //       }).toList();
  //       if (refresh) {
  //         _activities = loadedActivities;
  //       } else {
  //         _activities.addAll(loadedActivities);
  //       }
  //       // _activities = loadedActivities;
  //       notifyListeners();
  //       currentPage++;
  //
  //       return AuthResult.success;
  //     } else {
  //       print("Activity not found in response data");
  //       return AuthResult.failure;
  //     }
  //   } else {
  //     print("Failed to fetch wallet Activities: ${response.statusCode}");
  //     return AuthResult.failure;
  //   }
  // }

  var txTimeStamp = '';
  var txType = '';
  var txId = '';
  var txTotalAmount = '';
  var txAmountType = '';
  var txStatus = '';
  var txTokenId = '';
  var txCreatorId = '';
  var txOfferedBy = '';
  var txCreatorRoyalityPercent = '';
  var txCrdNum = '';
  var txCrdBrand = '';
  var txBankImage = '';
  var txBankAccNum = '';
  var receiverBankDetails = '';

  clearTxSummaryData(){
     txTimeStamp = '';
    txType = '';
     txId = '';
    txTotalAmount = '';
    txAmountType = '';
     txStatus = '';
    txTokenId = '';
    txCreatorId = '';
    txOfferedBy = '';
    txCreatorRoyalityPercent = '';
    txCrdNum = '';
    txCrdBrand = '';
     _transactionFeeses=[];
      txBankImage = '';
     txBankAccNum = '';
     receiverBankDetails = "null";
  }


  List<Map<String, dynamic>> _transactionFeeses=[];
  List<Map<String, dynamic>> get transactionFeeses {
    return [..._transactionFeeses];
  }
  late FlutterHyperPay flutterHyperPay;
  Future<void> getCheckOut(BuildContext context, String token) async {
    final url = Uri.parse('https://eu-test.oppwa.com/v1/checkouts');
    final headers = {
      'Authorization':
      'Bearer OGFjN2E0Yzk4YWE1MzM5ZjAxOGFhNzYxOTIwMTAyNWZ8MnpoY2ozY2tXcg==', // unique
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = {
      'entityId': '8ac7a4c78ea8442e018ea86ab2da00c5', // unique
      'amount': '1192.00',
      'currency': 'SAR',
      'paymentType': 'DB',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      flutterHyperPay = FlutterHyperPay(
        shopperResultUrl: InAppPaymentSetting.shopperResultUrl,
        paymentMode: PaymentMode.test,
        lang: 'en_US',
      );
      print('doing payment using checkout id');
      print(json.decode(response.body)['id']);
      payRequestNowReadyUI(
        brandsName: [
          "APPLEPAY",
        ],
        checkoutId: json.decode(response.body)['id'],
        authToken: token,
        context: context,
      );
    } else {
      // dev.log(response.body.toString(), name: "STATUS CODE ERROR");
      print('printing checkout error');
    }
  }

  Future<AuthResult> payRequestNowReadyUI({
    required List<String> brandsName,
    required String checkoutId,
    required String authToken,
    required BuildContext context,
  }) async {
    PaymentResultData paymentResultData;
    paymentResultData = await flutterHyperPay.readyUICards(
      readyUI: ReadyUI(
        brandsName: brandsName,
        checkoutId: checkoutId,
        merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
        countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
        companyNameApplePayIOS: "Hesa Wallet",
        themColorHexIOS: "#000000",

        // FOR IOS ONLY
        // setStorePaymentDetailsMode:
        //     true // store payment details for future use
        // brandName: 'VISA',
        // checkoutId: checkoutId,
        // cardNumber: "4440000009900010",
        // holderName: "test name",
        // month: '01',
        // year: '2039',
        // cvv: '100',
        // enabledTokenization: false,
      ),
    );
    fToast = FToast();
    fToast.init(context);

    if (paymentResultData.paymentResult == PaymentResult.success ||
        paymentResultData.paymentResult == PaymentResult.sync) {
      // print('payment success');
      print("Payment Result ");
      print(paymentResultData.toString());
      // getpaymentstatus(checkoutId);
      // print("checkoutId");
      // print(checkoutId);
      return AuthResult.success;

      // do something
    } else {

      print("Payment Result ");
      print(paymentResultData.errorString);
      return AuthResult.failure;
    }
  }
  Future<AuthResult> getTransactionSummary({
    required String accessToken,
    required String id,
    required String type,
    required BuildContext context,
  }) async {
    try {
      // final url = Uri.parse(BASE_URL + '/user/wallet-activity/$id');
      final url = Uri.parse(BASE_URL + '/user/wallet-activity/$id?type=$type');

      final response = await http.get(
        url,
        headers: {
          // "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );

      final jsonData = json.decode(response.body);
      print('activity details' + response.body);

      if (response.statusCode == 200) {
        if (jsonData != null) {
          txTimeStamp = jsonData['transactionDetails']['timestamp'] ?? 'N/A';
          txType = jsonData['transactionDetails']['txType'] ?? 'N/A';
          txId = jsonData['transactionDetails']['txId'] ?? 'N/A';
          txTotalAmount = jsonData['totalAmount']['value'].toString() ?? 'N/A';
          txAmountType = jsonData['totalAmount']['type'].toString() ?? 'N/A';
          txStatus = jsonData['transactionDetails']['txStatus'] ?? 'N/A';
          txTokenId = jsonData['transactionDetails']['tokenID'] ?? 'N/A';
          txCreatorId = jsonData['transactionDetails']['creatorID'] ?? 'N/A';
          txOfferedBy = jsonData['transactionDetails']['offeredBy'] ?? 'N/A';
          txCreatorRoyalityPercent = jsonData['transactionDetails']
                      ['creatorRoyaltyPercentage']
                  .toString() ??
              'N/A';
          txCrdBrand = jsonData['cardDetails']['type'].toString() ?? 'N/A';
          txCrdNum =
              jsonData['cardDetails']['maskedNumber'].toString() ?? 'N/A';
          receiverBankDetails =
              jsonData['receiverBankDetails'].toString();
          txBankImage = receiverBankDetails != "null" ?
              jsonData['receiverBankDetails']['bankLogo'].toString() : "https://tse1.mm.bing.net/th?id=OIP.tUMAs55tjnci6Imc_jVzMwAAAA&pid=Api&P=0&h=180";
          txBankAccNum =   receiverBankDetails != "null" ?
              jsonData['receiverBankDetails']['accountNumber'].toString():"***********";

          // Fetching fees

          // Map<String, dynamic> transactionFee = jsonData['transactionDetails']['transctionFee'];
          // assetListingFee = transactionFee['assetListingFee']['value']?.toString() ?? 'N/A';
          // networkFees = transactionFee['networkFees']['value']?.toString() ?? 'N/A';
          // paymentProcessingFee = transactionFee['paymentProcessingFee']['value']?.toString() ?? 'N/A';
          // totalFees = transactionFee['totalFees']['value']?.toString() ?? 'N/A';
          //
          // // Fetching labels
          // assetListingLabel = transactionFee['assetListingFee']['label']?.toString() ?? 'N/A';
          // networkLabel = transactionFee['networkFees']['label']?.toString() ?? 'N/A';
          // paymentProcessingLabel = transactionFee['paymentProcessingFee']['label']?.toString() ?? 'N/A';
          // totalLabel = transactionFee['totalFees']['label']?.toString() ?? 'N/A';
          Map<String, dynamic> transactionFee =
              jsonData['transactionDetails']['transctionFee'];

          // Create a list to hold fee items dynamically
          List<Map<String, dynamic>> feesList = [];

          // Iterate over the keys of transactionFee map
          transactionFee.keys.forEach((key) {
            Map<String, dynamic> fee = transactionFee[key];
            feesList.add(fee);
          });

          _transactionFeeses = feesList;

          notifyListeners();
          return AuthResult.success;
        } else {
          print("Activity not found in response data");
          return AuthResult.failure;
        }
      } else {
        print("Failed to fetch wallet Activities: ${response.statusCode}");
        return AuthResult.failure;
      }
    } catch (error) {
      // Handle error here
      print('Error occurred: $error');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> sendTransactionOTP({
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/send-transaction-otp');
    final body = {};

    final response = await http.post(
      url,
      body: body,
      headers: {
        // "Content-type": "application/json",
        // "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("OTP not sent: ${response.body}");
      return AuthResult.failure;
    }
  }

  Future<AuthResult> mintCollectionpayableTransactionSend({
    required String params,
    required String token,
    required String walletAddress,
    required BuildContext context,
    required String mintCollectionId,
    required String ownerId,
    required String operation,
    required String brand,
    required String tokenId,
    required String country,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    paramsMap['creatorWalletAddress'] = yourWalletAddress;
    // Convert the paramsMap to a string
    // String updatedParams = jsonEncode(paramsMap);
    // print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "MintCollection",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": 'tokenization',
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('collection payload to send bilal');
      print(requestBody.toString());
      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        testDialogToCheck(
            context: context,
            title: 'MintCollection not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      testDialogToCheck(
          context: context,
          title: 'MintCollection not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> mintNftpayableTransactionSend({
    required String params,
    required String token,
    required String walletAddress,
    required String country,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    paramsMap['creatorWalletAddress'] = yourWalletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('minting params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "MintNFT",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand" : brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('minitng WAdd to send bilal');
      print(walletAddress);
      print('minitng payload to send bilal');
      print(requestBody.toString());
      print('minting response');

      print(response.body);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Minting Error: ${response.body}");
        testDialogToCheck(
            context: context,
            title: 'Mint NFT not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Minting Error: $e');
      testDialogToCheck(
          context: context,
          title: 'Mint NFT not working',
          description: e.toString());
      functionToNavigateAfterPayable(
        e.toString(),
        operation,
        context,
      );
      return AuthResult.failure;
    }
  }

  Future<AuthResult> mintNFTWithEditions({
    required String params,
    required String token,
    required String walletAddress,
    required String country,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    paramsMap['creatorWalletAddress'] = yourWalletAddress;
    Map<String, dynamic> metadata = paramsMap['metadata'];
    int numberOfEditions = metadata['numberOfEdtions'];
    paramsMap['totalEditions'] = numberOfEditions;
    metadata.remove('numberOfEdtions');
    paramsMap['metadata'] = metadata;
    String updatedParams = jsonEncode(paramsMap);
    print('minting params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "MintNFTWithEditions",
      "walletAddress": walletAddress,
      // "tokenId": '8ac7a4a08d117072018d12975ec70f2f',
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('minitng WAdd to send bilal');
      print(walletAddress);
      print('MintNFTWithEditions payload to send bilal');
      print(requestBody.toString());
      print('MintNFTWithEditions response');

      print(response.body);
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("MintNFTWithEditions Error: ${response.body}");
        testDialogToCheck(
            context: context,
            title: 'MintNFTWithEditions',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('MintNFTWithEditions Error: $e');
      testDialogToCheck(
          context: context,
          title: 'MintNFTWithEditions not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> purchaseNft({
    required String params,
    required String token,
    required String walletAddress,
    required String country,
    required String brand,
    required BuildContext context,
    required String tokenId,
    required String operation,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String yourWalletAddress = walletAddress;
    //
    // paramsMap['creatorWalletAddress'] = yourWalletAddress;
    // paramsMap['price'] = 500;
    // Convert the paramsMap to a string
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "PurchaseNFT",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        testDialogToCheck(
            context: context,
            title: 'PurchaseNFT',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      testDialogToCheck(
          context: context, title: 'PurchaseNFT', description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> purchaseCollection({
    required String params,
    required String token,
    required String walletAddress,
    required String country,
    required String brand,
    required BuildContext context,
    required String tokenId,
    required String operation,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "PurchaseCollection",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        testDialogToCheck(
            context: context,
            title: 'PurchaseCollection',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      testDialogToCheck(
          context: context,
          title: 'PurchaseCollection',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> listNftFixedPrice({
    required String params,
    required String token,
    required String walletAddress,
    required BuildContext context,
    required String tokenId,
    required String brand,
    required String operation,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;

    paramsMap['listedBy'] = yourWalletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "ListNFT",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        testDialogToCheck(
            context: context,
            title: 'ListNFT Fixed price not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      testDialogToCheck(
          context: context,
          title: 'ListNFT Fixed price not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> listCollectionFixedPrice({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    paramsMap['listedBy'] = yourWalletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "ListCollection",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        testDialogToCheck(
            context: context,
            title: 'ListCollection Fixed price not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'ListCollection Fixed price not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> listNftForAuction({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    paramsMap['listedBy'] = yourWalletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "ListNFTForAuction",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      // "params": updatedParams,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'ListNFTForAuction not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'ListNFTForAuction not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> listCollectionForAuction({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    paramsMap['listedBy'] = yourWalletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "ListCollectionForAuction",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      // "params": updatedParams,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'ListCollectionForAuction not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'ListCollectionForAuction not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> burnNFT({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;

    paramsMap['owner'] = yourWalletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "BurnNFT",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      // "params": updatedParams,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'BurnNFT not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'BurnNFT not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> burnCollection({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    paramsMap['owner'] = yourWalletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "BurnCollection",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'BurnCollection not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'BurnCollection not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> makeOffer({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String yourWalletAddress = walletAddress;
    // String collectionId = '8c9b250f-2038-4162-9c9a-6015dc2f16a5';

    // paramsMap['owner'] = yourWalletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "MakeOffer",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'MakeOfferNFT not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'MakeOfferNFT not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> makeOfferCollection({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "MakeCollectionOffer",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'MakeCollectionOffer',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'MakeCollectionOffer',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> acceptCounterOffer({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "AcceptCounterOffer",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'AcceptCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'AcceptCounterOffer',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> acceptCollectionCounterOffer({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String brand,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "AcceptCollectionCounterOffer",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "brand": brand,
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        checkoutURL = responseBody['data']['checkoutURL'];
        checkoutId = responseBody['data']['checkoutId'];
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'acceptCollectionCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'acceptCollectionCounterOffer',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  //non payable
  Future<AuthResult> acceptOffer({
    required String params,
    required String token,
    required String operation,
    required String code,
    required String walletAddress,
    // required String country,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "AcceptOffer",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('accept offer response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        print("send response " + responseBody.toString());
        testDialogToCheck(
            context: context,
            title: 'AcceptOfferNFT',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'AcceptOfferNFT',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation,context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context, title: 'AcceptOfferNFT', description: e.toString());
      functionToNavigateAfterNonPayable(
        e.toString(),
        operation,
        context,
      );
      return AuthResult.failure;
    }
  }

  Future<AuthResult> acceptCollectionOffer({
    required String params,
    required String token,
    required String operation,
    required String code,
    required String walletAddress,
    // required String country,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String yourWalletAddress = walletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "AcceptCollectionOffer",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('AcceptCollectionOffer response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        print("send response " + responseBody.toString());
        testDialogToCheck(
            context: context,
            title: 'AcceptCollectionOffer',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation,context,
            statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'AcceptCollectionOffer',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'AcceptCollectionOffer',
          description: e.toString());
      functionToNavigateAfterNonPayable(
        e.toString(),
        operation,context,
      );
      return AuthResult.failure;
    }
  }

  Future<AuthResult> rejectNFTOfferReceived({
    required String params,
    required String token,
    required String walletAddress,
    required String code,
    required String operation,
    // required String country,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String yourWalletAddress = walletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "RejectOffer",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('reject offer response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'rejectNFTOfferReceived',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation,context,
            statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'rejectNFTOfferReceived',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation,context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'rejectNFTOfferReceived',
          description: e.toString());
      functionToNavigateAfterNonPayable(
        e.toString(),
        operation, context,
      );
      return AuthResult.failure;
    }
  }

  Future<AuthResult> rejectCollectionOfferReceived({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required String code,
    // required String country,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String yourWalletAddress = walletAddress;
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "RejectCollectionOffer",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('RejectCollectionOffer response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'RejectCollectionOffer',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'RejectCollectionOffer',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation,context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'RejectCollectionOffer',
          description: e.toString());
      functionToNavigateAfterNonPayable(
        e.toString(),
        operation,context,
      );
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelNFTOfferMade({
    required String params,
    required String token,
    required String operation,
    required String code,
    required String walletAddress,
    // required String country,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String updatedParams = jsonEncode(paramsMap);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "CancelOffer",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('CancelNFTOfferMade response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelNFTOfferMade',
            description: response.body.toString());
        
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelNFTOfferMade',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelNFTOfferMade',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation, context,);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelAuctionListing({
    required String params,
    required String token,
    required String operation,
    required String code,
    required String walletAddress,
    // required String country,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String updatedParams = jsonEncode(paramsMap);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "CancelAuctionListing",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('CancelAuctionListing response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelAuctionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelAuctionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelAuctionListing',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation, context,);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelCollectionAuctionListing({
    required String params,
    required String token,
    required String operation,
    required String code,
    required String walletAddress,
    // required String country,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String updatedParams = jsonEncode(paramsMap);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "CancelCollectionAuctionListing",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('CancelCollectionAuctionListing response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelCollectionAuctionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelCollectionAuctionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation,context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelCollectionAuctionListing',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation, context,);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelListing({
    required String params,
    required String token,
    required String operation,
    required String code,
    required String walletAddress,
    // required String country,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String updatedParams = jsonEncode(paramsMap);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "CancelListing",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      // fToast = FToast();
      // fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('CancelListing response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        // _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context, title: 'CancelListing', description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation,context,);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelCollectionListing({
    required String params,
    required String token,
    required String operation,
    required String code,
    required String walletAddress,
    // required String country,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String updatedParams = jsonEncode(paramsMap);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "CancelCollectionListing",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('CancelCollectionListing response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelCollectionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelCollectionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelCollectionListing',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation, context,);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelCollectionOfferMade({
    required String params,
    required String token,
    required String operation,
    required String walletAddress,
    required String code,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    // String updatedParams = jsonEncode(paramsMap);
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "CancelCollectionOffer",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": code,
      "params": paramsMap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('CancelCollectionOfferMade response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelCollectionOfferMade not working',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelCollectionOfferMade not working',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation, context,);
      return AuthResult.failure;
    }
  }

  functionToNavigateAfterNonPayable(String response, String operation, BuildContext context,
      {String statusCode = ''}) {
    Future.delayed(const Duration(seconds: 1), () async {
      AppDeepLinking().openNftApp(
        {
          "operation": operation,
          "statusCode": statusCode.toString(),
          "data": response,
          "comments": "Non payable transactions response",
        },
      );
      await Navigator.of(context)
          .pushNamedAndRemoveUntil(
          'nfts-page', (Route d) => false,
          arguments: {});
    });
  }

  functionToNavigateAfterPayable(
      String response, String operation, BuildContext context,
      {String statusCode = ''}) {
    Future.delayed(Duration(seconds: 2), () async {
      //reme later
      print('statusCode' + statusCode.toString());
      AppDeepLinking().openNftApp(
        {
          "operation": operation,
          "statusCode": statusCode.toString(),
          "data": response,
          "comments": "payable transactions response",
        },
      );
      await Navigator.of(context)
          .pushNamedAndRemoveUntil(
          'nfts-page', (Route d) => false,
          arguments: {});
    });
  }

  functionToNavigateAfterCounterOffer(String response, String operation,
      {String statusCode = ''}) {
    Future.delayed(Duration(seconds: 1), () {
      AppDeepLinking().openNftApp(
        {
          "operation": operation,
          "statusCode": statusCode.toString(),
          "data": response,
          "comments": "Counter Offers response",
        },
      );
    });
  }

  ///
  Future<AuthResult> makeCounterOffer({
    // required String params,
    required String token,
    required String operation,
    required BuildContext context,
    required String id,
    required String offererId,
    required String offerAmount,
    required String code,
    required String walletAddress,
  }) async {
    final url = Uri.parse(BASE_URL + '/counter-offer');

    var requestBody = {
      "id": id,
      "offererId": offererId,
      // "offererId": offererId,
      "offerAmount": int.parse(offerAmount),
      "code": code,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('Counter offer response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        // _showToast('Counter Offer Sent!');
        print("send response " + responseBody.toString());
        testDialogToCheck(
            context: context,
            title: 'MakeCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        // _showToast('Counter Offer Not Sent');
        testDialogToCheck(
            context: context,
            title: 'MakeCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      // _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'MakeCounterOffer',
          description: e.toString());
      functionToNavigateAfterCounterOffer(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> makeCollectionCounterOffer({
    // required String params,
    required String token,
    required String operation,
    required BuildContext context,
    required String id,
    required String offererId,
    required String offerAmount,
    required String walletAddress,
    required String code,
  }) async {
    final url = Uri.parse(BASE_URL + '/counter-offer/collection');

    var requestBody = {
      "id": id,
      "offererId": offererId,
      "offerAmount": int.parse(offerAmount),
      "code": code,
    };
    fToast = FToast();
    fToast.init(context);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('payload to send bilal');
      print(requestBody.toString());
      print('Counter offer response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        // _showToast('Counter Offer Sent!');
        print("send response " + responseBody.toString());
        testDialogToCheck(
            context: context,
            title: 'MakeCollectionCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        // _showToast('Counter Offer Not Sent');
        testDialogToCheck(
            context: context,
            title: 'MakeCollectionCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      // _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'MakeCollectionCounterOffer',
          description: e.toString());
      functionToNavigateAfterCounterOffer(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> rejectNFTCounterOffer({
    // required String params,
    required String token,
    required String operation,
    required BuildContext context,
    required String id,
    required String offererId,
    required String offerAmount,
    required String walletAddress,
    required String code,
  }) async {
    final url = Uri.parse(BASE_URL + '/counter-offer/reject');

    var requestBody = {
      "id": id,
      "offererId": offererId,
      "offerAmount": int.parse(offerAmount),
      "code": code,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('Counter offer response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Reject NFTCounter Offer Sent!');
        print("send response " + responseBody.toString());
        testDialogToCheck(
            context: context,
            title: 'RejectNFTCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Reject NFTCounter Offer Not Sent');
        testDialogToCheck(
            context: context,
            title: 'RejectNFTCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      // _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'RejectNFTCounterOffer',
          description: e.toString());
      functionToNavigateAfterCounterOffer(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> rejectCollectionCounterOffer({
    // required String params,
    required String token,
    required String operation,
    required BuildContext context,
    required String id,
    required String code,
    required String offererId,
    required String offerAmount,
    required String walletAddress,
  }) async {
    final url = Uri.parse(BASE_URL + '/counter-offer/collection/reject');

    var requestBody = {
      "id": id,
      "offererId": offererId,
      "code": code,
      "offerAmount": int.parse(offerAmount),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('payload to send bilal');
      print(requestBody.toString());
      print('Counter offer response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Reject CollectionCounter Offer Sent!');
        print("send response " + responseBody.toString());
        testDialogToCheck(
            context: context,
            title: 'RejectCollectionCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Reject CollectionCounter Offer Not Sent');
        testDialogToCheck(
            context: context,
            title: 'RejectCollectionCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      // _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'RejectCollectionCounterOffer',
          description: e.toString());
      functionToNavigateAfterCounterOffer(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> tokenizeCardRequest({
    required String token,
    required String brand,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/tokenize-card-request');
    final Map<String, dynamic> requestBody = {
      "brand": brand,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      fToast = FToast();
      fToast.init(context);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          tokenizedCheckoutId = responseBody['data']['checkoutId'];
        }

        print(response.body);
        return AuthResult.success;
      } else {
        // Handle the error response here if needed
        print("Error: ${response.body}");
        _showToast('Something Went Wrong!');
        return AuthResult.failure;
      }
    } catch (e) {
      // Handle exceptions here
      print('Error: $e');
      _showToast('Something Went Wrong!');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> payableTransactionProcess(
      {required String token,
      required String paymentId,
      required BuildContext context,
      String? operation}) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/process');
    final Map<String, dynamic> requestBody = {
      "paymentId": paymentId,
    };
    print('paymentId for process' + paymentId);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
        // )
        // .timeout(Duration(seconds: 10)
      ); // Set timeout duration as needed

      fToast = FToast();
      fToast.init(context);
      print('process api request body');
      print(requestBody);
      print('process api response');
      print(response.body);
      testDialogToCheck(
          context: context,
          title: 'Process Api Response',
          description: response.body.toString());
      if (response.statusCode == 201) {
        _showToast('Payment Processed Successfully');
        functionToNavigateAfterPayable(
            response.body.toString(), operation!, context,
            statusCode: response.statusCode.toString());

        return AuthResult.success;
      } else {
        // Handle the error response here if needed
        print("Process Api Error: ${response.body}");
        _showToast('Payment Processing Failed');
        functionToNavigateAfterPayable(
            response.body.toString(), operation!, context,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } on TimeoutException catch (error) {
      // Handle timeout error
      print('Process Api Timeout Error: $error');
      _showToast('Request Timeout');
      testDialogToCheck(
          context: context,
          title: 'Process Api Response',
          description: error.toString());
      functionToNavigateAfterPayable(
        error.toString(),
        operation!,
        context,
      );

      return AuthResult.failure;
    } catch (e) {
      // Handle other exceptions here
      print('Process Api Error: $e');

      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'Process Api Response On catch',
          description: e.toString());
      functionToNavigateAfterPayable(
        e.toString(),
        operation!,
        context,
      );
      return AuthResult.failure;
    }
  }

  Future<AuthResult> startTokenization({
    required String token,
    required String tokenizedId,
    required BuildContext context,
    // required String cardNumber,
    // required String expiryMonth,
    // required String expiryYear,
    // required String cvv,
  }) async {
    final url =
        Uri.parse('https://test.oppwa.com/v1/checkouts/$tokenizedId/payment');
    final Map<String, dynamic> requestData = {
      "entityId": '652e7d7916f7d5046389db76',
      // "entityId": tokenizedId,
      // "notificationUrl": 'www.facebook.com',
      // "createRegistration": "true",
    };

    String requestBody = Uri(queryParameters: requestData).query;
    // final Map<String, String> body = {
    //   'card.number': cardNumber,
    //   'card.expiryMonth': expiryMonth,
    //   'card.expiryYear': expiryYear,
    //   'card.cvv': cvv,
    // };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/x-www-form-urlencoded",
          // "Accept": "application/json",
          'Authorization':
              'Bearer OGFjN2E0Y2E4OWUyOTlkYzAxODllZGU2ZGMxNjA1ZDF8cWNtRVREQWM3RQ==',
          // 'Cookie': 'ak_bmsc=284F4B69BA8EC379C4529CED28341A1A~000000000000000000000000000000~YAAQBig0F27zKGCLAQAAuSJQYxUCDJoWOMOxVzPKdy4m7xHsy9PTe+wKH1y/rnw5Rjh3KrWYYDJgR0ahXH2Fs9gFgBDgMDWPMvImJVZ1gcJhdVth/M0++2zDM42IYcAvD4vSaAnEh63DvnIhT3MitiiN8Ami5X5aQBTgc0Js732vV6+zNCfLRY373v9EHq0L5lHkhe+xO/tYaodLcNyUlze+i8s6cSA5VP0macS9/yf3jbRZavXvqx+QG1Xt6lqInVj1hvBMqTiOC9rT/tu7R07Tt1raHpbojZlSW6MYplBoDNz/YxA65bZDEIvp5Iztjxfz3a8TAvTGQSrWCf3OxyygFhQ3IeyqmUdHrwa7fXL5ZsVgKrZkYjPr'
        },
        body:
            // body
            json.encode(requestBody),
      );
      // print(requestBody);
      fToast = FToast();
      fToast.init(context);

      if (response.statusCode == 200) {
        _showToast('Card Tokenized Successfully');

        print(response.body);

        return AuthResult.success;
      } else {
        // Handle the error response here if needed
        print("Error: ${response.body}");
        _showToast('Card Processing Failed');
        return AuthResult.failure;
      }
    } catch (e) {
      // Handle exceptions here
      print('Error: $e');
      _showToast('Error');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> addUserCard({
    required String token,
    required String bin,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + "/user/add-card");
    // String bin = generateRandomSixDigitNumber();
    final Map<String, dynamic> requestBody = {
      "bin": bin,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      fToast = FToast();
      fToast.init(context);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['success'] == true) {
          final paymentLink = responseBody['data']['paymentLink'];
          _showToast('Payment Link Generated: $paymentLink');
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (BuildContext context) {
          //       return PaymentWebView(
          //         targetUrl: paymentLink,
          //       );
          //     },
          //   ),
          // );
          print(responseBody);
          return AuthResult.success;
        } else {
          final errorMessage = responseBody['message'];
          _showToast('Error: $errorMessage');
          return AuthResult.failure;
        }
      } else {
        _showToast('Error: ${response.body}');
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      return AuthResult.failure;
    }
  }

  String generateRandomSixDigitNumber() {
    // Generate a random 6-digit number (between 100000 and 999999)
    final random = Random();
    final min = 100000;
    final max = 999999;
    final randomNumber = min + random.nextInt(max - min);
    return randomNumber.toString();
  }

  // void _showToast(String message) {
  //   // Replace this with your toast notification code
  // }
  //
  // // enum AuthResult { success, failure }

  Future<AuthResult> fetchPayableTransactions({
    required String id,
  }) async {
    final String apiUrl = BASE_URL + '/payable-transactions/process?id=$id';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response if the request is successful
        final Map<String, dynamic> responseBody = json.decode(response.body);
        // Handle the data as needed
        print(responseBody);
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      return AuthResult.failure;
    }
  }

  // Future<String> requestCheckoutId() async {
  //   final String baseUrl = checkoutURL;
  //   final Map<String, dynamic> queryParams = {
  //     'amount': '48.99',
  //     'currency': 'EUR',
  //     'paymentType': 'DB',
  //   };
  //
  //   final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
  //
  //   try {
  //     final response = await http.get(uri);
  //
  //     if (response.statusCode == 200) {
  //       final String? contentType = response.headers['content-type'];
  //
  //       if (contentType != null &&
  //           contentType.toLowerCase().contains('application/json')) {
  //         final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //
  //         if (jsonResponse.containsKey('checkoutId')) {
  //           return jsonResponse['checkoutId'] as String;
  //         }
  //       } else {
  //         // Handle HTML response here
  //         print('Received HTML response: ${response.body}');
  //         // You can show an error message to the user or take other appropriate actions
  //       }
  //     } else {
  //       // Handle HTTP error here
  //       print('HTTP Error: ${response.statusCode}');
  //       // You can show an error message to the user or take other appropriate actions
  //     }
  //   } catch (e) {
  //     // Handle other errors here
  //     print('Error occurred: $e');
  //     // You can show an error message to the user or take other appropriate actions
  //   }
  //
  //   return 'null'; // Return null in case of an error or unexpected response
  //
  // }

  _showToast(String message, {int duration = 1000}) {
    Widget toast = Container(
      height: 60,
      // width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: AppColors.textColorWhite.withOpacity(0.5),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              color: Colors.transparent,
              child: Text(
                message,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                // .toUpperCase(),
                style: TextStyle(
                        color: AppColors.backgroundColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold)
                    .apply(fontWeightDelta: -2),
              ),
            ),
          ),
          // Spacer(),
        ],
      ),
    );

    // Custom Toast Position
    fToast.showToast(
        child: toast,
        toastDuration: Duration(milliseconds: duration),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: Center(child: child),
            top: 43.0,
            left: 20,
            right: 20,
          );
        });
  }

  testDialogToCheck({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
