import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../screens/connection_requests_pages/connect_dapp.dart';
import '../screens/unlock/unlock.dart';
import '../screens/user_transaction_summaries_with_payment/transaction_req_acceptreject.dart';
import '../screens/user_transaction_summaries_with_payment/transaction_request.dart';

class AppLinksService {
  late final AppLinks _appLinks;
  late final BuildContext context;
  String? _currentLink;
  Timer? _timeoutTimer;
  Timer? _inactivityTimer;
  AppLinksService({required this.context});


  void dispose() {
    _timeoutTimer?.cancel();
    _inactivityTimer?.cancel();
    appLinksService.dispose();
  }
  Future<void> initializeAppLinks(var userWalletAddress) async {
    _appLinks = AppLinks();
    // _startTimeoutTimer();
    // _startInactivityTimer();
    _appLinks.uriLinkStream.listen((Uri? uri) {
      // _resetTimeoutTimer();
      // _resetInactivityTimer();
      // _updateLastActiveTime();
      final String? operation = uri?.queryParameters['operation'];
      if (uri != null && operation !=null) {
        print('uri link');
        print(uri.toString());
        _handleLink(uri, userWalletAddress);
      }
    });
    // final Uri? initialUri = await _appLinks.getLatestLink();
    // if (initialUri != null) {
    //   _handleLink(initialUri, userWalletAddress);
    // }
   // await _checkLastActiveTime();
  }

  Future<void> _updateLastActiveTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastActiveTime', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _checkLastActiveTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastActiveTime = prefs.getInt('lastActiveTime');

    if (lastActiveTime != null) {
      DateTime lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveTime);
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastActive);

      if (difference.inSeconds >= 30) {
        _navigateToLockScreen();
      } else {
        _startInactivityTimer(); // Restart inactivity timer when unlocking
      }
    } else {
      _startInactivityTimer(); // Start inactivity timer if not set
    }
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(Duration(seconds:30), () {
      // _navigateToLockScreen();
    });
  }

  void _resetTimeoutTimer() {
    _startTimeoutTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: 30), () {
      _navigateToLockScreen();
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _navigateToLockScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Unlock()),
          (Route<dynamic> route) => false,
    );
  }

  void _handleLink(Uri uri, var userWalletAddress) {
    final String newLink = uri.toString();
    // _resetInactivityTimer();
    // _updateLastActiveTime();
    _currentLink = newLink;
    Provider.of<TransactionProvider>(context, listen: false).payloadTnxParam = newLink;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    final String? operation = uri.queryParameters['operation'];
    final String? logoFromNeo = uri.queryParameters['logo'];
    final String? siteUrl = uri.queryParameters['siteUrl'];
    if (operation == 'connectWallet') {
      Provider.of<UserProvider>(context, listen: false).navigateToNeoForConnectWallet = true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ConnectDapp()),
            (Route<dynamic> route) => false,
      );
      Provider.of<TransactionProvider>(context, listen: false).logoFromNeo = logoFromNeo;
      Provider.of<TransactionProvider>(context, listen: false).siteUrl = siteUrl;
    } else if (operation == 'disconnectWallet') {
      // handleDisconnection1();
    } else {
      Provider.of<UserProvider>(context, listen: false).navigateToNeoForConnectWallet = false;

      if (operation != null && userWalletAddress != null) {
        Future.delayed(Duration(milliseconds: 200), () {
          _navigateBasedOnOperation(uri, operation, userWalletAddress);
        });
      }
    }
  }
  void _navigateBasedOnOperation(
      Uri uri, String? operation, String userWalletAddress) {
    if (operation == null) return;
    // _resetInactivityTimer();
    // _updateLastActiveTime();
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