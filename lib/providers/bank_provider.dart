import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
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
  final Map<String, String> body = {
  // "beneficiaryBank": bankName,
  // "beneficiaryBankAddress": "CBC",
  // "beneficiaryBankClearingCode": "02",
  // "beneficiaryBankCode": "CBC",
  // "beneficiaryAccountNo": "858888888",
  // "beneficiaryName": beneficiaryName,
  // "beneficiaryAddress": "Karachi",
  "isPrimary": "true",
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
  _showToast('Bank Added successfully!');
  // Perform any additional actions upon successful bank addition
  return AuthResult.success;
  } else {
  print("Failed to add bank account: ${responseData['message']}");
  _showToast('Failed to add bank account');
  // Show an error message or handle the failure as needed
  return AuthResult.failure;
  }
  } else {
  print("Failed to add bank account. Status code: ${response.body}");
  // Show an error message or handle the failure as needed
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
      // _showToast('Update bank successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Bank is not updated yet: ${response.body}");
      // _showToast('Bank is not updated yet');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> deleteBankAccount({
    required BuildContext context,
    required String token,
    required String accountNumber,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/delete-bank-account');
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
      _showToast(successResponse['message']);
      // Perform any additional actions upon successful bank addition
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      final errorResponse = json.decode(response.body);
      print("Bank is not Deleted yet: ${response.body}");
      _showToast(errorResponse['message']);
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

