import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:sizer/sizer.dart';
import '../constants/colors.dart';
import '../constants/configs.dart';
class CardProvider with ChangeNotifier{
  late FToast fToast;

  Future<AuthResult> addCard({
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/add-card');
    final body = {};

    final response = await http.post(
      url,
      body: body,
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("Card added successfully!");
      _showToast('Card added successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Card not be added: ${response.body}");
      _showToast('Card not be added');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> tokenizeCardVerify({
    required String token,
    required BuildContext context,
    required String checkoutId,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/tokenize-card-verify');
    final body = {
      'checkoutId': checkoutId
    };

    final response = await http.post(
      url,
      body: body,
      headers: {
        // "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    fToast = FToast();
    fToast.init(context);
    print('tokenizecardverify' + response.body);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("Card added successfully!");
      _showToast('Card added successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Card not be added: ${response.body}");
      _showToast('Card not be added');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> deletePaymentCards({
    required String token,
    required String tokenId,
    // required int index,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/deletePaymentCards');
    final body = {
      "tokenId": tokenId,
    };

    final response = await http.post(
      url,
      body: body,
      headers: {
        // "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    fToast = FToast();
    fToast.init(context);
    print('delete response' + response.body);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("Card Deleted successfully!");
      _showToast('Card Deleted successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Card not be Deleted: ${response.body}");
      _showToast('Card not be Deleted');
      return AuthResult.failure;
    }
  }

  Future<void> saveCardDetails() async {
    final String baseUrl = 'https://test.oppwa.com/v1/tokens';
    final String publicKey = 'your_public_key'; // Replace with your actual public key

    final Map<String, String> headers = {
      'Authorization': 'Bearer $publicKey',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final Map<String, String> body = {
      'paymentBrand': 'VISA', // Change this to the desired card brand
      'card.number': '4111111111111111', // Replace with the card number
      'card.holder': 'John Doe', // Replace with the cardholder's name
      'card.expiryMonth': '12', // Replace with the card's expiry month
      'card.expiryYear': '2025', // Replace with the card's expiry year
      'card.cvv': '123', // Replace with the card's CVV
    };

    final Uri uri = Uri.parse(baseUrl);

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      // Tokenization successful, handle token
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String token = responseData['id'];
      print('Card tokenization successful. Token: $token');
      // You can save the 'token' securely on your device or backend for future use
    } else {
      // Tokenization failed
      print('Card tokenization failed with status: ${response.statusCode}');
      print(response.body);
    }
  }

  void main() {
    saveCardDetails();
  }


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
}



