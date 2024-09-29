import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import '../constants/configs.dart';

class PaymentFees with ChangeNotifier {
  late FToast fToast;
  var platformMintingFees;
  var networkFees;
  var paymentProcessingFee;
  var totalFees;


  Future<AuthResult> paymentFeesForMintNFT({
    // required double assetPrice,
    // required int entries,
    // required int creatorRoyaltyPercent,
    required String params,
  }) async {
    final url = Uri.parse(BASE_URL + '/payment-fees/calculate');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String creatorRoyaltyPercent = paramsMap['creatorRoyaltyPercent'].toString();
    print("creatorRoyaltyPercent");
    print(creatorRoyaltyPercent);
    final Map<String, dynamic> requestBody = {
      "assetPrice": 0,
      "func": "MintNFT",
      "entries": 1,
      "creatorRoyaltyPercent": creatorRoyaltyPercent,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': "6f382aafe37d128ceaabd2d3238aefb46460176189f5af448209eef88a812d66aa232001",
        },
        body: json.encode(requestBody),
      );

      print("MintNFTFees");
      print(response.body);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        platformMintingFees = responseBody['data']['platformMintingFees'].toString();
        totalFees = responseBody['data']['totalFees'].toString();
        paymentProcessingFee = responseBody['data']['paymentProcessingFee'].toString();
        networkFees = responseBody['data']['networkFees'].toString();
        print("new values " + totalFees+ platformMintingFees+paymentProcessingFee+networkFees);

        return AuthResult.success;
      } else {
        return AuthResult.failure;
      }
    } catch (e) {
      print('Minting Error: $e');
      return AuthResult.failure;
    }
  }



}