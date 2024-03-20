import 'dart:convert';
import 'dart:io';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/models/connected_sites_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../constants/colors.dart';
import 'package:dio/dio.dart';
import '../constants/configs.dart';
import '../models/bank_model.dart';
import '../models/payment_card_model.dart';
import 'bank_provider.dart';

class UserProvider with ChangeNotifier {
  late FToast fToast;
  // var walletAddress;
  String? walletAddress;
  String? userName;
  String? firstName;
  String? lastName;
  String? mobileNum;
  String? email;
  String? userAvatar;
  String? idNumber;
  var isEmailVerified;
  var verifiedEmail;
  bool navigateToNeoForConnectWallet=false;

  List<PaymentCard> _paymentCards = [];

  List<PaymentCard> get paymentCards {
    return [..._paymentCards];
  }

  List<Bank> _banks = [];

  List<Bank> get banks {
    return [..._banks];
  }

  List<ConnectedSites> _connectedSites = [];

  List<ConnectedSites> get connectedSites {
    return [..._connectedSites];
  }

  Future<AuthResult> getUserDetails({
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user');
    // final body = {};
    final cookieHeader = 'token=$token';

    final response = await http.get(
      url,
      // body: body,
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 200) {
      // Successful login, handle navigation or other actions
      final jsonResponse = json.decode(response.body);
      // List<PaymentCard> paymentCards = [];

      List<dynamic> cardJsonList = jsonResponse['paymentCards'];
      _paymentCards.clear();
      cardJsonList.forEach((cardJson) {
        PaymentCard card = PaymentCard.fromJson(cardJson);
        _paymentCards.add(card);
      });
      // print("cardJsonList");
      // print(cardJsonList);
      List<dynamic> banksJsonList = jsonResponse['bankAccounts'];
      _banks.clear();
      banksJsonList.forEach((banJson) {
        Bank bank = Bank.fromJson(banJson);
        _banks.add(bank);
        });
      walletAddress = jsonResponse['accounts'][0]['walletAddress'];
      userName = jsonResponse['userName'];
      mobileNum = jsonResponse['mobileNumber'];
      firstName = jsonResponse['firstName'];
      lastName = jsonResponse['lastName'];
      idNumber = jsonResponse['idNumber'];
      userName = jsonResponse['userName'];
      userAvatar = jsonResponse['userAvatar'];
      isEmailVerified = jsonResponse['isEmailVerified'].toString();
      verifiedEmail = jsonResponse['email'].toString();

      print("User details getting successfully!");
      print(jsonResponse);
      // _showToast('User details getting successfully!');
      List<dynamic>? sitesJsonList = jsonResponse['connectedSites'];
      _connectedSites.clear(); // Clear the list before adding new items

      sitesJsonList?.forEach((siteJson) {
        if (siteJson is String && siteJson != null) {
          _connectedSites.add(ConnectedSites.fromJson(siteJson));
        }
      });

      // print('Connected Sites.com');
      // print(_connectedSites.isNotEmpty ? _connectedSites[2].urls : 'List is empty or index 2 is out of bounds');



      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("User details not found: ${response.body}");
      // _showToast('User details not found');
      return AuthResult.failure;
    }
  }


  Future<AuthResult> userUpdate({
    required BuildContext context,
    required String token,
    required String editableFirstName,
    // required String lastName,
    required String editableMobileNum,
    // required String email,
    // required String idNumber,
    // required String userName,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/update');
    final body = {
     "firstName" : editableFirstName,
     // "lastName" : lastName,
     "mobileNumber" : editableMobileNum,
     // "email" : email,
     // "userName" : userName,
     // "idNumber" : idNumber,
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
    print('' + response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("User updated successfully!");
      _showToast('User updated successfully!');
      // Perform any additional actions upon successful bank addition
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("User is not updated yet: ${response.body}");
      _showToast('User is not updated yet');
      return AuthResult.failure;
    }
  }



  // Future<AuthResult> getUserDetails({
  //   required String token,
  //   required BuildContext context,
  // }) async {
  //   final dio = Dio();
  //   final url =
  //       BASE_URL + '/user'; // Replace BASE_URL with your actual base URL
  //
  //   // Create a Dio options object with the token as a cookie
  //   final options = Options(headers: {
  //     // 'Cookie': 'token=$token',
  //     'User-Agent': 'PostmanRuntime/7.33.0',
  //   });
  //
  //   try {
  //     final response = await dio.get(url, options: options);
  //
  //     fToast = FToast();
  //     fToast.init(context);
  //
  //     if (response.statusCode == 200) {
  //       // Successful response handling here
  //       final jsonResponse = json.decode(response.data.toString());
  //       walletAddress = jsonResponse['accounts'][0]['walletAddress'];
  //
  //       print("User details getting successfully!");
  //       print(jsonResponse);
  //       _showToast('User details getting successfully!');
  //       return AuthResult.success;
  //     } else if (response.statusCode == 403) {
  //       // Handle a 403 error (Forbidden)
  //       print("Permission denied: ${response.data}");
  //       _showToast('Permission denied. Check your token or permissions.');
  //       return AuthResult.failure;
  //     } else {
  //       // Handle other status codes as needed
  //       print("Request failed with status code: ${response.statusCode}");
  //       _showToast('Request failed with status code: ${response.statusCode}');
  //       return AuthResult.failure;
  //     }
  //   } catch (e) {
  //     // Handle network errors or exceptions
  //     print('Error: $e');
  //     _showToast('Error fetching user details');
  //     return AuthResult.failure;
  //   } finally {
  //     dio.close(); // Close the Dio instance to free up resources
  //   }
  // }


  Future<AuthResult> connectDapps({
    required String siteUrl,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/connect-dapp');
    final body = {
      "url": siteUrl,
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
    print(response.body + 'connect Dapp Response');
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("Successuly connected this site");
      _showToast('Successuly connected this site');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Url not found: ${response.body}");
      _showToast('This site is already connected');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> disconnectDapps({
    required String siteUrl,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/disconnect-dapp');
    final body = {
      "url": siteUrl,
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
    print("printing response");
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("");
      _showToast('Successuly disconnected this site');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Revoked all failed: ${response.body}");
      _showToast('Disconnected site failed');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> verifyEmail({
    required String email,
    required BuildContext context,
    required String token,
  }) async {
    try {
      final url = Uri.parse(BASE_URL + '/user/verify-email');
      final body = {
        "email": email,

      };
      final response = await http.post(url, body: body,
        headers: {
          // "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },

      );
      fToast = FToast();
      fToast.init(context);
      if (response.statusCode == 201) {
        // Successful login, handle navigation or other actions
        print("Email verification sent successfully!");
        _showToast('Email verified successfully!');
        return AuthResult.success;
      } else {
        // Show an error message or handle the response as needed
        print("Email verified failed: ${response.body}");
        _showToast('Email verified failed');
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error verifying email: $e');
      // Handle error as necessary
      _showToast('Error verifying email');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> forgotPassword({
    required String email,
    required BuildContext context,
    // required String token,
  }) async {
    try {
      final url = Uri.parse(BASE_URL + '/user/forgot-password');
      final body = {"email": email};

      final response = await http.post(
        url,
        body: body,
      );
      fToast = FToast();
      fToast.init(context);
      print('forgot password response' + response.body);
      if (response.statusCode == 201) {
        // Successful request
        print("Email sent successfully!");
        _showToast('Email sent successfully!');
        return AuthResult.success;
      } else {
        // Request failed
        print("Email sending failed: ${response.body}");
        _showToast('Email sending failed');
        return AuthResult.failure;
      }
    } catch (e) {
      // Exception occurred during request
      print("Exception occurred: $e");
      _showToast('An error occurred');
      return AuthResult.failure;
    }
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
