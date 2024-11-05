import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../constants/colors.dart';
import '../constants/configs.dart';
import '../models/bank_model.dart';

class BankProvider with ChangeNotifier{
  late FToast fToast;

  List<BankName> _banks = [];

  List<BankName> get banks {
    return [..._banks];
  }

  var selectedBank = "";
  var selectedBankName = "";
  bool otpErrorResponse=false;
  bool otpSuccessResponse=false;
  var uniqueIdFromStep1;

  Future<AuthResult> addBankAccount({
  required String token,
  // required String bankName,
  required String ibanNumber,
  required String bankBic,
  // required String beneficiaryName,
  required String code,
  required BuildContext context,
  }) async {
  final String url = BASE_URL + '/user/add-bank-account';
  final Map<String, dynamic> body = {
  // "beneficiaryBank": bankName,
  // "beneficiaryBankAddress": "CBC",
  // "beneficiaryBankClearingCode": "02",
  // "beneficiaryBankCode": "CBC",
  // "beneficiaryAccountNo": "858888888",
  // "beneficiaryName": beneficiaryName,
  // "beneficiaryAddress": "Karachi",
  "isPrimary": true,
  "accountNumber": ibanNumber,
  "bic": bankBic,
  "code": code,
  };

  final response = await http.post(
  Uri.parse(url),
  body: json.encode(body),
  headers: {
  "Content-Type": "application/json",
  "Accept": "application/json",
  'Authorization': 'Bearer $token',
  },
  );
  fToast = FToast();
  fToast.init(context);
  print('addbankresponse');
  print(response.body);
  if (response.statusCode == 201) {
  final responseData = json.decode(response.body);
  if (responseData['success']) {
  print("Bank Added");
  // Perform any additional actions upon successful bank addition
  return AuthResult.success;
  } else {
  print("Failed to add bank account: ${responseData['message']}");
  // Show an error message or handle the failure as needed
  return AuthResult.failure;
  }
  } else {
  print("Failed to add bank account. Status code: ${response.body}");
  return AuthResult.failure;
  }
  }


  var addBankErrorResponse;


  Future<AuthResult> addBankAccountStep1({
    required String token,
    required String ibanNumber,
    required String bankBic,
    required String accountTitle,
    bool isEnglish =true,
    required BuildContext context,
  }) async {
    final String url = BASE_URL + '/user/bank-account/add/step1';
    final Map<String, dynamic> body = {
      "accountNumber": ibanNumber,
      "accountTitle": accountTitle,
      "bic": bankBic,
      "isPrimary": true,
    };

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept-language': isEnglish ? 'eng' : 'ar',
      },
    );
    fToast = FToast();
    fToast.init(context);
    print('addbankStep1');
    print(response.body);
    // print(body);
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final uniqueId = responseData['data']['uniqueId'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uniqueId', uniqueId);
      uniqueIdFromStep1=uniqueId;
       otpErrorResponse=false;
       otpSuccessResponse=false;
      notifyListeners();
      print("uniqueId" + uniqueId);
      if (responseData['success']) {
        print("Bank Added");
        addBankErrorResponse=null;
        return AuthResult.success;
      } else {

        print("Failed to add bank account: ${responseData['message']}");

        return AuthResult.failure;
      }
    } else {
      final errorResponse = json.decode(response.body);
      print("Failed to add bank account. Status code: ${response.body}");
      addBankErrorResponse = errorResponse['message'][0]['message'];
       otpErrorResponse=false;
       otpSuccessResponse=false;
      return AuthResult.failure;
    }
  }

  Future<AuthResult> addBankAccountStep2({
    required String code,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/bank-account/add/step2');

    final body = {
      "code": code,

    };

    final response = await http.post(url, body: body,  headers: {
      'X-Unique-Id': '$uniqueIdFromStep1',
      'Authorization': 'Bearer $token',
    },);
    print('addbankStep2');
    print(response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      otpErrorResponse=false;
      otpSuccessResponse=true;
      notifyListeners();
      return AuthResult.success;
    } else {
      otpErrorResponse=true;
      otpSuccessResponse=false;
      notifyListeners();
      return AuthResult.failure;
    }
  }


  Future<AuthResult> getAllBanks(String token) async {
    final String url = BASE_URL + '/bank-info';
    try {
      final response = await http.get(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
      );
      final jsonResponse = json.decode(response.body);
      print('Get bank list');
      print(jsonResponse);
      if (response.statusCode == 200) {
        List<dynamic> banksJsonList = jsonResponse;
        _banks.clear();
        banksJsonList.forEach((banJson) {
          BankName bank = BankName.fromJson(banJson);
          _banks.add(bank);
        });
        // final List<Map<String, dynamic>> banks = List<Map<String, dynamic>>.from(json.decode(response.body));
        // return banks;
        return AuthResult.success;
      } else {
        print('Failed to fetch banks. Status code: ${response.statusCode}');
        // return []; // Return an empty list in case of failure
        return AuthResult.failure;
      }

    } catch (error) {
      print('Error fetching banks: $error');
      // return []; // Return an empty list in case of an error
      return AuthResult.failure;
    }

  }



  Future<AuthResult> updateBankAccount({
    required bool isPrimary,
    required int index,
    required String accountNumber,
    required String bic,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/update-bank-account');
    final body = {
      "index": index.toString(),
      "isPrimary": isPrimary.toString(),
      "accountNumber" : accountNumber.toString(),
      "bic" : bic.toString(),
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
    print('updated bank response' + response.body);
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      print("Update bank successfully!");
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Bank is not updated yet: ${response.body}");
      return AuthResult.failure;
    }
  }

  Future<AuthResult> updateBankAccountAsPrimaryStep1({
    required bool isPrimary,
    required String accountNumber,
    // required String accountTitle,
    // required String bic,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/bank-account/update/step1');
    final body = {
      "accountNumber" : accountNumber.toString(),
      // "accountTitle": accountTitle.toString(),
      // "bic" : bic.toString(),
      "isPrimary": isPrimary.toString(),
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
    print('updatedBody' + body.toString());
    print('updatedbankresponseStep1' + response.body);
    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final uniqueId = jsonResponse['data']['uniqueId'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uniqueId', uniqueId);
      uniqueIdFromStep1=uniqueId;
      otpErrorResponse=false;
      otpSuccessResponse=false;
      notifyListeners();
      print("Update bank successfully!");
      return AuthResult.success;
    } else {
      print("Bank is not updated yet: ${response.body}");
      otpErrorResponse=false;
      otpSuccessResponse=false;
      return AuthResult.failure;
    }
  }

  Future<AuthResult> updateBankAccountStep1({
    required bool isPrimary,
    required String accountNumber,
    required String accountTitle,
    required String bic,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/bank-account/update/step1');
    final body = {
      "accountNumber" : accountNumber.toString(),
      "accountTitle": accountTitle.toString(),
      "bic" : bic.toString(),
      "isPrimary": isPrimary.toString(),
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
    print('updatedBody' + body.toString());
    print('updatedbankresponseStep1' + response.body);
    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final uniqueId = jsonResponse['data']['uniqueId'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uniqueId', uniqueId);
      uniqueIdFromStep1=uniqueId;
      otpErrorResponse=false;
      otpSuccessResponse=false;
      notifyListeners();
      print("Update bank successfully!");
      return AuthResult.success;
    } else {
      print("Bank is not updated yet: ${response.body}");
      otpErrorResponse=false;
      otpSuccessResponse=false;
      return AuthResult.failure;
    }
  }

  Future<AuthResult> updateBankAccountStep2({
    required String code,
    required String token,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/bank-account/update/step2');

    final body = {
      "code": code,
    };

    final response = await http.post(url, body: body,  headers: {

      "Accept": "application/json",
      'Authorization': 'Bearer $token',
      'X-Unique-Id': '$uniqueIdFromStep1',
    },);

    print('updateBankStep2 Response');
    print(response.body);
    print(uniqueIdFromStep1.toString());
    fToast = FToast();
    fToast.init(context);
    if (response.statusCode == 201) {
      otpErrorResponse=false;
      otpSuccessResponse=true;
      notifyListeners();
      return AuthResult.success;
    } else {
      otpErrorResponse=true;
      otpSuccessResponse=false;
      notifyListeners();
      return AuthResult.failure;
    }
  }


  Future<AuthResult> deleteBankAccount({
    required BuildContext context,
    required String token,
    required String accountNumber,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/bank-account/delete');
    final body = {
      "accountNumber" : accountNumber.toString(),
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
    print('delete bank api response' + response.body);
    fToast = FToast();
    fToast.init(context);
    print('Delete bank response'+response.body);
    if (response.statusCode == 201) {
      // Successful login, handle navigation or other actions
      final successResponse = json.decode(response.body);
      print("Bank Deleted successfully!");
      // Perform any additional actions upon successful bank addition
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      final errorResponse = json.decode(response.body);
      print("Bank is not Deleted yet: ${response.body}");
      return AuthResult.failure;
    }
  }
}

