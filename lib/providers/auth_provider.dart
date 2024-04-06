import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../constants/app_deep_linking.dart';
import '../constants/colors.dart';
import '../constants/configs.dart';

class AuthProvider with ChangeNotifier {
  late FToast fToast;
  bool isOverlayVisible = false;

  // var tokenizedUserPayload;

  Future<AuthResult> signInWithMobile({
    required String mobile,
    required String code,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/auth/login/otp');
    final body = {
      "mobileNumber": "+966" + mobile,
      "code": code,
    };

    final response = await http.post(url, body: body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("Logged in successfully!");
      print(response.body);
      _showToast('Logged in successfully!');
      final jsonResponse = json.decode(response.body);

      // Get the wsToken from the response
      // final wsToken = jsonResponse['data']['wsToken'];
      final accessToken = jsonResponse['data']['accessToken'];

      // Save the wsToken in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('wsToken', wsToken);
      await prefs.setString('accessToken', accessToken);

      if(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet){
        await Provider.of<UserProvider>(context,listen: false).getUserDetails(context: context,
            token: accessToken
        );
        await AppDeepLinking().openNftApp(
          {
            "operation": "connectWallet",
            "Wallet Address": Provider.of<UserProvider>(context,listen: false).walletAddress,
            "comments":
            "coming back from hesa wallet app with wallet address",
          },

        );
        print('go to neo');
      }
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Login failed: ${response.body}");
      _showToast('Login failed');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> updateInformation({
    required String username,
    required String image,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/update');
    final body = {
      "username": username,
      "displayPicture": image,
    };

    final response = await http.post(url, body: body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("Information updated successfully!");
      _showToast('Information updated successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Something went wrong: ${response.body}");
      _showToast('Something went wrong');
      return AuthResult.failure;
    }
  }


  Future<AuthResult> deleteAccount({
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/delete-account');
    final specialToken =
        "726d7a62edbddc32ba6cafaa2805484b4c7659ffa999f27b0b09ba8db27f017d";
    // final body = {
    //   "email": email,
    // };
    final body = {};

    final response = await http.post(url, body: body, headers: {
      'Authorization': 'Bearer $specialToken',
    });

    final fToast = FToast();
    fToast.init(context);

    if (response.statusCode == 201) {
      // Successful account deletion, handle navigation or other actions
      print("Account deleted successfully!");
      _showToast('Account deleted successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Account deletion failed: ${response.body}");
      _showToast('Account deletion failed');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> logoutUser({
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/auth/logout');
    final body = {};

    final response = await http.post(
      url,
      body: body,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    fToast = FToast();
    fToast.init(context);

    final jsonResponse = json.decode(response.body);
    final msg = jsonResponse['msg'];
    if (response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();

      print(msg); // Print the message
      _showToast(msg); // Show the message in _showToast
      return AuthResult.success;
    } else {
      print("Log out failed: ${response.body}");
      _showToast(msg);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> sendLoginOTP({
    required String mobile,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/auth/send-login-otp');
    final body = {
      "to": "+966" + mobile,
    };

    final response = await http.post(url, body: body);
    fToast = FToast();
    fToast.init(context);
    print('send login otp' + response.body);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("${response.body}");
      _showToast('OTP sent successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Something went wrong: ${response.body}");
      _showToast('Something went wrong');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> resendRegisterOTP({
    required String tokenizedUserPL,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/resend-otp');
    final body = {
      "tokenizedUserPayload": tokenizedUserPL,
    };

    final response = await http.post(
      url,
      body: body,
      headers: {
        // "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $tokenizedUserPL',
      },
    );
    fToast = FToast();
    fToast.init(context);
    print('resend response ' + response.body);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("${response.body}");
      _showToast('OTP sent successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Something went wrong: ${response.body}");
      _showToast('Something went wrong');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> registerUser({
    required String firstName,
    required String lastName,
    required String idType,
    required String idNumber,
    required String userName,
    required String password,
    required String deviceToken,
    required String mobileNumber,
    required BuildContext context,
  }) async {
    final url = Uri.parse('$BASE_URL/auth/register');
    final body = {
      "firstName": firstName,
      "lastName": lastName,
      "idType": idType,
      "idNumber": idNumber,
      "userName": userName,
      "password": password,
      "mobileNumber": "+966" + mobileNumber,
      "deviceToken": deviceToken,
    };

    final headers = {
      'Content-Type': 'application/json',
      // Add any other headers here (e.g., authentication headers)
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body), // Encode the body as JSON
      );
      fToast = FToast();
      fToast.init(context);
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 201) {
        // Successful registration
        print("User registered successfully!");
        final jsonResponse = json.decode(response.body);
        var tokenizedUserPayload;
        tokenizedUserPayload = jsonResponse['data']['tokenizedUserPayload'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('tokenizedUserPayload', tokenizedUserPayload);
        print("tokenizedUserPayload" + tokenizedUserPayload);
        _showToast('User registered successfully!');
        return AuthResult.success;
      } else {
        // Registration failed
        print("Registration failed: ${response.body}");
        _showToast('Registration failed');
        return AuthResult.failure;
      }
    } catch (e) {
      // Handle network or other errors
      print("Error during registration: $e");
      _showToast('Registration failed');
      return AuthResult.failure;
    }
  }



  Future<AuthResult> verifyUser({
    required String mobile,
    required String code,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/verify');
    final body = {
      "to": "+966" + mobile,
      "code": code,
      "tokenizedUserPayload": token.toString(),
    };
    print(mobile);
    print(code);
    print(token);

    final response = await http.post(url, body: body);
    print('verify api response');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("User registered successfully!");
      _showToast('User registered successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Verifying failed: ${response.body}");
      _showToast('Registration failed');
      return AuthResult.failure;
    }
  }


  Future<AuthResult> loginWithUsername({
    required String username,
    required String password,

    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(BASE_URL + '/auth/login');
      final body = {
        "username": username,
        "password": password,
      };

      final response = await http.post(url, body: body).timeout(Duration(seconds: 30)); // Timeout set to 10 seconds
      fToast = FToast();
      fToast.init(context);
      print("login with username response");
      print(response.body);
      if (response.statusCode == 201) {
        // Successful login
        print("User logged in successfully!");
        _showToast('User logged in successfully!');

        // Parse the response JSON
        final jsonResponse = json.decode(response.body);
        final accessToken = jsonResponse['data']['accessToken'];
        final refreshToken = jsonResponse['data']['refreshToken'];

        // Save the wsToken in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        await prefs.setString('password', password);

        print('true ya false');
        print(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet);
        // if(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet){
          await Provider.of<UserProvider>(context,listen: false).getUserDetails(context: context,
              token: accessToken
          );
          await AppDeepLinking().openNftApp(
            {
              "operation": "connectWallet",
              "walletAddress": Provider.of<UserProvider>(context,listen: false).walletAddress,
              "userName": Provider.of<UserProvider>(context,listen: false).userName,
              "userIcon": Provider.of<UserProvider>(context,listen: false).userAvatar,
              "loginResponse":response.body.toString()
            },
          );
          print('go to neo');
        // }
        return AuthResult.success;
      } else {
        // Show an error message or handle the response as needed
        print("Login failed: ${response.body}");
        _showToast('Login failed');
        if(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet){
      }
        return AuthResult.failure;
      }
    } on TimeoutException catch (e) {
      // Handle timeout exception
      print("TimeoutException during login: $e");
      // _showToast('Timeout occurred during login');
      // if(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet) {
        await AppDeepLinking().openNftApp(
          {
            "operation": "connectWallet",
            "walletAddress": Provider
                .of<UserProvider>(context, listen: false)
                .walletAddress,
            "userName": Provider.of<UserProvider>(context,listen: false).userName,
            "userIcon": Provider.of<UserProvider>(context,listen: false).userAvatar,
            "loginResponse": e.toString()
          },
        );
      // }
      return AuthResult.failure;
    } catch (e) {
      // Catching any other exception that might occur during the login process
      print("Exception during login: $e");
      _showToast('An error occurred during login');
      // if(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet) {
        await AppDeepLinking().openNftApp(
          {
            "walletAddress": Provider.of<UserProvider>(context,listen: false).walletAddress,
            "userName": Provider.of<UserProvider>(context,listen: false).userName,
            "userIcon": Provider.of<UserProvider>(context,listen: false).userAvatar,
            "loginResponse": e.toString()
          },
        );
      // }
      return AuthResult.failure;
    }
  }


  Future<AuthResult> refreshToken({
    required String refreshToken,
    required String token,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(BASE_URL + '/auth/refresh-token');
      final body = {
        "refreshToken" : refreshToken,
      };

      final response = await http.post(url, body: body,
        headers: {
        'Authorization': 'Bearer $token',
      },
      ); // Timeout set to 10 seconds
      // fToast = FToast();
      // fToast.init(context);
      print("refresh token response");
      print(response.body);
      print('=='+refreshToken);
      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final accessToken = jsonResponse['data']['accessToken'];
        final refreshToken = jsonResponse['data']['refreshToken'];

        // Save the wsToken in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);

        // _showToast('Token Refreshed Successfully!');
        // }
        return AuthResult.success;
      } else {
        print(" ${response.body}");
        // _showToast('Token Refreshed failed');
        return AuthResult.failure;
      }
    } on TimeoutException catch (e) {
      // _showToast('Token Refreshed failed');
      return AuthResult.failure;
    } catch (e) {
      // _showToast('Token Refreshed failed');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/change-password');
    final body = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
    };


    final response = await http.post(url, body: body,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    fToast = FToast();
    fToast.init(context);
    print('update password' + response.body);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("Password updated successfully!");
      _showToast('Password updated successfully!');
      return AuthResult.success;
    } else {
      // print("Password updated successfully!");
      // _showToast('Password updated successfully!');
      // return AuthResult.success;
      // Show an error message or handle the response as needed
      print("Password updation failed: ${response.body}");
      _showToast('Password updation failed');
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
