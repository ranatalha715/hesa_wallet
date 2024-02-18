import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:sizer/sizer.dart';
import '../constants/app_deep_linking.dart';
import '../constants/colors.dart';
import '../constants/configs.dart';

class TransactionProvider with ChangeNotifier {
  late FToast fToast;
  var checkoutURL;
  var checkoutId;
  var tokenizedCheckoutId;
  var selectedCardTokenId;
  var selectedCardNum;

  // var decodedMetaData;

  Future<String> decodeMetaData({required String url}) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Successfully fetched data
      final Map<String, dynamic> jsonData = json.decode(response.body);

      // Now jsonData contains the parsed JSON data
      // decodedMetaData = jsonData;
      print('json data testing');
      // print(jsonEncode(jsonData.toString()));
      // print(jsonData.toString());
      // return jsonEncode(jsonData.toString());
      return jsonData.toString();
    } else {
      // Handle error
      print('Failed to fetch data. Status code: ${response.statusCode}');
      return "";
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
      // Successful login, handle navigation or other actions
      print("OTP sent successfully!");
      _showToast('OTP sent successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("OTP not sent: ${response.body}");
      _showToast('OTP not sent');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> nonPayableTransactionSend({
    required String token,
    required String code,
    required String walletAddress,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/non-payable-transactions/send');
    final Map<String, dynamic> requestBody = {
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "MintCollection",
      "walletAddress": walletAddress,
      "country": "PK",
      "signature": ",",
      "publicKey": ",",
      "code": code,
      "params": [
        "2",
        "My First Collection",
        "0x17e6d6e903c1fd7eabe86bc50ff95a2c3301a09a8741947d82db755f",
        [
          "e304107f-59d3-45c1-862b-3ab03cd9eb5a",
          "45b92d9a-2fa2-423b-bed7-511ae7f5c28c"
        ]
      ],
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
        print(response.body);
        _showToast('Transaction Send!');
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Transaction not send');
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> MintCollectionpayableTransactionSend({
    required String params,
    required String token,
    required String walletAddress,
    required BuildContext context,
    required String mintCollectionId,
    required String ownerId,
    required String operation,
    required String tokenId,
    required String country,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    paramsMap['creatorWalletAddress'] = yourWalletAddress;
    // Convert the paramsMap to a string
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "MintCollection",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": 'tokenization',
      "country": "PK",
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
        _showToast('Payable Transaction Sent!');
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> mintNftpayableTransactionSend({
    required String params,
    required String token,
    required String walletAddress,
    required String country,
    required String operation,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    paramsMap['creatorWalletAddress'] = yourWalletAddress;
    // Convert the paramsMap to a string
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "MintNFT",
      "walletAddress": walletAddress,
      // "tokenId": '8ac7a4a08d117072018d12975ec70f2f',
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> purchaseNft({
    required String params,
    required String token,
    required String walletAddress,
    required String country,
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
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "PurchaseNFT",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      "params": paramsMap,
      // "params": {
      //   "id": "45318c0b-2430-4f66-8925-8254e627dff2",
      //   "price": 300
      // }
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> listNftFixedPrice({
    required String params,
    required String token,
    required String walletAddress,
    // required String country,
    required BuildContext context,
    required String tokenId,
    required String operation,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;

    paramsMap['listedBy'] = yourWalletAddress;
    // paramsMap['price'] = 500;
    // Convert the paramsMap to a string
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "ListNFT",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> listCollectionFixedPrice({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;

    paramsMap['listedBy'] = yourWalletAddress;
    // paramsMap['price'] = 500;
    // Convert the paramsMap to a string
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "ListCollection",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> listNftForAuction({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;

    paramsMap['listedBy'] = yourWalletAddress;
    // paramsMap['price'] = 500;
    // Convert the paramsMap to a string
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "ListNFTForAuction",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> listCollectionForAuction({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;

    paramsMap['listedBy'] = yourWalletAddress;
    // paramsMap['price'] = 500;
    // Convert the paramsMap to a string
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "ListCollectionForAuction",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> burnNFT({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;

    paramsMap['owner'] = yourWalletAddress;
    // paramsMap['price'] = 500;
    // Convert the paramsMap to a string
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "BurnNFT",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> burnCollection({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
    required BuildContext context,
    required String tokenId,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/send');
    Map<String, dynamic> paramsMap = jsonDecode(params);
    String yourWalletAddress = walletAddress;
    // String collectionId = '8c9b250f-2038-4162-9c9a-6015dc2f16a5';

    paramsMap['owner'] = yourWalletAddress;
    // paramsMap['id'] = collectionId;
    // paramsMap['price'] = 500;
    // Convert the paramsMap to a string
    String updatedParams = jsonEncode(paramsMap);
    print('params to send bilal' + updatedParams);
    final Map<String, dynamic> requestBody = {
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "BurnCollection",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      // "params": updatedParams,
      "params": paramsMap,
      // "params": {
      //   "id": "1cb68dbc-c782-4342-8e02-6eb0bfc385ef",
      //   "owner":"0x65BC9C8608688E1FA95247C570F5B72DB945468A"
      // }
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> makeOffer({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
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
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "MakeOffer",
      "walletAddress": walletAddress,
      "tokenId": tokenId,
      "type": "tokenized",
      "country": "PK",
      "billing": {
        "country": "PK",
        "city": "Karachi",
        "state": "Sindh",
        "postcode": "75400",
        "street1": "39 E"
      },
      // "params": updatedParams,
      "params": paramsMap,
      // "params": {
      //   "id": "1cb68dbc-c782-4342-8e02-6eb0bfc385ef",
      //   "owner":"0x65BC9C8608688E1FA95247C570F5B72DB945468A"
      // }
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  //non payable
  Future<AuthResult> acceptOffer({
    required String params,
    required String token,
    required String operation,
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
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "AcceptOffer",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": "0001",
      "params": paramsMap,
      // "params": {
      //   "id": " 839c5f8d-sb09-4f91-bf82-2f35b3d87659",
      //   "offererId": "0x4925D03C16A4CC04CA665A34EC3BC43CD9D8B705"
      // }
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> rejectOffer({
    required String params,
    required String token,
    required String walletAddress,
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
      "orgCode": "{{organization}}",
      "channel": "{{channel}}",
      "chaincode": "nft",
      "func": "RejectOffer",
      "walletAddress": walletAddress,
      "country": "PK",
      "code": "0001",
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
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        functionToNavigateAfterNonPayable(response.body.toString(),operation);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      functionToNavigateAfterNonPayable(e.toString(),operation);
      return AuthResult.failure;
    }
  }

  functionToNavigateAfterNonPayable(
      String response, String operation,) {
    AppDeepLinking().openNftApp(
      {
        "data": response,
        "operation" : operation,
        "comments": "response coming from api /non-payable-transactions/send",
      },
    );
  }

  Future<AuthResult> calculateTransactionSummary({
    required String token,
    required String assetPrice,
    required String func,
    required String entries,
    required String creatorRoyaltyPercent,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL +
        '/payment-fees/calculate-transaction-summary?assetPrice=$assetPrice&func=$func&entries=$entries&creatorRoyaltyPercent=$creatorRoyaltyPercent');
    final Map<String, dynamic> requestBody = {};

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        // body: json.encode(requestBody),
      );

      fToast = FToast();
      fToast.init(context);
      print('transaction summary response' + response.body);

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);

        print("transaction summary response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> tokenizeCardRequest({
    required String token,
    // required String bin,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/user/tokenize-card-request');
    final Map<String, dynamic> requestBody = {
      // "bin": bin,
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

  Future<AuthResult> payableTransactionProcess({
    required String token,
    required String paymentId,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/v2/payable-transactions/process');
    final Map<String, dynamic> requestBody = {
      "paymentId": paymentId,
    };
    print('paymentId for process' + paymentId);
    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-type": "application/json",
              "Accept": "application/json",
              'Authorization': 'Bearer $token',
            },
            body: json.encode(requestBody),
          )
          .timeout(Duration(seconds: 10)); // Set timeout duration as needed

      fToast = FToast();
      fToast.init(context);
      print('process api request body');
      print(requestBody);
      print('process api response');
      print(response.body);
      if (response.statusCode == 201) {
        _showToast('Payment Processed Successfully');
        AppDeepLinking().openNftApp(
          {
            "data": response.body.toString(),
            "comments":
                "response coming from api /v2/payable-transactions/process",
          },
        );
        return AuthResult.success;
      } else {
        // Handle the error response here if needed
        print("Process Api Error: ${response.body}");
        _showToast('Payment Processing Failed');
        AppDeepLinking().openNftApp(
          {
            "data": response.body.toString(),
            "comments":
                "response coming from api /v2/payable-transactions/process",
          },
        );
        return AuthResult.failure;
      }
    } on TimeoutException catch (_) {
      // Handle timeout error
      print('Process Api Timeout');
      _showToast('Request Timeout');
      AppDeepLinking().openNftApp(
        {
          "data": "Request Timeout",
          "comments":
              "response coming from api /v2/payable-transactions/process",
        },
      );
      return AuthResult.failure;
    } catch (e) {
      // Handle other exceptions here
      print('Process Api Error: $e');
      _showToast('Error');
      AppDeepLinking().openNftApp(
        {
          "data": e.toString(),
          "comments":
              "response coming from api /v2/payable-transactions/process",
        },
      );
      return AuthResult.failure;
    }
  }

  // Future<AuthResult> payableTransactionProcess({
  //   required String token,
  //   required String paymentId,
  //   required BuildContext context,
  // }) async {
  //   final url = Uri.parse(BASE_URL + '/v2/payable-transactions/process');
  //   final Map<String, dynamic> requestBody = {
  //     "paymentId": paymentId,
  //   };
  //   print('paymentId for process' + paymentId);
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-type": "application/json",
  //         "Accept": "application/json",
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode(requestBody),
  //     );
  //     fToast = FToast();
  //     fToast.init(context);
  //     print('process api request body');
  //     print(requestBody);
  //     print('process api response');
  //     print(response.body);
  //     if (response.statusCode == 201) {
  //       _showToast('Payment Processed Successfully');
  //       // Navigator.push(
  //       //   context,
  //       //   MaterialPageRoute(builder: (context) => WalletTokensNfts()),
  //       // ).then((value) {
  //       // _showToast('opening NEO App');
  //
  //       AppDeepLinking().openNftApp(
  //         {
  //           "data": response.body.toString(),
  //           "comments":
  //               "response coming from api /v2/payable-transactions/process",
  //         },
  //       );
  //
  //       // }); //response.body
  //       // print(response.body);
  //
  //       return AuthResult.success;
  //     } else {
  //       // Handle the error response here if needed
  //       print("Process Api Error: ${response.body}");
  //       _showToast('Payment Processing Failed');
  //       return AuthResult.failure;
  //     }
  //   } catch (e) {
  //     // Handle exceptions here
  //     print('Process Api Error: $e');
  //     _showToast('Error');
  //     return AuthResult.failure;
  //   }
  // }

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

  // Future<String> tokenizeCardRequest({required String bin, required String token}) async {
  //   final url = Uri.parse(BASE_URL +"/user/tokenize-card-request");
  //   final binSubstring = bin.substring(0, 6);
  //
  //   Map<String, dynamic> requestBody = {
  //     "bin": binSubstring,
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-type": "application/json",
  //         "Accept": "application/json",
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode(requestBody),
  //     );
  //
  //     if (response.statusCode == 201) {
  //       final Map<String, dynamic> responseBody = json.decode(response.body);
  //       if (responseBody['success'] == true) {
  //         final String checkoutId = responseBody['data']['checkoutId'];
  //         print(responseBody);
  //         return checkoutId;
  //       } else {
  //         // Handle error here if needed
  //         throw Exception('Tokenization request failed: ${responseBody['message']}');
  //       }
  //     } else {
  //       // Handle error here if needed
  //       throw Exception('HTTP request failed with status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle exception here if needed
  //     throw Exception('Error: $e');
  //   }
  // }

// Example usage:
// String bin = "411111";
// Future<String> checkoutId = tokenizeCardRequest(bin);

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
}
