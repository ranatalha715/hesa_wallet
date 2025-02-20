import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/providers/user_provider.dart';
import 'package:hesa_wallet/screens/connection_requests_pages/connect_dapp.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:uni_links/uni_links.dart';
import '../constants/app_deep_linking.dart';
import '../constants/colors.dart';
import '../constants/configs.dart';
import '../widgets/local_toast.dart';

class AuthProvider with ChangeNotifier {
  late FToast fToast;
  bool isOverlayVisible = false;
  var uniqueIdFromStep1;
  var codeFromOtpBoxes = '';
  bool otpErrorResponse = false;
  bool otpSuccessResponse = false;

  // Future<AuthResult> logInWithMobile({
  //   required String mobile,
  //   required String code,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     final url = Uri.parse(BASE_URL + '/auth/login/otp');
  //     final body = {
  //       "mobileNumber": "+966" + mobile,
  //       "code": code,
  //     };
  //
  //     final response = await http.post(url,
  //         body: body);
  //     fToast = FToast();
  //     fToast.init(context);
  //     print('loginwithmobileresponse');
  //     print(response.body);
  //     if (response.statusCode == 201) {
  //       print("User logged in successfully!");
  //       final jsonResponse = json.decode(response.body);
  //       final accessToken = jsonResponse['data']['accessToken'];
  //       final refreshToken = jsonResponse['data']['refreshToken'];
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('accessToken', accessToken);
  //       await prefs.setString('refreshToken', refreshToken);
  //       otpErrorResponse = false;
  //       otpSuccessResponse = true;
  //       notifyListeners();
  //       print(Provider.of<UserProvider>(context, listen: false)
  //           .navigateToNeoForConnectWallet);
  //       if (Provider.of<UserProvider>(context, listen: false)
  //           .navigateToNeoForConnectWallet) {
  //         await Future.delayed(const Duration(milliseconds: 500));
  //         await Navigator.of(context)
  //             .pushNamed(ConnectDapp.routeName, arguments: {});
  //       } else {
  //         await Future.delayed(const Duration(milliseconds: 500));
  //         await Navigator.of(context).pushNamedAndRemoveUntil(
  //             'nfts-page', (Route d) => false,
  //             arguments: {});
  //         await getLinksStream().firstWhere((String? link) {
  //           if (link != null) {
  //             Uri uri = Uri.parse(link);
  //             String? operation = uri.queryParameters['operation'];
  //             if (operation != null && operation == 'connectWallet') {
  //               Provider.of<UserProvider>(context, listen: false)
  //                   .navigateToNeoForConnectWallet = true;
  //
  //               // setState(() {
  //               isOverlayVisible = Provider.of<UserProvider>(context,
  //                       listen: false)
  //                   .navigateToNeoForConnectWallet; // Set overlay visibility to true
  //               // });
  //
  //               print("check kro" +
  //                   Provider.of<UserProvider>(context, listen: false)
  //                       .navigateToNeoForConnectWallet
  //                       .toString());
  //               Future.delayed(const Duration(milliseconds: 500));
  //               Navigator.of(context).pushAndRemoveUntil(
  //                 MaterialPageRoute(builder: (context) => ConnectDapp()),
  //                 (Route<dynamic> route) => false,
  //               );
  //             } else {
  //               Provider.of<UserProvider>(context, listen: false)
  //                   .navigateToNeoForConnectWallet = false;
  //
  //               // setState(() {
  //               isOverlayVisible = Provider.of<UserProvider>(context,
  //                       listen: false)
  //                   .navigateToNeoForConnectWallet; // Set overlay visibility to false
  //               // });
  //             }
  //             return true; // Exit the loop after processing
  //           } else {
  //             Provider.of<UserProvider>(context, listen: false)
  //                 .navigateToNeoForConnectWallet = false;
  //
  //             // setState(() {
  //             isOverlayVisible = Provider.of<UserProvider>(context,
  //                     listen: false)
  //                 .navigateToNeoForConnectWallet; // Set overlay visibility to false
  //             // });
  //           }
  //
  //           return false;
  //         });
  //       }
  //       otpErrorResponse = false;
  //       otpSuccessResponse = true;
  //       notifyListeners();
  //
  //       return AuthResult.success;
  //     } else {
  //       print("Login failed: ${response.body}");
  //       otpErrorResponse = true;
  //       otpSuccessResponse = false;
  //       notifyListeners();
  //       return AuthResult.failure;
  //     }
  //   } on TimeoutException catch (e) {
  //     otpErrorResponse = true;
  //     otpSuccessResponse = false;
  //     print("TimeoutException during login: $e");
  //     return AuthResult.failure;
  //   } catch (e) {
  //     otpErrorResponse = true;
  //     otpSuccessResponse = false;
  //     print("Exception during login: $e");
  //     return AuthResult.failure;
  //   }
  // }

  Future<AuthResult> logInWithMobile({
    required String mobile,
    required String code,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(BASE_URL + '/auth/login/otp');
      final body = {
        "mobileNumber": "+966" + mobile,
        "code": code,
      };
      final response = await http.post(url, body: body);
      print('loginwithmobileresponse: ${response.body}');
      if (response.statusCode == 201) {
        print("User logged in successfully!");
        final jsonResponse = json.decode(response.body);
        final accessToken = jsonResponse['data']['accessToken'];
        final refreshToken = jsonResponse['data']['refreshToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        otpErrorResponse = false;
        otpSuccessResponse = true;
        notifyListeners();
        if (Provider.of<UserProvider>(context, listen: false).navigateToNeoForConnectWallet) {
          await Future.delayed(const Duration(milliseconds: 500));
          await Navigator.of(context).pushNamed(ConnectDapp.routeName);
        } else {
          await Future.delayed(const Duration(milliseconds: 500));
          await Navigator.of(context).pushNamedAndRemoveUntil('nfts-page', (Route d) => false);
          final appLinks = AppLinks();
          appLinks.uriLinkStream.listen((Uri uri) {
            debugPrint('Received App Link: $uri');
            String? operation = uri.queryParameters['operation'];
            if (operation != null && operation == 'connectWallet') {
              Provider.of<UserProvider>(context, listen: false).navigateToNeoForConnectWallet = true;
              isOverlayVisible = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => ConnectDapp()),
                      (Route<dynamic> route) => false,
                );
              });
            } else {
              Provider.of<UserProvider>(context, listen: false).navigateToNeoForConnectWallet = false;
              isOverlayVisible = false;
            }
          }).onError((error) {
            print("App Links error: $error");
          });
        }
        otpErrorResponse = false;
        otpSuccessResponse = true;
        notifyListeners();
        return AuthResult.success;
      } else {
        print("Login failed: ${response.body}");
        otpErrorResponse = true;
        otpSuccessResponse = false;
        notifyListeners();
        return AuthResult.failure;
      }
    } on TimeoutException catch (e) {
      otpErrorResponse = true;
      otpSuccessResponse = false;
      print("TimeoutException during login: $e");
      return AuthResult.failure;
    } catch (e) {
      otpErrorResponse = true;
      otpSuccessResponse = false;
      print("Exception during login: $e");
      return AuthResult.failure;
    }
  }


  Future<AuthResult> deleteAccountStep1({
    required String token,
    required String termsAndConditions,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/delete/step1');
    final body = {"termsAndConditions": termsAndConditions};

    final response = await http.post(url, body: body, headers: {
      'Authorization': 'Bearer $token',
    });

    final fToast = FToast();
    fToast.init(context);
    print('delete account');
    print(json.decode(response.body));
    if (response.statusCode == 201) {
      otpErrorResponse = false;
      otpSuccessResponse = false;
      return AuthResult.success;
    } else {
      otpErrorResponse = false;
      otpSuccessResponse = false;
      return AuthResult.failure;
    }
  }

  Future<AuthResult> deleteAccountStep2({
    required String code,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/delete/step2');

    final body = {
      "code": code,
    };

    final response = await http.post(
      url,
      body: body,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('sending code' + code.toString());
    print('sending unique id' + uniqueIdFromStep1.toString());
    print('deleteaccountatep2 Response');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      otpErrorResponse = false;
      otpSuccessResponse = true;
      notifyListeners();
      return AuthResult.success;
    } else {
      otpErrorResponse = true;
      otpSuccessResponse = false;
      notifyListeners();
      return AuthResult.failure;
    }
  }

    Future<AuthResult> logoutUser({
    required String token,
    required String refreshToken,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/auth/logout');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Provider.of<UserProvider>(context, listen: false).clearUserData();
        print('Logout success');
        return AuthResult.success;
      } else {
        print("Logout failed: ${response.body}");
        return AuthResult.failure;
      }
    } catch (e) {
      print("Error during logout: $e");
      return AuthResult.failure;
    }
  }


  Future<AuthResult> sendLoginOTP({
    required String mobile,
    required BuildContext context,
    bool isEnglish =true,
  }) async {
    final url = Uri.parse(BASE_URL + '/auth/send-login-otp');
    final body = {
      "to": "+966" + mobile,
    };

    final response = await http.post(url, body: body,
      headers: {
        // "Content-type": "application/json",
        // "Accept": "application/json",
        'accept-language': isEnglish ? 'eng' : 'ar',
      },
    );
    fToast = FToast();
    fToast.init(context);
    print('send login otp' + response.body);
    if (response.statusCode == 201) {
      print('login Otp Response');
      print("${response.body}");
      final successResponse = json.decode(response.body);
      // localToast(context,  'success'+ successResponse['message']);
      loginErrorResponse = null;
      otpErrorResponse = false;
      otpSuccessResponse = false;
      return AuthResult.success;
    } else {
      print("Something went wrong: ${response.body}");
      final errorResponse = json.decode(response.body);
      loginErrorResponse = errorResponse['message'][0]['message'];
      // localToast(context,  'failure'+ errorResponse['message'][0]['message']);
      otpErrorResponse = false;
      otpSuccessResponse = false;
      return AuthResult.failure;
    }
  }

  Future<AuthResult> sendOTP({
    required BuildContext context,
    required String token,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/otp/send');
    final body = {};

    try {
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
      print('send otp' + response.body);

      if (response.statusCode == 201) {
        otpErrorResponse = false;
        otpSuccessResponse = false;
        return AuthResult.success;
      } else {
        // Show an error message or handle the response as needed
        print("Something went wrong: ${response.body}");
        otpErrorResponse = false;
        otpSuccessResponse = false;
        return AuthResult.failure;
      }
    } catch (e) {
      // Handle the exception
      print("Exception occurred: $e");
      otpErrorResponse = false;
      otpSuccessResponse = false;
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
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Something went wrong: ${response.body}");
      return AuthResult.failure;
    }
  }

  Future<AuthResult> registerNumResendOtp({
    required String token,
    required String medium,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/register/resend-otp');

    final body = {"medium": medium};

    final response = await http.post(
      url,
      body: body,
      headers: {
        'X-Unique-Id': '$uniqueIdFromStep1',
        'Authorization': 'Bearer $token',
      },
    );
    print('sending unique id' + uniqueIdFromStep1.toString());
    print('registerNumResendOtp Response');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      otpErrorResponse = false;
      notifyListeners();
      return AuthResult.success;
    } else {
      print("registerNumResendOtp failed: ${response.body}");
      notifyListeners();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> registerEmailResendOtp({
    required String token,
    required String medium,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/register/resend-otp');

    final body = {"medium": medium};

    final response = await http.post(
      url,
      body: body,
      headers: {
        'X-Unique-Id': '$uniqueIdFromStep1',
        'Authorization': 'Bearer $token',
      },
    );
    print('sending unique id' + uniqueIdFromStep1.toString());
    print('registerEmailResendOtp Response');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      otpErrorResponse = false;
      notifyListeners();
      return AuthResult.success;
    } else {
      print("registerEmailResendOtp failed: ${response.body}");
      notifyListeners();
      return AuthResult.failure;
    }
  }

  var registerUserErrorResponse;

  Future<AuthResult> registerUserStep1({
    required String firstName,
    required String lastName,
    required String nationality,
    required String idType,
    required String idNumber,
    required String mobileNumber,
    required BuildContext context,
    bool isEnglish=true,
  }) async {
    final url = Uri.parse('$BASE_URL/register/step1');
    final body = {
      "firstName": firstName,
      "lastName": lastName,
      "idType": idType,
      "nationality": nationality,
      "idNumber": idNumber,
      "mobileNumber": "+966" + mobileNumber,
    };

    final headers = {
      'Content-Type': 'application/json',
      'accept-language': isEnglish ? 'eng' : 'ar',
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
      print('Register user response');
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        final uniqueId = jsonResponse['data']['uniqueId'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('uniqueId', uniqueId);
        uniqueIdFromStep1 = uniqueId;
        otpErrorResponse = false;
        otpSuccessResponse = false;
        notifyListeners();
        print("uniqueId" + uniqueId);
        final successResponse = json.decode(response.body);
        registerUserErrorResponse = null;
        return AuthResult.success;
      } else {
        final errorResponse = json.decode(response.body);
        print("Registration failed: ${response.body}");
        registerUserErrorResponse = errorResponse['message'][0]['message'];
        otpErrorResponse = false;
        otpSuccessResponse = false;
        return AuthResult.failure;
      }
    } catch (e) {
      // Handle network or other errors
      print("Error during registration: $e");

      otpErrorResponse = false;
      otpSuccessResponse = false;
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
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Verifying failed: ${response.body}");

      notifyListeners();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> registerUserStep2({
    required String code,
    // required String uniqueId,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/register/step2');

    final body = {
      "code": code,
    };

    final response = await http.post(
      url,
      body: body,
      headers: {
        'X-Unique-Id': '$uniqueIdFromStep1',
      },
    );
    print('sending code' + code.toString());
    print('sending unique id' + uniqueIdFromStep1.toString());
    print('registerUserStep2 Response');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      otpErrorResponse = false;
      otpSuccessResponse = true;
      notifyListeners();
      return AuthResult.success;
    } else {
      otpErrorResponse = true;
      otpSuccessResponse = false;
      notifyListeners();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> registerUserStep3({
    required String username,
    required String email,
    required String password,
    bool isEnglish=true,
    required BuildContext context,
  }) async {
    final url = Uri.parse('$BASE_URL/register/step3');
    final body = {
      "username": username,
      "email": email,
      "password": password,
    };

    final headers = {
      'Content-Type': 'application/json',
      'X-Unique-Id': '$uniqueIdFromStep1',
      'accept-language': isEnglish ? 'eng' : 'ar',

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
      print('Register user step3 response');
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 201) {
        // Successful registration
        print("User registered successfully!");
        final jsonResponse = json.decode(response.body);
        print(jsonResponse);

        // final uniqueId = jsonResponse['data']['uniqueId'];
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('uniqueId', uniqueId);
        // uniqueIdFromStep1=uniqueId;
        otpErrorResponse = false;
        otpSuccessResponse = false;
        notifyListeners();

        // print("uniqueId" + uniqueId);
        // final successResponse = json.decode(response.body);
        registerUserErrorResponse = null;
        return AuthResult.success;
      } else {
        final errorResponse = json.decode(response.body);
        registerUserErrorResponse = errorResponse['message'][0]['message'];
        // Registration failed
        print("Registration failed: ${response.body}");
        otpErrorResponse = false;
        otpSuccessResponse = false;
        notifyListeners();
        return AuthResult.failure;
      }
    } catch (e) {
      // Handle network or other errors
      print("Error during registration: $e");
      return AuthResult.failure;
    }
  }

  Future<AuthResult> registerUserStep4({
    required String code,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/register/step4');
    final body = {
      "code": code,
    };

    final response = await http.post(
      url,
      body: body,
      headers: {
        'X-Unique-Id': '$uniqueIdFromStep1',
      },
    );
    print('registerUserStep4 Response');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      otpErrorResponse = false;
      otpSuccessResponse = true;
      notifyListeners();
      return AuthResult.success;
    } else {
      otpErrorResponse = true;
      otpSuccessResponse = false;
      notifyListeners();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> registerUserStep5({
    required String termsAndConditions,
    required String deviceToken,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/register/step5');
    final body = {
      "termsAndConditions": termsAndConditions == "true" ? "true" : "false",
      "deviceToken": deviceToken,
    };

    final response = await http.post(
      url,
      body: body,
      headers: {
        'X-Unique-Id': '$uniqueIdFromStep1',
      },
    );
    print('step 5 body');
    print(uniqueIdFromStep1);
    print(deviceToken);
    print('registerUserStep5 Response');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final accessToken = jsonResponse['data']['accessToken'];
      final refreshToken = jsonResponse['data']['refreshToken'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);
      // await prefs.setString('password', password);
      // await updateFCM(FCM: FCM, token: token, context: context)
      print('true ya false h');
      print(Provider.of<UserProvider>(context, listen: false)
          .navigateToNeoForConnectWallet);
      if (Provider.of<UserProvider>(context, listen: false)
          .navigateToNeoForConnectWallet) {
        await Navigator.of(context)
            .pushNamed(ConnectDapp.routeName, arguments: {});

        // await Provider.of<UserProvider>(context,listen: false).getUserDetails(context: context,
        //     token: accessToken
        // );
        // await AppDeepLinking().openNftApp(
        //   {
        //     "operation": "connectWallet",
        //     "walletAddress": Provider.of<UserProvider>(context,listen: false).walletAddress,
        //     "userName": Provider.of<UserProvider>(context,listen: false).userName,
        //     "userIcon": Provider.of<UserProvider>(context,listen: false).userAvatar,
        //     "loginResponse":response.body.toString()
        //   },
        // );
        print('go to neo');
      } else {
        // forUnlock ?   prefs.setBool('setLockScreen', false): null;
        Future.delayed(Duration(seconds: 3), () async {
          // This code runs after the delay
          print('This message is printed after a 3-second delay.');
          await Navigator.of(context).pushNamedAndRemoveUntil(
              'nfts-page', (Route d) => false,
              arguments: {});
        });
      }
      // loginErrorResponse=null;
      // return AuthResult.success;
      loginErrorResponse = null;
      otpErrorResponse = false;
      otpSuccessResponse = false;
      notifyListeners();
      return AuthResult.success;
    } else {
      final errorResponse = json.decode(response.body);
      print("Login failed: ${response.body}");

      loginErrorResponse = errorResponse['message'][0]['message'];
      //   if(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet){
      // }
      otpErrorResponse = false;
      otpSuccessResponse = false;
      notifyListeners();
      return AuthResult.failure;
    }
  }

  var loginErrorResponse;

  Future<AuthResult> loginWithUsername({
    required String username,
    bool forUnlock = false,
    bool isEnglish = true,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(BASE_URL + '/auth/login');
      final body = {
        "username": username,
        "password": password,
      };

      final response = await http
          .post(url,
              headers: {
                // "Content-type": "application/json",
                // "Accept": "application/json",
                'accept-language': isEnglish ? 'eng' : 'ar',
              },
              body: body)
          .timeout(Duration(seconds: 30)); // Timeout set to 10 seconds
      fToast = FToast();
      fToast.init(context);
      print("login with username response");
      print(response.body);
      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final accessToken = jsonResponse['data']['accessToken'];
        final refreshToken = jsonResponse['data']['refreshToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        // await prefs.setString('password', password);
        // await updateFCM(FCM: FCM, token: token, context: context)
        print('true ya false h');
        print(Provider.of<UserProvider>(context, listen: false)
            .navigateToNeoForConnectWallet);
        if (Provider.of<UserProvider>(context, listen: false)
            .navigateToNeoForConnectWallet) {
          await Navigator.of(context)
              .pushNamed(ConnectDapp.routeName, arguments: {});

          // await Provider.of<UserProvider>(context,listen: false).getUserDetails(context: context,
          //     token: accessToken
          // );
          // await AppDeepLinking().openNftApp(
          //   {
          //     "operation": "connectWallet",
          //     "walletAddress": Provider.of<UserProvider>(context,listen: false).walletAddress,
          //     "userName": Provider.of<UserProvider>(context,listen: false).userName,
          //     "userIcon": Provider.of<UserProvider>(context,listen: false).userAvatar,
          //     "loginResponse":response.body.toString()
          //   },
          // );
          print('go to neo');
        } else {
          forUnlock ? prefs.setBool('setLockScreen', false) : null;
          Future.delayed(Duration(seconds: 1), () {
            // This code runs after the delay
            print('This message is printed after a 3-second delay.');
          });
          await Navigator.of(context).pushNamedAndRemoveUntil(
              'nfts-page', (Route d) => false,
              arguments: {});
        }
        loginErrorResponse = null;
        return AuthResult.success;
      } else {
        final errorResponse = json.decode(response.body);
        print("Login failed: ${response.body}");

        loginErrorResponse = errorResponse['message'][0]['message'];
        //   if(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet){
        // }
        return AuthResult.failure;
      }
    } on TimeoutException catch (e) {
      print("TimeoutException during login: $e");
      loginErrorResponse = e.toString();
      // if(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet) {
      //   await AppDeepLinking().openNftApp(
      //     {
      //       "operation": "connectWallet",
      //       "walletAddress": Provider
      //           .of<UserProvider>(context, listen: false)
      //           .walletAddress,
      //       "userName": Provider.of<UserProvider>(context,listen: false).userName,
      //       "userIcon": Provider.of<UserProvider>(context,listen: false).userAvatar,
      //       "loginResponse": e.toString()
      //     },
      //   );
      // }
      return AuthResult.failure;
    } catch (e) {
      // Catching any other exception that might occur during the login process
      print("Exception during login: $e");
      loginErrorResponse = e.toString();
      // if(Provider.of<UserProvider>(context,listen: false).navigateToNeoForConnectWallet) {
      //   await AppDeepLinking().openNftApp(
      //     {
      //       "walletAddress": Provider.of<UserProvider>(context,listen: false).walletAddress,
      //       "userName": Provider.of<UserProvider>(context,listen: false).userName,
      //       "userIcon": Provider.of<UserProvider>(context,listen: false).userAvatar,
      //       "loginResponse": e.toString()
      //     },
      //   );
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
        "refreshToken": refreshToken,
      };
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print("refresh token response");
      print(response.body);
      print('==' + refreshToken);
      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final accessToken = jsonResponse['data']['accessToken'];
        final refreshToken = jsonResponse['data']['refreshToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        return AuthResult.success;
      } else {
        print(" ${response.body}");
        return AuthResult.failure;
      }
    } on TimeoutException catch (e) {
      return AuthResult.failure;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  Future<AuthResult> updateFCM({
    required String FCM,
    required String token,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(BASE_URL + '/user/update-device-token');
      final body = {
        "deviceToken": FCM,
      };

      final response = await http.post(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print("Fse");
      print(response.body);
      if (response.statusCode == 201) {
        return AuthResult.success;
      } else {
        print(" ${response.body}");
        return AuthResult.failure;
      }
    } on TimeoutException catch (e) {
      return AuthResult.failure;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  var userNameAvailable = true;

  Future<AuthResult> checkUsername({
    required String userName,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(BASE_URL + '/user/check-username/$userName');
      final response = await http.get(
        url,
        headers: {},
      );
      print("check username response");
      print(response.body);
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        print('success response');
        print(extractedData['success']);
        userNameAvailable = extractedData['success'];
        // extractedData['success']==true ? userNameAvailable=true:userNameAvailable=false;
        return AuthResult.success;
      } else {
        print(" ${response.body}");
        return AuthResult.failure;
      }
    } on TimeoutException catch (e) {
      return AuthResult.failure;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  var changePasswordError;

  Future<AuthResult> changePasswordStep1({
    required String token,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    bool isEnglish =true,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/change/password/step1');
    final body = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    };

    final response = await http.post(
      url,
      body: body,
      headers: {
        'Authorization': 'Bearer $token',
        'accept-language': isEnglish ? 'eng' : 'ar',
      },
    );
    fToast = FToast();
    fToast.init(context);
    print('change password step 1' + response.body);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("Password updated successfully!");
      changePasswordError = null;
      otpErrorResponse = false;
      otpSuccessResponse = false;
      return AuthResult.success;
    } else {
      print("Password updation failed: ${response.body}");
      final errorResponse = json.decode(response.body);
      print("Registration failed: ${response.body}");
      changePasswordError = errorResponse['message'][0]['message'];
      otpErrorResponse = false;
      otpSuccessResponse = false;
      return AuthResult.failure;
    }
  }

  Future<AuthResult> changePasswordStep2({
    required String code,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/change/password/step2');

    final body = {
      "code": code,
    };

    final response = await http.post(
      url,
      body: body,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('sending code' + code.toString());
    print('changePasswordstep2 Response');
    print(response.body);
    if (response.statusCode == 201) {
      otpErrorResponse = false;
      otpSuccessResponse = true;
      notifyListeners();
      return AuthResult.success;
    } else {
      otpErrorResponse = true;
      otpSuccessResponse = false;
      notifyListeners();
      return AuthResult.failure;
    }
  }

  _showToast(String message, {int duration = 1000, double height = 60}) {
    Widget toast = Container(
      height: height,
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
            top: 43.0,
            left: 20,
            right: 20,
          );
        });
  }
}
