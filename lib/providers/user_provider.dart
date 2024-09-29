import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/models/connected_sites_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../constants/colors.dart';
import '../constants/configs.dart';
import '../models/bank_model.dart';
import '../models/payment_card_model.dart';
import 'bank_provider.dart';

class UserProvider with ChangeNotifier {
  late FToast fToast;
  bool otpErrorResponse=false;
  bool otpSuccessResponse=false;
  String? walletAddress;
  String? userName;
  String? firstName;
  String? lastName;
  String? mobileNum;
  String? email;
  String? userAvatar;
  String? idNumber;
  String isEmailVerified = "false";
  var verifiedEmail;
  var userNationality;
  bool navigateToNeoForConnectWallet=false;
  var uniqueIdFromStep1;

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
    // final cookieHeader = 'token=$token';
    print("this is token");
    print(token.toString());

    final response = await http.get(
      url,
      // body: body,
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
print('userdetails' + response.statusCode.toString());
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> cardJsonList = jsonResponse['paymentCards'];
      _paymentCards.clear();
      cardJsonList.forEach((cardJson) {
        PaymentCard card = PaymentCard.fromJson(cardJson);
        _paymentCards.add(card);
      });

      List<dynamic> banksJsonList = jsonResponse['bankAccounts'];
      _banks.clear();
      banksJsonList.forEach((banJson) {
        Bank bank = Bank.fromJson(banJson);
        _banks.add(bank);
        });
      print("new banks");
      print(banksJsonList);
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
      userNationality = jsonResponse['nationality'].toString();

      print("User details getting successfully!");
      print(response.body);
      // _showToast('User details getting successfully!', duration: 6000);
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


  Future<AuthResult> userUpdateStep1({
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String email,
    required BuildContext context,
    required String token,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/update/step1');
    final body = {
      "firstName" : firstName,
      "lastName" : lastName,
      "mobileNumber" : mobileNumber,
      "email" : email,
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
    print('userupdatestep1' + response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);

      final uniqueId = jsonResponse['data']['uniqueId'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uniqueId', uniqueId);
      uniqueIdFromStep1=uniqueId;
      notifyListeners();
      print("uniqueId" + uniqueId);
      otpErrorResponse=false;
      otpSuccessResponse=false;
      return AuthResult.success;
    } else {
      otpErrorResponse=false;
      otpSuccessResponse=false;
      return AuthResult.failure;
    }
  }

  Future<AuthResult> userUpdateStep2({
    required String code,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/update/step2');

    final body = {
      "code": code,
    };

    final response = await http.post(url, body: body,  headers: {
      'X-Unique-Id': '$uniqueIdFromStep1',
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    },);
    print('sending code' + code.toString());
    print('sending unique id' + uniqueIdFromStep1.toString());
    print('userupdateStep2 Response');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      otpErrorResponse=false;
      otpSuccessResponse=true;
      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Updation failed: ${response.body}");
      _showToast('${response.body}');
      otpErrorResponse=true;
      otpSuccessResponse=false;
      notifyListeners();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> userUpdateResendOtp({
    required String token,
    required BuildContext context,

  }) async {
    final url = Uri.parse(BASE_URL + '/user/update/resend-otp');

    final body = {
    };

    final response = await http.post(url, body: body,  headers: {
      'X-Unique-Id': '$uniqueIdFromStep1',
      'Authorization': 'Bearer $token',
    },);
    print('sending unique id' + uniqueIdFromStep1.toString());
    print('userupdateResendOtp Response');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {

      notifyListeners();
      return AuthResult.success;
    } else {
      print("ResendOtp failed: ${response.body}");
      _showToast('${response.body}');

      notifyListeners();
      return AuthResult.failure;
    }
  }



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
      return AuthResult.success;
    } else {
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
        final errorResponse = json.decode(response.body);
        _showToast('${errorResponse['message']}');
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error verifying email: $e');
      // Handle error as necessary
      _showToast('Error verifying email: $e');
      return AuthResult.failure;
    }
  }

  var emailErrorResponse;

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
      final jsonResponse = json.decode(response.body);
      final msg = jsonResponse['message'];
      if (response.statusCode == 201) {
        // Successful request
        print("Email sent successfully!");
        emailErrorResponse= null;
        return AuthResult.success;
      } else {
        final errorResponse = json.decode(response.body);
        print("Email sending failed: ${response.body}");
        emailErrorResponse = errorResponse['message'][0]['message'];
        return AuthResult.failure;
      }
    } catch (e) {
      // Exception occurred during request
      print("Exception occurred: $e");
      _showToast(e.toString());
      return AuthResult.failure;
    }
  }



  _showToast(String message, {int duration = 1000}) {
    Widget toast = Container(
      height: 7.h,
      // width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.sp),
        color: AppColors.profileHeaderDark,
        border: Border.all(
            color: AppColors.hexaGreen,
            width: 1),
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
                        color: AppColors.hexaGreen,
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
            top: 43,
            left: 15,
            right: 15,
          );
        });
  }
}
