import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../screens/user_transaction_summaries_with_payment/transaction_req_acceptreject.dart';
import '../screens/user_transaction_summaries_with_payment/transaction_request.dart';

class AppLinksService {
  late final AppLinks _appLinks;
  late final BuildContext context;
  String? _currentLink;

  AppLinksService({required this.context});

  Future<void> initializeAppLinks(var userWalletAddress) async {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('uri link');
        print(uri.toString());
        _handleLink(uri, userWalletAddress);
      }
    });
    // final Uri? initialUri = await _appLinks.getLatestLink();
    // if (initialUri != null) {
    //   _handleLink(initialUri, userWalletAddress);
    // }
  }

  void _handleLink(Uri uri, var userWalletAddress) {
    final String newLink = uri.toString();
    _currentLink = newLink;

    Provider.of<TransactionProvider>(context, listen: false).payloadTnxParam =
        newLink;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    final String? operation = uri.queryParameters['operation'];
    final String? params = uri.queryParameters['params'];
    Map<String, dynamic>? metadata;
    // if (params != null && params.isNotEmpty) {
    //   try {
    //     final Map<String, dynamic> paramsMap = jsonDecode(params);
    //     metadata = paramsMap['metadata'];
    //     if (metadata != null) {
    //       print('Metadata testing: $metadata');
    //     } else {
    //       print('Metadata not found');
    //     }
    //   } catch (e) {
    //     print('Error decoding JSON: $e');
    //   }
    // }
    // else {
    //   print('No params found');
    // }
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _navigateBasedOnOperation(uri, operation, userWalletAddress);
    // });
    if(uri !=null && operation!=null && userWalletAddress!=null){
      Future.delayed(Duration(milliseconds: 200), () {
        _navigateBasedOnOperation(uri, operation, userWalletAddress);
      });
    }
    // Future.delayed(Duration(milliseconds: 200), () {
    //   _navigateBasedOnOperation(uri, operation, userWalletAddress);
    // });
  }

  // Future<void> initializeAppLinks(var userWalletAddress) async {
  //   AppDeepLinking deepLinking = AppDeepLinking();
  //   deepLinking.initDeeplink();
  //   final Uri? initialUri = await deepLinking.getDeepLinkStream().first;
  //   if (initialUri != null) {
  //     print('this should run');
  //     print(initialUri.toString());
  //     _handleLink(initialUri, userWalletAddress);
  //   } else {
  //     print("No initial URI found");
  //   }
  // }
  //
  // void _handleLink(Uri uri, var userWalletAddress) {
  //   final String newLink = uri.toString();
  //   _currentLink = newLink;
  //
  //   Provider.of<TransactionProvider>(context, listen: false).payloadTnxParam = newLink;
  //
  //   if (Navigator.canPop(context)) {
  //     Navigator.pop(context);
  //   }
  //
  //   final String? operation = uri.queryParameters['operation'];
  //   final String? params = uri.queryParameters['params'];
  //   Map<String, dynamic>? metadata;
  //
  //   if (params != null && params.isNotEmpty) {
  //     try {
  //       final Map<String, dynamic> paramsMap = jsonDecode(params);
  //       metadata = paramsMap['metadata'];
  //       if (metadata != null) {
  //         print('Metadata testing: $metadata');
  //       } else {
  //         print('Metadata not found');
  //       }
  //     } catch (e) {
  //       print('Error decoding JSON: $e');
  //     }
  //   } else {
  //     print('No params found');
  //   }
  //
  //   print('Handling Deep Link Navigation...');
  //   _navigateBasedOnOperation(uri, operation, userWalletAddress);
  // }
  void _navigateBasedOnOperation(
      Uri uri, String? operation, String userWalletAddress) {
    if (operation == null) return;
    switch (operation) {
      case 'makeOfferNFT':
        navigateToTransactionRequestWithoutWalletAddress(
            uri.queryParameters, operation, context);
        break;
      case 'makeOfferCollection':
        navigateToTransactionRequestWithoutWalletAddress(
          uri.queryParameters,
          operation,
          context,
        );
        break;
      case 'AcceptNFTOfferReceived':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'AcceptCollectionOffer':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'rejectNFTOfferReceived':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'rejectCollectionOfferReceived':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'CancelNFTOfferMade':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'CancelAuctionListing':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'CancelCollectionAuctionListing':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'CancelListing':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'CancelCollectionListing':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'CancelCollectionOfferMade':
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'makeNFTCounterOffer':
        var data = json.decode(uri.queryParameters['params']!);
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'makeCollectionCounterOffer':
        var data = json.decode(uri.queryParameters['params']!);
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'rejectNFTCounterOffer':
        var data = json.decode(uri.queryParameters['params']!);
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      case 'rejectCollectionCounterOffer':
        var data = json.decode(uri.queryParameters['params']!);
        navigateToTransactionRequestWithNonPayable(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
      default:
        navigateToTransactionRequest(
            uri.queryParameters, operation, context, userWalletAddress);
        break;
    }
  }
}

Future<void> navigateToTransactionRequest(
  Map<String, dynamic> queryParams,
  String operation,
  BuildContext ctx,
  String userWalletAddress,
) async {
  String paramsString = queryParams['params'] ?? '';
  String feesString = queryParams['fees'] ?? '';
  await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
    "params": paramsString,
    "fees": feesString,
    "operation": operation,
    "walletAddress": userWalletAddress,
  });
}

Future<void> navigateToTransactionRequestWithoutWalletAddress(
  Map<String, dynamic> queryParams,
  String operation,
  BuildContext ctx,
) async {
  String paramsString = queryParams['params'] ?? '';
  String feesString = queryParams['fees'] ?? '';
  await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
    "params": paramsString,
    "fees": feesString,
    "operation": operation,
  });
}

Future<void> navigateToTransactionRequestWithNonPayable(
  Map<String, dynamic> queryParams,
  String operation,
  BuildContext ctx,
  String userWalletAddress,
) async {
  String paramsString = queryParams['params'] ?? '';
  String feesString = queryParams['fees'] ?? '';
  await Navigator.of(ctx)
      .pushNamed(TransactionRequestAcceptReject.routeName, arguments: {
    "params": paramsString,
    "fees": feesString,
    "operation": operation,
    "walletAddress": userWalletAddress
  });
}
