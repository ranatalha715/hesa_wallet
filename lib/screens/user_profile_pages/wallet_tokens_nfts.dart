import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uni_links/uni_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/providers/nfts_provider.dart';
import 'package:hesa_wallet/widgets/nfts_collection_divisions/nfts_collections_division.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';
import '../signup_signin/welcome_screen.dart';
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
    await Provider.of<NftsProvider>(context, listen: false)
        .getAllNftsCollection(
      token: accessToken,
      context: context,
      walletAddress: user.walletAddress!,
    );
    await Provider.of<NftsProvider>(context, listen: false).nftsOwnedByUser(
      token: accessToken,
      walletAddress: user.walletAddress!,
      context: context,
    );
    await Provider.of<NftsProvider>(context, listen: false)
        .getNftsCollectionOwnedByUser(
      token: accessToken,
      walletAddress: user.walletAddress!,
      context: context,
    );
    await Provider.of<NftsProvider>(context, listen: false).nftsCreatedByUser(
      token: accessToken,
      context: context,
      walletAddress: user.walletAddress!,
    );

    await Provider.of<NftsProvider>(context, listen: false)
        .getNftsCollectionCreatedByUser(
      token: accessToken,
      context: context,
      walletAddress: user.walletAddress!,
    );

    setState(() {
      _isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();
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

  // uniilink

  String _receivedData = 'No UniLink data received';

  Future<void> initUniLinks() async {
    // Initialize UniLinks
    // await initPlatformState();
    // Listen for incoming links
    // AppDeepLinking().initDeeplink(); muzamil recommended
    getLinksStream().listen((String? link) {
      print(link.toString() + " before");
      if (link != null) {
        setState(() {
          _receivedData = link;
        });

        Uri uri = Uri.parse(link);
        String? operation = uri.queryParameters['operation'];
        print('operation mint' + operation.toString());

        if (operation != null && operation == 'MintNFT') {
          // Navigate to page for MintNFT operation
          navigateToTransactionRequestWithMint(
              uri.queryParameters, operation, context);
        } else
          if (operation != null && operation == 'MintCollection') {
          // Navigate to other page
          navigateToTransactionRequestWithMintCollection(
              uri.queryParameters, operation, context);
        }
          else
          if (operation != null && operation == 'MintNFTWithEditions') {
            // Navigate to other page
            navigateToTransactionRequestWithMintNFTWithEditions(
                uri.queryParameters, operation, context);
          }
          else if (operation != null && operation == 'purchaseNFT') {
          //purchaseNFT
          navigateToTransactionRequestWithPurchaseNft(
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
        }
        else if (operation != null && operation == 'burnCollection') {
          //burnCollection
          navigateToTransactionRequestWithBurnCollection(
              uri.queryParameters, operation, context);
        }
        else if (operation != null && operation == 'makeOfferNFT') {
          //makeOfferNFT
          navigateToTransactionRequestWithMakeOfferNFT(
              uri.queryParameters, operation, context);
        }
        else if (operation != null && operation == 'acceptOfferReceived') {
          //acceptOfferReceived
          navigateToTransactionRequestAcceptRejectWithAcceptOffer(
              uri.queryParameters, operation, context);
        }
          else if (operation != null && operation == 'AcceptCollectionOffer') {
            //AcceptCollectionOffer
            navigateToTransactionRequestAcceptRejectWithAcceptCollectionOffer(
                uri.queryParameters, operation, context);
          }
        else if (operation != null && operation == 'rejectNFTOfferReceived') {
          //rejectNFTOfferReceived
          navigateToTransactionRequestAcceptRejectWithrejectNFTOfferReceived(
              uri.queryParameters, operation, context);
        }
          else if (operation != null && operation == 'rejectCollectionOfferReceived') {
            //rejectCollectionOfferReceived
            navigateToTransactionRequestAcceptRejectWithrejectCollectionOfferReceived(
                uri.queryParameters, operation, context);
          }
        else if (operation != null && operation == 'CancelNFTOfferMade') {
          //CancelNFTOfferMade
          navigateToTransactionRequestAcceptRejectWithCancelNFTOfferMade(
              uri.queryParameters, operation, context);
        }
          else if (operation != null && operation == 'CancelAuctionListing') {
            //CancelAuctionListing
            navigateToTransactionRequestAcceptRejectWithCancelAuctionListing(
                uri.queryParameters, operation, context);
          }
          else if (operation != null && operation == 'CancelCollectionAuctionListing') {
            //CancelCollectionAuctionListing
            navigateToTransactionRequestAcceptRejectWithCancelCollectionAuctionListing(
                uri.queryParameters, operation, context);
          }
        else
        if (operation != null && operation == 'CancelCollectionOfferMade') {
          //CancelCollectionOfferMade
          navigateToTransactionRequestAcceptRejectWithCancelCollectionOfferMade(
              uri.queryParameters, operation, context);
        }
        else if (operation != null && operation == 'makeNFTCounterOffer') {
          //makeNFTCounterOffer
          var data = json.decode(uri.queryParameters["params"]!);
          String? id = data['id'];
          String? offererId = data['offererId'];
          int? offerAmount = int.tryParse(data['offerAmount'].toString() ?? '');
          print('test params individually');
          print(id.toString() + "  " + offererId.toString() + "  " +
              offerAmount.toString());
          navigateToTransactionRequestAcceptRejectWithMakeCounterOffer(
              uri.queryParameters, operation, context, id.toString(),
              offererId.toString(), offerAmount.toString());
        }
        else
        if (operation != null && operation == 'makeCollectionCounterOffer') {
          //makeNFTCounterOffer
          var data = json.decode(uri.queryParameters["params"]!);
          String? id = data['id'];
          String? offererId = data['offererId'];
          int? offerAmount = int.tryParse(data['offerAmount'].toString() ?? '');
          print('test params individually');
          print(id.toString() + "  " + offererId.toString() + "  " +
              offerAmount.toString());
          navigateToTransactionRequestAcceptRejectWithmakeCollectionCounterOffer(
              uri.queryParameters, operation, context, id.toString(),
              offererId.toString(), offerAmount.toString());
        }
        else if (operation != null && operation == 'acceptCounterOffer') {
          //acceptCounterOffer
          navigateToTransactionRequestWithAcceptCounterOffer(
              uri.queryParameters, operation, context);
        }
        else if (operation != null && operation == 'rejectNFTCounterOffer') {
          //makeNFTCounterOffer
          var data = json.decode(uri.queryParameters["params"]!);
          String? id = data['id'];
          String? offererId = data['offererId'];
          int? offerAmount = int.tryParse(data['offerAmount'].toString() ?? '');
          print('test params individually');
          print(id.toString() + "  " + offererId.toString() + "  " +
              offerAmount.toString());
          navigateToTransactionRequestAcceptRejectWithrejectNFTCounterOffer(
              uri.queryParameters, operation, context, id.toString(),
              offererId.toString(), offerAmount.toString());
        }
        else
        if (operation != null && operation == 'rejectCollectionCounterOffer') {
          //makeNFTCounterOffer
          var data = json.decode(uri.queryParameters["params"]!);
          String? id = data['id'];
          String? offererId = data['offererId'];
          int? offerAmount = int.tryParse(data['offerAmount'].toString() ?? '');
          print('test params individually');
          print(id.toString() + "  " + offererId.toString() + "  " +
              offerAmount.toString());
          navigateToTransactionRequestAcceptRejectWithrejectCollectionCounterOffer(
              uri.queryParameters, operation, context, id.toString(),
              offererId.toString(), offerAmount.toString());
        }
        else
        if (operation != null && operation == 'acceptCollectionCounterOffer') {
          //acceptCollectionCounterOffer
          navigateToTransactionRequestWithacceptCollectionCounterOffer(
              uri.queryParameters, operation, context);
        }
        else {}
      }
    }
    );
  }

  Future<void> navigateToTransactionRequestWithMintCollection(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithMintNFTWithEditions(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithMint(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithPurchaseNft(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithListNftFixedPrice(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithListCollectionFixedPrice(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithListNftForAuction(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithListCollectionForAuction(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithBurnNFT(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithBurnCollection(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithMakeOfferNFT(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
    });
  }

  Future<void> navigateToTransactionRequestWithAcceptCounterOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestWithacceptCollectionCounterOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(TransactionRequest.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestAcceptRejectWithAcceptOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestAcceptRejectWithAcceptCollectionOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<
      void> navigateToTransactionRequestAcceptRejectWithrejectNFTOfferReceived(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<
      void> navigateToTransactionRequestAcceptRejectWithrejectCollectionOfferReceived(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestAcceptRejectWithCancelNFTOfferMade(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<
      void> navigateToTransactionRequestAcceptRejectWithCancelCollectionOfferMade(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<
      void> navigateToTransactionRequestAcceptRejectWithCancelAuctionListing(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<
      void> navigateToTransactionRequestAcceptRejectWithCancelCollectionAuctionListing(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "walletAddress":userWalletAddress
    });
  }

  Future<void> navigateToTransactionRequestAcceptRejectWithMakeCounterOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx,
      String id,
      String offererId,
      String offerAmount,) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "id": id,
      "offererId": offererId,
      "offerAmount": offerAmount,
      "walletAddress":userWalletAddress
    });
    print('chal gia');
  }

  Future<
      void> navigateToTransactionRequestAcceptRejectWithrejectNFTCounterOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx,
      String id,
      String offererId,
      String offerAmount,) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "id": id,
      "offererId": offererId,
      "offerAmount": offerAmount,
      "walletAddress":userWalletAddress
    });
    print('chal gia');
  }

  Future<
      void> navigateToTransactionRequestAcceptRejectWithrejectCollectionCounterOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx,
      String id,
      String offererId,
      String offerAmount,) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "id": id,
      "offererId": offererId,
      "offerAmount": offerAmount,
      "walletAddress":userWalletAddress
    });
    print('chal gia');
  }

  Future<
      void> navigateToTransactionRequestAcceptRejectWithmakeCollectionCounterOffer(
      Map<String, dynamic> queryParams,
      String operation,
      BuildContext ctx,
      String id,
      String offererId,
      String offerAmount,) async {
    String paramsString = queryParams['params'] ?? '';
    await Navigator.of(ctx).pushNamed(
        TransactionRequestAcceptReject.routeName, arguments: {
      "params": paramsString,
      "operation": operation,
      "id": id,
      "offererId": offererId,
      "offerAmount": offerAmount,
      "walletAddress":userWalletAddress
    });
  }

  bool showLockedScreen = false;

  @override
  Widget build(BuildContext context) {
    final nftsCollectionAll =
        Provider
            .of<NftsProvider>(context, listen: false)
            .nftsCollectionAll;
    final nftsAll = Provider
        .of<NftsProvider>(context, listen: false)
        .nftsCreated; //WILL CHANGE THIS
    final nftsOwned =
        Provider
            .of<NftsProvider>(context, listen: false)
            .nftsOwned;
    final nftsCollectionOwnedByUser =
        Provider
            .of<NftsProvider>(context, listen: false)
            .nftsCollectionOwnedByUser;

    final nftsCreated =
        Provider
            .of<NftsProvider>(context, listen: false)
            .nftsCreated;
    final nftsCollectionCreated =
        Provider
            .of<NftsProvider>(context, listen: false)
            .nftsCollectionCreated;
    return Consumer<UserProvider>(builder: (context, user, child) {
      return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
        return Stack(
          children: [
            Scaffold(
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
                                  left: 14.sp, right: 20.sp, bottom: 8.sp),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
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

                                        Positioned(
                                          right: 1,
                                          // bottom: 2.sp,
                                          child: Container(
                                            height: 4.3.sp,
                                            width: 4.3.sp,
                                            decoration: BoxDecoration(
                                              color: AppColors.errorColor,
                                              borderRadius:
                                              BorderRadius.circular(10.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(20.sp),
                                  //     border: Border.all(
                                  //       color: AppColors.textColorGrey,
                                  //       width: 1,
                                  //     ),
                                  //   ),
                                  //   child: Padding(
                                  //     padding: EdgeInsets.only(
                                  //         left: 8.sp,
                                  //         right: 8.sp,
                                  //         top: 5.sp,
                                  //         bottom: 5.sp),
                                  //     child: Row(
                                  //       children: [
                                  //         Icon(
                                  //           Icons.fiber_manual_record,
                                  //           size: 7.sp,
                                  //           color: AppColors.textColorGrey,
                                  //         ),
                                  //         SizedBox(
                                  //           width: 2.w,
                                  //         ),
                                  //         Text(
                                  //           'AlMajra B-01'.tr(),
                                  //           style: TextStyle(
                                  //               fontSize: 9.8.sp,
                                  //               fontWeight: FontWeight.w500,
                                  //               color: themeNotifier.isDark
                                  //                   ? AppColors.textColorWhite
                                  //                   : AppColors.textColorBlack),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() {
                                          showLockedScreen = true;
                                        }),
                                    //     Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => WelcomeScreen()),
                                    // ),
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 5.sp),
                                      child: Image.asset(
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
                                //     gradient: LinearGradient(
                                //       colors: [Color(0xff92B928), Color(0xffC9C317)],
                                //       begin: Alignment.topLeft,
                                //       end: Alignment.bottomRight,
                                //     ),
                                borderRadius: BorderRadius.circular(100)),
                            child: Padding(
                              padding: EdgeInsets.all(1.sp),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: AppColors.backgroundColor,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Padding(
                                  padding: EdgeInsets.all(1.sp),
                                  child:
                                  // SvgPicture.string(
                                  //   // Replace 'base64EncodedSvg' with your actual Base64-encoded SVG string
                                  //   Provider.of<UserProvider>(context, listen: false).userAvatar!,
                                  //   // You can set width and height to adjust the size of the SVG image
                                  //   width: 55.sp,
                                  //   height: 55.sp,
                                  // ),
                                  Image.asset(
                                    // user.userAvatar!,
                                    //     Provider.of<UserProvider>(context, listen: false).userAvatar ?? "",
                                    "assets/images/profile.png",
                                    height: 55.sp,
                                    width: 55.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2.5.h,
                          ),
                          Text(
                            user.userName != null
                                ? user.userName! + ".mjra"
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
                            onTap: () => _copyToClipboard(user.walletAddress!),
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
                                SizedBox(
                                  width: 3.sp,
                                ),
                                Icon(
                                  Icons.content_copy,
                                  size: 10.sp,
                                  color: AppColors.textColorGrey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 65.h,
                      width: double.infinity,
                      color: themeNotifier.isDark
                          ? AppColors.backgroundColor
                          : AppColors.textColorWhite,
                      child: Column(
                        children: [
                          PreferredSize(
                            preferredSize: Size.fromHeight(kToolbarHeight + 10),
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 1.sp,
                                    color: themeNotifier.isDark
                                        ? AppColors.transactionSummNeoBorder
                                        : AppColors.tabUnselectedClorLight,
                                  ),
                                ),
                                Container(
                                  color: Colors.transparent,
                                  // Background color of the TabBar

                                  child: TabBar(
                                    controller: _tabController,
                                    indicatorColor: AppColors.activeButtonColor,
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
                                      Tab(text: 'Tokens'.tr()),
                                      Tab(text: 'NFTs'.tr()),
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
                                    vertical: 18.h,
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "You have no Tokens",
                                      style: TextStyle(
                                          color: themeNotifier.isDark
                                              ? AppColors
                                              .textColorGreyShade2
                                              : AppColors.textColorBlack,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12.sp,
                                          fontFamily: 'Blogger Sans'),
                                    ),
                                  ),
                                ),
                                //show this when data is empty
                                // Center(child: Text('You have no NFTs under \nthis wallet ID',
                                //   textAlign: TextAlign.center,
                                //   style: TextStyle(
                                //     color: AppColors.textColorGrey,
                                //     fontWeight: FontWeight.w400,
                                //     fontSize: 11.5.sp,
                                //   ),
                                // )),
                                Column(
                                  children: [
                                    Container(
                                        height: 8.h,
                                        width: 100.w,
                                        color: themeNotifier.isDark
                                            ? AppColors.backgroundColor
                                            : AppColors.textColorWhite,
                                        child: SingleChildScrollView(
                                          scrollDirection:
                                          Axis.horizontal,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
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
                                                  title: "Owned".tr(),
                                                  // image:
                                                  //     'assets/images/cat_dig_art.png',
                                                  index: 1,
                                                  handler: () =>
                                                      onCategorySelected(
                                                          1),
                                                ),
                                                NFTCategoryWidget(
                                                  title: "Created".tr(),
                                                  // image:
                                                  //     'assets/images/cat_sports.png',
                                                  index: 2,
                                                  handler: () =>
                                                      onCategorySelected(
                                                          2),
                                                ),
                                                NFTCategoryWidget(
                                                  title: "Listed".tr(),
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
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showLockedScreen)
              WelcomeScreen(
                handler: () =>
                    setState(() {
                      showLockedScreen = false;
                    }),
              ),
          ],
        );
      });
    });
  }

  Widget NFTCategoryWidget({required String title,
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
            border: Border.all(
                color: _isSelected == index
                    ? AppColors.activeButtonColor
                    : AppColors.textColorWhite,
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
                    color: AppColors.textColorGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSpaceContent(var nftsCollectionAll,
      var nftsAll,
      var nftsCollectionOwnedByUser,
      var nftsOwned,
      var isDark,
      var nftsCollectionCreated,
      var nftsCreated) {
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
          nftsCollection: nftsCollectionCreated,
          nfts: nftsCreated,
        ); // Replace ListedNFTList with your widget displaying listed categories
    // return ListedNFTList(); // Replace ListedNFTList with your widget displaying listed categories
      default:
        return Container(); // Default case, return an empty container or handle as per your requirement
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    fToast = FToast();
    fToast.init(context);
    // _showToast('Wallet address copied!');
  }
}
