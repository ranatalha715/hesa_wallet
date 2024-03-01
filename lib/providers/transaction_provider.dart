import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
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
      _showToast('OTP sent successfully!');
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("OTP not sent: ${response.body}");
      _showToast('OTP not sent');
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
      _showToast('Error');
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
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("Minting Error: ${response.body}");
        _showToast('Payable Transaction not sent');
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
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'Mint NFT not working',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation, context,);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> mintNFTWithEditions({
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
        _showToast('Payable Transaction Sent!');
        print("send response " + responseBody.toString());

        return AuthResult.success;
      } else {
        print("MintNFTWithEditions Error: ${response.body}");
        _showToast('Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'MintNFTWithEditions',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context, statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('MintNFTWithEditions Error: $e');
      _showToast('Error');
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
        testDialogToCheck(
            context: context,
            title: 'PurchaseNFT not working',
            description: response.body.toString());
        functionToNavigateAfterPayable(
            response.body.toString(), operation, context);
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'PurchaseNFT not working',
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
            title: 'ListNFT Fixed price not working',
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
      functionToNavigateAfterPayable(
          e.toString(), operation, context);
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
      functionToNavigateAfterPayable(
          e.toString(), operation, context);
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
      "orgCode": "Neonft",
      "channel": "nftchannel",
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
      functionToNavigateAfterPayable(
          e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> acceptCounterOffer({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
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
      functionToNavigateAfterPayable(
          e.toString(), operation, context);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> acceptCollectionCounterOffer({
    required String params,
    required String token,
    required String walletAddress,
    required String operation,
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
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'AcceptOfferNFT',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'AcceptOfferNFT',
          description: e.toString());
      functionToNavigateAfterNonPayable(
        e.toString(), operation,);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> acceptCollectionOffer({
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
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "AcceptCollectionOffer",
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
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation,
            statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'AcceptCollectionOffer',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation,
            statusCode: response.statusCode.toString());
            return AuthResult.failure;
            }
            } catch (e)
        {
          print('Error: $e');
          _showToast('Error');
          testDialogToCheck(
              context: context,
              title: 'AcceptCollectionOffer',
              description: e.toString());
          functionToNavigateAfterNonPayable(
            e.toString(), operation,);
          return AuthResult.failure;
        }
      }

  Future<AuthResult> rejectNFTOfferReceived({
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
      "orgCode": "Neonft",
      "channel": "nftchannel",
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
        testDialogToCheck(
            context: context,
            title: 'rejectNFTOfferReceived',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation,
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
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation,
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
        e.toString(), operation,);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> rejectCollectionOfferReceived({
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
      "orgCode": "Neonft",
      "channel": "nftchannel",
      "chaincode": "nft",
      "func": "RejectCollectionOffer",
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
      print('RejectCollectionOffer response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'RejectCollectionOffer',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation,
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
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation,
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
        e.toString(), operation,);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelNFTOfferMade({
    required String params,
    required String token,
    required String operation,
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
      print('CancelNFTOfferMade response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelNFTOfferMade',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation,
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
        functionToNavigateAfterNonPayable(response.body.toString(), operation,
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
      functionToNavigateAfterNonPayable(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelAuctionListing({
    required String params,
    required String token,
    required String operation,
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
      print('CancelAuctionListing response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelAuctionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(
          response.body.toString(), operation, statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelAuctionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelAuctionListing',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelCollectionAuctionListing({
    required String params,
    required String token,
    required String operation,
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
      print('CancelCollectionAuctionListing response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelCollectionAuctionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(
          response.body.toString(), operation, statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelCollectionAuctionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelCollectionAuctionListing',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelListing({
    required String params,
    required String token,
    required String operation,
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
      print('CancelListing response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation, statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelListing',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelCollectionListing({
    required String params,
    required String token,
    required String operation,
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
      print('CancelCollectionListing response' + response.body);

      if (response.statusCode == 201) {
        print(response.body);
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _showToast('Non Payable Transaction Sent!');
        testDialogToCheck(
            context: context,
            title: 'CancelCollectionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(
            response.body.toString(), operation, statusCode: response.statusCode.toString());
        print("send response " + responseBody.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Non Payable Transaction not sent');
        testDialogToCheck(
            context: context,
            title: 'CancelCollectionListing',
            description: response.body.toString());
        functionToNavigateAfterNonPayable(response.body.toString(), operation, statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelCollectionListing',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> cancelCollectionOfferMade({
    required String params,
    required String token,
    required String operation,
    required String walletAddress,
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
        functionToNavigateAfterNonPayable(response.body.toString(), operation,  statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'CancelCollectionOfferMade not working',
          description: e.toString());
      functionToNavigateAfterNonPayable(e.toString(), operation);
      return AuthResult.failure;
    }
  }

  functionToNavigateAfterNonPayable(String response,
      String operation,
      {String statusCode = ''}) {
    Future.delayed(Duration(seconds: 3), () {
      AppDeepLinking().openNftApp(
        {
          "operation": operation,
          "statusCode": statusCode.toString(),
          "data": response,
          "comments": "Non payable transactions response",
        },
      );
    });
  }

  functionToNavigateAfterPayable(String response, String operation,
      BuildContext context,
      {String statusCode = ''}) {
    Future.delayed(Duration(seconds: 3), () {
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
    });
  }

  functionToNavigateAfterCounterOffer(String response,
      String operation,
      {String statusCode = ''}) {
    Future.delayed(Duration(seconds: 3), () {
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
    required String walletAddress,
  }) async {
    final url = Uri.parse(BASE_URL + '/counter-offer');

    var requestBody = {

      "id": id,
      "offererId": offererId,
      // "offererId": offererId,
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
        // _showToast('Counter Offer Sent!');
        print("send response " + responseBody.toString());
        testDialogToCheck(
            context: context,
            title: 'MakeCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(
            response.body.toString(), operation,  statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        // _showToast('Counter Offer Not Sent');
        testDialogToCheck(
            context: context,
            title: 'MakeCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(
            response.body.toString(), operation,  statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      // _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'MakeCounterOffer',
          description: e.toString());
      functionToNavigateAfterCounterOffer(
          e.toString(), operation);
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
  }) async {
    final url = Uri.parse(BASE_URL + '/counter-offer/collection');

    var requestBody = {
      "id": id,
      "offererId": offererId,
      "offerAmount": int.parse(offerAmount),
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
        functionToNavigateAfterCounterOffer(
            response.body.toString(), operation,  statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        // _showToast('Counter Offer Not Sent');
        testDialogToCheck(
            context: context,
            title: 'MakeCollectionCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(
            response.body.toString(), operation,  statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      // _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'MakeCollectionCounterOffer',
          description: e.toString());
      functionToNavigateAfterCounterOffer(
          e.toString(), operation);
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
  }) async {
    final url = Uri.parse(BASE_URL + '/counter-offer/reject');

    var requestBody = {
      "id": id,
      "offererId": offererId,
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
        _showToast('Reject NFTCounter Offer Sent!');
        print("send response " + responseBody.toString());
        testDialogToCheck(
            context: context,
            title: 'RejectNFTCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(
            response.body.toString(), operation, statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Reject NFTCounter Offer Not Sent');
        testDialogToCheck(
            context: context,
            title: 'RejectNFTCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(
            response.body.toString(), operation, statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      // _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'RejectNFTCounterOffer',
          description: e.toString());
      functionToNavigateAfterCounterOffer(
          e.toString(), operation);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> rejectCollectionCounterOffer({
    // required String params,
    required String token,
    required String operation,
    required BuildContext context,
    required String id,
    required String offererId,
    required String offerAmount,
    required String walletAddress,
  }) async {
    final url = Uri.parse(BASE_URL + '/counter-offer/collection/reject');

    var requestBody = {
      "id": id,
      "offererId": offererId,
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
        functionToNavigateAfterCounterOffer(
            response.body.toString(), operation, statusCode: response.statusCode.toString());
        return AuthResult.success;
      } else {
        print("Error: ${response.body}");
        _showToast('Reject CollectionCounter Offer Not Sent');
        testDialogToCheck(
            context: context,
            title: 'RejectCollectionCounterOffer',
            description: response.body.toString());
        functionToNavigateAfterCounterOffer(
            response.body.toString(), operation, statusCode: response.statusCode.toString());
        return AuthResult.failure;
      }
    } catch (e) {
      print('Error: $e');
      // _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'RejectCollectionCounterOffer',
          description: e.toString());
      functionToNavigateAfterCounterOffer(
          e.toString(), operation);
      return AuthResult.failure;
    }
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

  Future<AuthResult> payableTransactionProcess({required String token,
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
      functionToNavigateAfterPayable(error.toString(), operation!, context,);

      return AuthResult.failure;
    } catch (e) {
      // Handle other exceptions here
      print('Process Api Error: $e');

      _showToast('Error');
      testDialogToCheck(
          context: context,
          title: 'Process Api Response On catch',
          description: e.toString());
      functionToNavigateAfterPayable(e.toString(), operation!, context,);
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
