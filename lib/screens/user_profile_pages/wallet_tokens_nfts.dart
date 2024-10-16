import 'dart:convert';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/screens/settings/security_and_privacy.dart';
import 'package:uni_links/uni_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/providers/nfts_provider.dart';
import 'package:hesa_wallet/widgets/nfts_collection_divisions/nfts_collections_division.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import '../../constants/app_deep_linking.dart';
import '../../providers/assets_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/local_toast.dart';
import '../connection_requests_pages/connect_dapp.dart';
import '../signup_signin/welcome_screen.dart';
import '../unlock/unlock.dart';
import '../user_transaction_summaries_with_payment/transaction_req_acceptreject.dart';
import '../user_transaction_summaries_with_payment/transaction_request.dart';

class WalletTokensNfts extends StatefulWidget {
  static const routeName = 'nfts-page';

  const WalletTokensNfts({Key? key}) : super(key: key);

  @override
  State<WalletTokensNfts> createState() => _WalletTokensNftsState();
}

class _WalletTokensNftsState extends State<WalletTokensNfts>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late TabController _tabController;
  final scrollcontroller = ScrollController();
  late FToast fToast;
  var _isSelected = 0;
  var accessToken;
  var _isinit = true;
  int selectedCategoryIndex = 0;
  bool _isloading = false;
  bool showCopiedMsg = false;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  String replaceMiddleWithDots(String input) {
    if (input.length <= 30) {
      // If the input string is 30 characters or less, return it as is.
      return input;
    }

    final int middleIndex = input.length ~/ 2; // Find the middle index
    final int startIndex = middleIndex - 16; // Calculate the start index
    final int endIndex = middleIndex + 16; // Calculate the end index

    // Split the input string into three parts and join them with '...'
    final String result =
        input.substring(0, startIndex) + '...' + input.substring(endIndex);

    return result;
  }

  var userWalletAddress;

  Future<void> init() async {
    setState(() {
      _isloading = true;
    });

    await getAccessToken();

    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    var user = await Provider.of<UserProvider>(context, listen: false);
    userWalletAddress = user.walletAddress;
    await Provider.of<AssetsProvider>(context, listen: false).getListedAssets(
      token: accessToken,
      context: context,
      walletAddress: user.walletAddress!,
      ownerType: 'owner',
      type: 'all',
    );
    await Provider.of<AssetsProvider>(context, listen: false).getCreatedAssets(
      token: accessToken,
      context: context,
      walletAddress: user.walletAddress!,
      ownerType: 'creator',
      type: 'all',
    );
    await Provider.of<AssetsProvider>(context, listen: false).getOwnedAssets(
      token: accessToken,
      context: context,
      walletAddress: user.walletAddress!,
      ownerType: 'owner',
      type: 'all',
    );
    await Provider.of<AssetsProvider>(context, listen: false).getAllAssets(
      token: accessToken,
      context: context,
      walletAddress: user.walletAddress!,
      ownerType: 'both',
      type: 'all',
    );
    setState(() {
      _isloading = false;
    });
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final passcode = prefs.getString('passcode');
    final setLockScreen = prefs.getBool('setLockScreen') ?? false;
    return {
      'passcode': passcode,
      'setLockScreen': setLockScreen,
    };
  }

  setLockScreenStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('setLockScreen', value);
  }
  bool _isPasscodeSet =false;
  getPasscode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final passcode = prefs.getString('passcode')!;
    if(passcode!=""){
      _isPasscodeSet = true;
    }
    else{
      _isPasscodeSet = false;
    }
    print("ispasscodeset" + _isPasscodeSet.toString());
  }

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 1), () {
    //   localToast(context, "This is a toast message!",
    //       duration: 3000,
    //
    //   );
    // }
    // );
    getPasscode();
    initUniLinks();
    initUniLinks1();
    print('recieved data' + _receivedData);

    _tabController = TabController(length: 2, vsync: this);

    // Call init asynchronously to avoid blocking the UI thread
    init();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          AppColors.profileHeaderDark, // Change to your desired color
    ));
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.profileHeaderDark, // Reset to default color
    ));
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isinit) {
      // No need to setState here, as it's already done in the init() method
      init();
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  // Initially, set to All

// Inside the onChanged or onPressed of each NFTCategoryWidget, update the selected index
  void onCategorySelected(int index) {
    setState(() {
      selectedCategoryIndex = index;
    });
  }
  void handleDisconnection() async {
    final prefs =
    await SharedPreferences.getInstance();
    await prefs.setString('disconnectionTime', DateTime.now().toString());
    await  prefs.setBool('isConnected', false);
    setState(() {

    });
    await Future.delayed(Duration(seconds: 2), () {});
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert!'),
          content: Text('Disconnected Successfully'),
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
  Future<void> initUniLinks1() async {
    try {
      print('trying');
      await getLinksStream().firstWhere((String? link) {
        if (link != null) {
          Uri uri = Uri.parse(link);
          String? operation = uri.queryParameters['operation'];
          String? logoFromNeo = uri.queryParameters['logo'];
          String? siteUrl = uri.queryParameters['siteUrl'];
          print("print operation");
          print(operation);

          if (operation != null && operation == 'connectWallet') {
            Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet = true;

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ConnectDapp()),
                  (Route<dynamic> route) => false,
            );
            Provider.of<TransactionProvider>(context,listen: false).logoFromNeo=logoFromNeo;
            Provider.of<TransactionProvider>(context,listen: false).siteUrl=siteUrl;
            // setState(() {
            //   isOverlayVisible = Provider.of<UserProvider>(context, listen: false)
            //       .navigateToNeoForConnectWallet;  // Set overlay visibility to true
            // });

            print("check kro" +
                Provider.of<UserProvider>(context, listen: false)
                    .navigateToNeoForConnectWallet
                    .toString());
          }
          else if(operation != null && operation == 'DisconnectWallet') {
            handleDisconnection();
          }
          else {
            Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet = false;

            // setState(() {
            //   isOverlayVisible = Provider.of<UserProvider>(context, listen: false)
            //       .navigateToNeoForConnectWallet;  // Set overlay visibility to false
            // });
          }
          return true; // Exit the loop after processing
        } else{
          Provider.of<UserProvider>(context, listen: false)
              .navigateToNeoForConnectWallet = false;

          // setState(() {
          //   isOverlayVisible = Provider.of<UserProvider>(context, listen: false)
          //       .navigateToNeoForConnectWallet;  // Set overlay visibility to false
          // });

        }

        return false;
      });

      print('trying end');
      // clearLinkStream();
    } catch (e) {
      print('Error initializing UniLinks: $e');
      print('trying error');
    }
  }

  // uniilink

  String _receivedData = 'No UniLink data received';

  Future<void> initUniLinks() async {
    // Initialize UniLinks
    // await initPlatformState();
    // Listen for incoming links
    // AppDeepLinking().initDeeplink();
    getLinksStream().listen((String? link) {
      print(link.toString() + " before");
      if (link != null) {
        setState(() {
          _receivedData = link;
        });

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        Uri uri = Uri.parse(link);
        String? operation = uri.queryParameters['operation'];
        if (operation != null && operation == 'MintNFT') {
          navigateToTransactionRequestWithMint(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'MintCollection') {
          navigateToTransactionRequestWithMintCollection(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'MintNFTWithEditions') {
          navigateToTransactionRequestWithMintNFTWithEditions(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'purchaseNFT') {
          //purchaseNFT
          navigateToTransactionRequestWithPurchaseNft(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'purchaseCollection') {
          //purchaseNFT
          navigateToTransactionRequestWithPurchaseCollection(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'listNFT') {
          //listNFT
          navigateToTransactionRequestWithListNftFixedPrice(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'listCollection') {
          //listCollection
          navigateToTransactionRequestWithListCollectionFixedPrice(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'listAuctionNFT') {
          navigateToTransactionRequestWithListNftForAuction(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'listAuctionCollection') {
          //listAuctionCollection
          navigateToTransactionRequestWithListCollectionForAuction(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'burnNFT') {
          //burnNFT
          navigateToTransactionRequestWithBurnNFT(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'burnCollection') {
          //burnCollection
          navigateToTransactionRequestWithBurnCollection(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'makeOfferNFT') {
          //makeOfferNFT
          navigateToTransactionRequestWithMakeOfferNFT(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'makeOfferCollection') {
          //makeOfferCollection
          navigateToTransactionRequestWithMakeOfferCollection(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'AcceptNFTOfferReceived') {
          //AcceptNFTOfferReceived
          navigateToTransactionRequestAcceptRejectWithAcceptOffer(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'AcceptCollectionOffer') {
          //AcceptCollectionOffer
          navigateToTransactionRequestAcceptRejectWithAcceptCollectionOffer(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'rejectNFTOfferReceived') {
          //rejectNFTOfferReceived
          navigateToTransactionRequestAcceptRejectWithrejectNFTOfferReceived(
              uri.queryParameters, operation, context);
        } else if (operation != null &&
            operation == 'rejectCollectionOfferReceived') {
          //rejectCollectionOfferReceived
          navigateToTransactionRequestAcceptRejectWithrejectCollectionOfferReceived(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'CancelNFTOfferMade') {
          //CancelNFTOfferMade
          navigateToTransactionRequestAcceptRejectWithCancelNFTOfferMade(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'CancelAuctionListing') {
          //CancelAuctionListing
          navigateToTransactionRequestAcceptRejectWithCancelAuctionListing(
              uri.queryParameters, operation, context);
        } else if (operation != null &&
            operation == 'CancelCollectionAuctionListing') {
          //CancelCollectionAuctionListing
          navigateToTransactionRequestAcceptRejectWithCancelCollectionAuctionListing(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'CancelListing') {
          //CancelListing
          navigateToTransactionRequestAcceptRejectWithCancelListing(
              uri.queryParameters, operation, context);
        } else if (operation != null &&
            operation == 'CancelCollectionListing') {
          //CancelCollectionListing
          navigateToTransactionRequestAcceptRejectWithCancelCollectionListing(
              uri.queryParameters, operation, context);
        } else if (operation != null &&
            operation == 'CancelCollectionOfferMade') {
          //CancelCollectionOfferMade
          navigateToTransactionRequestAcceptRejectWithCancelCollectionOfferMade(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'makeNFTCounterOffer') {
          //makeNFTCounterOffer
          var data = json.decode(uri.queryParameters["params"]!);
          String? id = data['id'];
          String? offererId = data['offererId'];
          int? offerAmount = int.tryParse(data['offerAmount'].toString() ?? '');
          print(id.toString() +
              "  " +
              offererId.toString() +
              "  " +
              offerAmount.toString());
          navigateToTransactionRequestAcceptRejectWithMakeCounterOffer(
              uri.queryParameters,
              operation,
              context,
              id.toString(),
              offererId.toString(),
              offerAmount.toString());
        } else if (operation != null &&
            operation == 'makeCollectionCounterOffer') {
          //makeNFTCounterOffer
          var data = json.decode(uri.queryParameters["params"]!);
          String? id = data['id'];
          String? offererId = data['offererId'];
          int? offerAmount = int.tryParse(data['offerAmount'].toString() ?? '');
          print(id.toString() +
              "  " +
              offererId.toString() +
              "  " +
              offerAmount.toString());
          navigateToTransactionRequestAcceptRejectWithmakeCollectionCounterOffer(
              uri.queryParameters,
              operation,
              context,
              id.toString(),
              offererId.toString(),
              offerAmount.toString());
        } else if (operation != null && operation == 'acceptNFTCounterOffer') {
          //acceptNFTCounterOffer
          navigateToTransactionRequestWithacceptNFTCounterOffer(
              uri.queryParameters, operation, context);
        } else if (operation != null && operation == 'rejectNFTCounterOffer') {
          //makeNFTCounterOffer
          var data = json.decode(uri.queryParameters["params"]!);
          String? id = data['id'];
          String? offererId = data['offererId'];
          int? offerAmount = int.tryParse(data['offerAmount'].toString() ?? '');
          print(id.toString() +
              "  " +
              offererId.toString() +
              "  " +
              offerAmount.toString());
          navigateToTransactionRequestAcceptRejectWithrejectNFTCounterOffer(
              uri.queryParameters,
              operation,
              context,
              id.toString(),
              offererId.toString(),
              offerAmount.toString());
        } else if (operation != null &&
            operation == 'rejectCollectionCounterOffer') {
          //makeNFTCounterOffer
          var data = json.decode(uri.queryParameters["params"]!);
          String? id = data['id'];
          String? offererId = data['offererId'];
          int? offerAmount = int.tryParse(data['offerAmount'].toString() ?? '');
          print(id.toString() +
              "  " +
              offererId.toString() +
              "  " +
              offerAmount.toString());
          navigateToTransactionRequestAcceptRejectWithrejectCollectionCounterOffer(
              uri.queryParameters,
              operation,
              context,
              id.toString(),
              offererId.toString(),
              offerAmount.toString());
        } else if (operation != null &&
            operation == 'acceptCollectionCounterOffer') {
          //acceptCollectionCounterOffer
          navigateToTransactionRequestWithacceptCollectionCounterOffer(
              uri.queryParameters, operation, context);
        } else {}
      }
    });
  }

  Future<void> navigateToTransactionRequestWithMintCollection(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithMintNFTWithEditions(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithMint(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    // await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
    //   "params": paramsString,
    //   "fees": feesString,
    //   "operation": operation,
    //   "walletAddress": userWalletAddress
    // });
    await Navigator.of(ctx).popAndPushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithPurchaseNft(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress,
    });
  }

  Future<void> navigateToTransactionRequestWithPurchaseCollection(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress,
    });
  }

  Future<void> navigateToTransactionRequestWithListNftFixedPrice(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithListCollectionFixedPrice(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithListNftForAuction(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithListCollectionForAuction(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithBurnNFT(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithBurnCollection(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithMakeOfferNFT(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
    });
  }

  Future<void> navigateToTransactionRequestWithMakeOfferCollection(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
    });
  }

  Future<void> navigateToTransactionRequestWithacceptNFTCounterOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithacceptCollectionCounterOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "walletAddress": userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestAcceptRejectWithAcceptOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
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

  Future<void>
      navigateToTransactionRequestAcceptRejectWithAcceptCollectionOffer(
          Map<String, dynamic> queryParams,
          String operation,
          BuildContext ctx) async {
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

  Future<void>
      navigateToTransactionRequestAcceptRejectWithrejectNFTOfferReceived(
          Map<String, dynamic> queryParams,
          String operation,
          BuildContext ctx) async {
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

  Future<void>
      navigateToTransactionRequestAcceptRejectWithrejectCollectionOfferReceived(
          Map<String, dynamic> queryParams,
          String operation,
          BuildContext ctx) async {
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

  Future<void> navigateToTransactionRequestAcceptRejectWithCancelNFTOfferMade(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
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

  Future<void>
      navigateToTransactionRequestAcceptRejectWithCancelCollectionOfferMade(
          Map<String, dynamic> queryParams,
          String operation,
          BuildContext ctx) async {
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

  Future<void> navigateToTransactionRequestAcceptRejectWithCancelAuctionListing(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
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

  Future<void>
      navigateToTransactionRequestAcceptRejectWithCancelCollectionAuctionListing(
          Map<String, dynamic> queryParams,
          String operation,
          BuildContext ctx) async {
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

  Future<void> navigateToTransactionRequestAcceptRejectWithCancelListing(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
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

  Future<void>
      navigateToTransactionRequestAcceptRejectWithCancelCollectionListing(
          Map<String, dynamic> queryParams,
          String operation,
          BuildContext ctx) async {
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

  Future<void> navigateToTransactionRequestAcceptRejectWithMakeCounterOffer(
    Map<String, dynamic> queryParams,
    String operation,
    BuildContext ctx,
    String id,
    String offererId,
    String offerAmount,
  ) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx)
        .pushNamed(TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "id": id,
      "offererId": offererId,
      "offerAmount": offerAmount,
      "walletAddress": userWalletAddress
    });
  }

  Future<void>
      navigateToTransactionRequestAcceptRejectWithrejectNFTCounterOffer(
    Map<String, dynamic> queryParams,
    String operation,
    BuildContext ctx,
    String id,
    String offererId,
    String offerAmount,
  ) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx)
        .pushNamed(TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "id": id,
      "offererId": offererId,
      "offerAmount": offerAmount,
      "walletAddress": userWalletAddress
    });
    print('chal gia');
  }

  Future<void>
      navigateToTransactionRequestAcceptRejectWithrejectCollectionCounterOffer(
    Map<String, dynamic> queryParams,
    String operation,
    BuildContext ctx,
    String id,
    String offererId,
    String offerAmount,
  ) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx)
        .pushNamed(TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "fees": feesString,
      "id": id,
      "offererId": offererId,
      "offerAmount": offerAmount,
      "walletAddress": userWalletAddress
    });
    print('chal gia');
  }

  Future<void>
      navigateToTransactionRequestAcceptRejectWithmakeCollectionCounterOffer(
    Map<String, dynamic> queryParams,
    String operation,
    BuildContext ctx,
    String id,
    String offererId,
    String offerAmount,
  ) async {
    String paramsString = queryParams['params'] ?? '';
    String feesString = queryParams['fees'] ?? '';
    await Navigator.of(ctx)
        .pushNamed(TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "fees": feesString,
      "operation": operation,
      "id": id,
      "offererId": offererId,
      "offerAmount": offerAmount,
      "walletAddress": userWalletAddress
    });
  }

  bool showLockedScreen = false;

  @override
  Widget build(BuildContext context) {
    final nftsAll =
        Provider.of<AssetsProvider>(context, listen: false).assetsAll;
    final nftsCollectionAll =
        Provider.of<AssetsProvider>(context, listen: false).assetsCollectionAll;
    final nftsListed =
        Provider.of<AssetsProvider>(context, listen: false).assetsListed;
    final collectionListed = Provider.of<AssetsProvider>(context, listen: false)
        .assetsCollectionListed;

    final nftsCreated =
        Provider.of<AssetsProvider>(context, listen: false).assetsCreated;
    final nftsCollectionCreated =
        Provider.of<AssetsProvider>(context, listen: false)
            .assetsCollectionCreated;

    final nftsOwned =
        Provider.of<AssetsProvider>(context, listen: false).assetsOwned;
    final nftsCollectionOwnedByUser =
        Provider.of<AssetsProvider>(context, listen: false)
            .assetsCollectionOwned;
    print('red dot logic');
    print(Provider.of<TransactionProvider>(context, listen: false).confirmedRedDot);
    print(Provider.of<TransactionProvider>(context, listen: false).showRedDot);
    return Consumer<UserProvider>(builder: (context, user, child) {
      return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
        return Stack(
          children: [
            FutureBuilder<Map<String, dynamic>>(
                future: getSettings(),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    if (snapshot.hasData) {
                      final passcode = snapshot.data!['passcode'] as String?;
                      final setLockScreen =
                          snapshot.data!['setLockScreen'] as bool;
                      print("setLockScreen && passcode");
                      print(setLockScreen.toString() + passcode.toString());
                      if (setLockScreen
                          // &&
                          // passcode != null &&
                          // passcode.isNotEmpty
                      ) {
                        return Unlock();
                          // return WelcomeScreen(handler: (){});
                        // Navigate to the pin screen
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => WelcomeScreen(
                          //             handler: () {},
                          //           )),
                          // );

                        });
                      }
                    }
                  }
                  return Scaffold(
                    key: _key,
                    drawer: AppDrawer(),
                    backgroundColor: themeNotifier.isDark
                        ? AppColors.backgroundColor
                        : AppColors.textColorWhite,
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 35.h,
                            width: double.infinity,
                            color: themeNotifier.isDark
                                ? AppColors.backgroundColor
                                : AppColors.textColorWhite,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 12.h,
                                  color: themeNotifier.isDark
                                      ? AppColors.profileHeaderDark
                                      : AppColors.whiteShade,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 14.sp,
                                        right: 20.sp,
                                        bottom: 8.sp),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _key.currentState!.openDrawer(),
                                          child: Stack(
                                            children: [
                                              Icon(
                                                Icons.menu_rounded,
                                                color: themeNotifier.isDark
                                                    ? AppColors.textColorWhite
                                                    : AppColors.textColorBlack,
                                                size: 25.sp,
                                              ),
                                              Consumer<TransactionProvider>(
                                                  builder: (context,
                                                      TransactionProvider trP,
                                                      _) {
                                                return Positioned(
                                                  right: 1,
                                                  // bottom: 2.sp,
                                                  child: Container(
                                                    height: 4.3.sp,
                                                    width: 4.3.sp,
                                                    decoration: BoxDecoration(
                                                      color: trP.showRedDot && trP.confirmedRedDot
                                                          ? AppColors.errorColor
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.sp),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setLockScreenStatus(true);
                                            // _isPasscodeSet ?
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) => Unlock()),
                                                  (Route<dynamic> route) => false, // This predicate removes all previous routes
                                            );


                                          },
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 5.sp),
                                            child:
                                            Image.asset(
                                              "assets/images/lock.png",
                                              height: 19.sp,
                                              width: 19.sp,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.textColorGrey,
                                      borderRadius: BorderRadius.circular(100)),
                                  child: Padding(
                                    padding: EdgeInsets.all(1.sp),
                                    child: Container(
                                      height: 60.sp,
                                      width: 60.sp,
                                      decoration: BoxDecoration(
                                          color: AppColors.backgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Padding(
                                        padding: EdgeInsets.all(1.sp),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child:
                                          user.userAvatar != null
                                              ?
                                          Image.network(
                                                  user.userAvatar!,
                                                  fit: BoxFit.cover,

                                                )
                                              :
                                          Padding(
                                            padding:  EdgeInsets.all(4.sp),
                                            child: Image.asset(
                                                    "assets/images/user_placeholder.png",
                                              color: AppColors.textColorGrey,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  user.userName != null
                                      ? user.userName!
                                      : 'username.mjra'.tr(),
                                  style: TextStyle(
                                      fontSize: 11.7.sp,
                                      fontFamily: 'Blogger Sans',
                                      fontWeight: FontWeight.w700,
                                      color: themeNotifier.isDark
                                          ? AppColors.textColorWhite
                                          : AppColors.textColorBlack),
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                // if(user.walletAddress != null)
                                GestureDetector(
                                  onTap: () =>
                                      _copyToClipboard(user.walletAddress!),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        user.walletAddress != null
                                            ? replaceMiddleWithDots(
                                                user.walletAddress!)
                                            : "...",
                                        // '0x1647f...87332',
                                        style: TextStyle(
                                            fontSize: 9.5.sp,
                                            fontFamily: 'Blogger Sans',
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textColorGrey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                height: 65.h,
                                width: double.infinity,
                                color: themeNotifier.isDark
                                    ? AppColors.backgroundColor
                                    : AppColors.textColorWhite,
                                child: Column(
                                  children: [
                                    PreferredSize(
                                      preferredSize:
                                          Size.fromHeight(kToolbarHeight + 10),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              height: 1.sp,
                                              color: themeNotifier.isDark
                                                  ? AppColors
                                                      .transactionSummNeoBorder
                                                  : AppColors
                                                      .tabUnselectedClorLight,
                                            ),
                                          ),
                                          Container(
                                            color: Colors.transparent,
                                            // Background color of the TabBar

                                            child:
                                            TabBar(
                                              controller: _tabController,
                                              // indicatorPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                              indicatorColor:
                                                  AppColors.activeButtonColor,
                                              unselectedLabelColor:
                                                  AppColors.textColorGrey,
                                              labelColor: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                              labelStyle: TextStyle(
                                                  color: themeNotifier.isDark
                                                      ? AppColors.textColorWhite
                                                      : AppColors.textColorBlack,
                                                  fontSize: 11.5.sp,
                                                  fontWeight: FontWeight.w600),
                                              tabs: [
                                                Tab(text: "     " + 'Tokens'.tr() +"     "),
                                                Tab(text: "      " + 'NFTs'.tr() + "       "),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _isloading
                                        ? Padding(
                                            padding: EdgeInsets.only(top: 25.h),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.activeButtonColor,
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            child: TabBarView(
                                              controller: _tabController,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 15.h,
                                                  ),
                                                  child: Text(
                                                    "You have no Tokens",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: themeNotifier.isDark
                                                            ? AppColors
                                                                .textColorGreyShade2
                                                            : AppColors
                                                                .textColorBlack,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12.sp,
                                                        fontFamily: 'Blogger Sans'),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                        height: 8.h,
                                                        width: 100.w,
                                                        color: themeNotifier.isDark
                                                            ? AppColors
                                                                .backgroundColor
                                                            : AppColors
                                                                .textColorWhite,
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 16.sp,
                                                            ),
                                                            // vertical: 10.sp),
                                                            child: Row(
                                                              children: [
                                                                NFTCategoryWidget(
                                                                  title: "All".tr(),
                                                                  // image: "",
                                                                  isFirst: true,
                                                                  index: 0,
                                                                  handler: () =>
                                                                      onCategorySelected(
                                                                          0),
                                                                ),
                                                                NFTCategoryWidget(
                                                                    title: "Owned"
                                                                        .tr(),
                                                                    // image:
                                                                    //     'assets/images/cat_dig_art.png',
                                                                    index: 1,
                                                                    handler: () {
                                                                      setState(() {
                                                                        _isloading =
                                                                            true;
                                                                      });
                                                                      onCategorySelected(
                                                                          1);
                                                                      setState(() {
                                                                        _isloading =
                                                                            false;
                                                                      });
                                                                    }),
                                                                NFTCategoryWidget(
                                                                  title: "Created"
                                                                      .tr(),
                                                                  // image:
                                                                  //     'assets/images/cat_sports.png',
                                                                  index: 2,
                                                                  handler: () =>
                                                                      onCategorySelected(
                                                                          2),
                                                                ),
                                                                NFTCategoryWidget(
                                                                  title:
                                                                      "Listed".tr(),
                                                                  // image:
                                                                  //     'assets/images/cat_animals.png',
                                                                  index: 3,
                                                                  handler: () =>
                                                                      onCategorySelected(
                                                                          3),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )),
                                                    Expanded(
                                                        child: bottomSpaceContent(
                                                            nftsCollectionAll,
                                                            nftsAll,
                                                            nftsCollectionOwnedByUser,
                                                            nftsOwned,
                                                            themeNotifier.isDark,
                                                            nftsCollectionCreated,
                                                            nftsCreated,
                                                            nftsListed,
                                                            collectionListed))
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                  ],
                                ),
                              ),
                              if(showCopiedMsg)
                              Positioned(
                                left: 10,
                                right: 10,
                                bottom: 40,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: 4.h,
                                    width: 35.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.sp),
                                      color: AppColors.profileHeaderDark,
                                    ),

                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/images/hesa_wallet_logo.png",
                                          fit: BoxFit.cover,
                                          height: 12.sp,
                                          width: 12.sp,
                                        ),
                                        SizedBox(width: 5.sp,),
                                        Text(
                                          'Address copied!',
                                          style: TextStyle(
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textColorWhite,
                                              fontFamily: 'Blogger Sans'
                                          ),)
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

            // if (showLockedScreen)
            //   WelcomeScreen(
            //     handler: () =>
            //         setState(() {
            //           showLockedScreen = false;
            //         }),
            //   ),
          ],
        );
      });
    });
  }

  Widget NFTCategoryWidget(
      {required String title,
      Function? handler,
      // String? image,
      bool isFirst = false,
      required int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = index;
        });
        handler!();
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.sp),
        decoration: BoxDecoration(
            color: _isSelected == index
                ? AppColors.hexaGreen.withOpacity(0.10)
                : AppColors.profileHeaderDark,
            border: Border.all(
                color: _isSelected == index
                    ? AppColors.hexaGreen
                    : Colors.transparent,
                width: 1),
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.sp, vertical: 8.sp),
          child: Row(
            children: [
              if (!isFirst)
                SizedBox(
                  width: 4.sp,
                ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: _isSelected == index
                        ? AppColors.hexaGreen
                        : AppColors.textColorGreyShade2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSpaceContent(
    var nftsCollectionAll,
    var nftsAll,
    var nftsCollectionOwnedByUser,
    var nftsOwned,
    var isDark,
    var nftsCollectionCreated,
    var nftsCreated,
    var nftsListed,
    var nftsCollectionListed,
  ) {
    switch (selectedCategoryIndex) {
      case 0: // All
        // Replace AllNFTList with your widget displaying all categories
        return NftsCollectionDivision(
            nftsCollection: nftsCollectionAll,
            nfts:
                nftsAll); // Replace AllNFTList with your widget displaying all categories
      case 1: // Owned
        return NftsCollectionDivision(
          nftsCollection: nftsCollectionOwnedByUser,
          nfts: nftsOwned,
        );

      case 2: // Created
        return NftsCollectionDivision(
          nftsCollection: nftsCollectionCreated,
          nfts: nftsCreated,
        );
      case 3: // Listed
        return NftsCollectionDivision(
          nftsCollection: nftsCollectionListed,
          nfts: nftsListed,
        ); // Replace ListedNFTList with your widget displaying listed categories
      // return ListedNFTList(); // Replace ListedNFTList with your widget displaying listed categories
      default:
        return Container(); // Default case, return an empty container or handle as per your requirement
    }
  }



  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      showCopiedMsg=true;
    });
    Future.delayed(Duration(milliseconds: 3000), () {
      setState(() {
        showCopiedMsg=false;
      });
    });
    // fToast = FToast();
    // fToast.init(context);

  }
}
