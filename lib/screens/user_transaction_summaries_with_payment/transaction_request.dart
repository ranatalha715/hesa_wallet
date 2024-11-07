import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/models/payment_card_model.dart';
import 'package:hesa_wallet/providers/card_provider.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/screens/signup_signin/terms_conditions.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:hesa_wallet/widgets/button.dart';
import 'package:hyperpay_plugin/model/custom_ui.dart';
import 'package:hyperpay_plugin/model/ready_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'dart:io' as OS;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hyperpay_plugin/flutter_hyperpay.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

import '../../constants/app_deep_linking.dart';
import '../../constants/configs.dart';
import '../../constants/inapp_settings.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/main_header.dart';
import '../../widgets/payment_fees/payment_fees.dart';
import '../userpayment_and_bankingpages/wallet_add_bank.dart';
import '../userpayment_and_bankingpages/wallet_add_card.dart';

class TransactionRequest extends StatefulWidget {
  const TransactionRequest({Key? key}) : super(key: key);

  static const routeName = 'transactionRequest';

  @override
  State<TransactionRequest> createState() => _TransactionRequestState();
}

class _TransactionRequestState extends State<TransactionRequest> {
  var _selectedPaymentCard = false;
  bool _isSelected = false;
  var _selectedBankDetails = false;
  var params;
  var operation;
  var walletAddress;
  var country;
  var transactionType;
  var transactionID;
  var mintingFee;
  var networkFee;
  var paymentProcessingFee;
  var totalTransactionAmount;
  var userWalletID;
  var creatorRolaity;
  var tokenstatus;
  var ownerid;
  var creatorId;
  var itemCollectionID;
  var unformatted = DateTime.now();

  final ScrollController scrollController = ScrollController();
  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();
  FocusNode firstFieldFocusNode = FocusNode();

  FocusNode secondFieldFocusNode = FocusNode();

  FocusNode thirdFieldFocusNode = FocusNode();

  FocusNode forthFieldFocusNode = FocusNode();

  FocusNode fifthFieldFocusNode = FocusNode();

  FocusNode sixthFieldFocusNode = FocusNode();
  var isLoading = false;
  var isCardLoading = false;
  var isDialogLoading = false;
  var isInit = true;
  var isValidating = false;
  var setThemeDark = true;
  var fees = "";
  Map<String, dynamic>? feesMap;
  Map<String, dynamic>? paramsMap;
  var wstoken = "";
  var accessToken = "";
  bool IsScrolled = false;
  late FlutterHyperPay flutterHyperPay;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    accessToken = prefs.getString('accessToken')!;
    print(accessToken);
  }

  makeIsScrolledFalse() {
    setState(() {
      IsScrolled = false;
    });
  }

  makeIsScrolledTrue() {
    setState(() {
      IsScrolled = true;
    });
  }

  init() async {}

  ScrollController _scrollController = ScrollController();

  void payRequestNowReadyUI(
      {required List<String> brandsName,
      required String checkoutId,
      required operation}) async {
    try {
      PaymentResultData paymentResultData;
      paymentResultData = await flutterHyperPay.readyUICards(
        readyUI: ReadyUI(
          brandsName: brandsName,
          checkoutId: checkoutId,
          // checkoutId: checkoutId,
          merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
          countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
          companyNameApplePayIOS: "LIMAR INTERNATIONAL TECHNOLGIES",
          themColorHexIOS: "#000000",
          // FOR IOS ONLY
          setStorePaymentDetailsMode:
              true, // store payment details for future use
        ),
      );
      print("paymentResultData.paymentResult=");
      print(paymentResultData.paymentResult);
      if (paymentResultData.paymentResult == PaymentResult.success ||
          paymentResultData.paymentResult == PaymentResult.sync) {
        setState(() {
          isLoading = true;
        });
        print(
          'CheckoutID Talha' +
              Provider.of<TransactionProvider>(context, listen: false)
                  .checkoutId,
        );
        paymentSuccesfullDialogue(
            amount: Provider.of<TransactionProvider>(
                context,
                listen: false)
                .totalForDialog );
        Provider.of<TransactionProvider>(context, listen: false)
            .functionToNavigateAfterPayable(
                paymentResultData.paymentResult.toString(), operation, context,
                statusCode: '201');
        setState(() {
          isLoading = false;
        });
        print('Payment successful');
        print('ye response ${paymentResultData}');
        // Handle success
      } else {
        print('Payment failed');
        paymentFailedDialogue(amount: Provider.of<TransactionProvider>(
            context,
            listen: false)
            .totalForDialog);
        Provider.of<TransactionProvider>(context, listen: false)
            .functionToNavigateAfterPayable(
            paymentResultData.paymentResult.toString(), operation, context,
            statusCode: '400');
        print('Failure Reason: ${paymentResultData.errorString}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      paymentFailedDialogue(amount: Provider.of<TransactionProvider>(
          context,
          listen: false)
          .totalForDialog);
      setState(() {
        isLoading = false;
      });
    }
  }

  late FToast fToast;

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

  @override
  void initState() {
    // Future.delayed(Duration(seconds: 2), () {
    //
    //   paymentSuccesfullDialogue(isDark: setThemeDark);
    // }
    // );
    init();
    // Locale currentLocale = context.locale;
    // bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    fToast = FToast();
    fToast.init(context);
    // flutterHyperPay = FlutterHyperPay(
    //   shopperResultUrl: InAppPaymentSetting.shopperResultUrl,
    //   paymentMode: PaymentMode.test,
    //   lang: isEnglish ? "en_US" : 'ar_AR',
    // );

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (isInit) {
      setState(() {
        isCardLoading = true;
      });
      await getAccessToken();
      // await Provider.of<UserProvider>(context, listen: false)
      //     .getUserDetails(token: accessToken, context: context);
      await Provider.of<UserProvider>(context, listen: false)
          .getUserDetails(token: accessToken, context: context);
      setState(() {
        isCardLoading = false;
      });
    }
    isInit = false;
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en';

    flutterHyperPay = FlutterHyperPay(
      shopperResultUrl: InAppPaymentSetting.shopperResultUrl,
      paymentMode: PaymentMode.test,
      lang: isEnglish ? "en_US" : 'ar_AR',
    );

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  String displayedText = '';
  String formattedExpiryDate = '';
  String displayedName = '';
  final TextEditingController _cardnumberController = TextEditingController();

  String addSpacesToText(String input) {
    final chunkSize = 4;
    final chunks = <String>[];

    for (int i = 0; i < input.length; i += chunkSize) {
      final end =
          (i + chunkSize <= input.length) ? i + chunkSize : input.length;
      chunks.add(input.substring(i, end));
    }

    return chunks.join(' ');
  }

  String replaceMiddleWithDots(String input) {
    if (input.length <= 30) {
      return input;
    }

    final int middleIndex = input.length ~/ 2; // Find the middle index
    final int startIndex = middleIndex - 15; // Calculate the start index
    final int endIndex = middleIndex + 15; // Calculate the end index

    // Split the input string into three parts and join them with '...'
    final String result =
        input.substring(0, startIndex) + '...' + input.substring(endIndex);

    return result;
  }

  String replaceMiddleWithDotsTokenId(String input) {
    if (input.length <= 30) {
      return input;
    }

    final int middleIndex = input.length ~/ 2; // Find the middle index
    final int startIndex = middleIndex - 12; // Calculate the start index
    final int endIndex = middleIndex + 9; // Calculate the end index

    // Split the input string into three parts and join them with '...'
    final String result =
        input.substring(0, startIndex) + '...' + input.substring(endIndex);

    return result;
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  rejectTransactions() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(seconds: 2), () async {
      print(
        "operation" + operation,
      );
      print("data" + "$operation transaction has been cancelled by the user,");
      setState(() {
        isLoading = false;
      });
      await AppDeepLinking().openNftApp(
        {
          "operation": operation,
          "statusCode": "300",
          "data": "$operation transaction has been cancelled by the user",
        },
      );
      Navigator.pop(context);
    });
  }

  navigateToAddCard() async {
    print('card brand');
    print(Provider.of<TransactionProvider>(context, listen: false)
        .selectedCardBrand);
    var result = await Provider.of<TransactionProvider>(context, listen: false)
        .tokenizeCardRequest(
            token: accessToken,
            brand: Provider.of<TransactionProvider>(context, listen: false)
                .selectedCardBrand,
            context: context);
    if (result == AuthResult.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WalletAddCard(
            tokenizedCheckoutId:
                Provider.of<TransactionProvider>(context, listen: false)
                    .tokenizedCheckoutId,
          ),
        ),
      );
    }
  }

  void confirmBrandDialogue(Function onCloseHandler,
      {required bool showPopup}) {
    if (showPopup) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final dialogWidth = screenWidth * 0.85;
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Colors.transparent,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    height: 23.h,
                    width: dialogWidth,
                    decoration: BoxDecoration(
                      color: AppColors.showDialogClr,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textColorBlack.withOpacity(0.95),
                          offset: Offset(0, 0),
                          blurRadius: 10,
                          spreadRadius: 0.4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Please select your card type'.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: AppColors.textColorWhite),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Provider.of<TransactionProvider>(context,
                                        listen: false)
                                    .selectedCardBrand = 'VISA';
                                // Navigator.pop(context);
                                navigateToAddCard();
                              },
                              child: Image.asset(
                                "assets/images/VisaPopup.png",
                                height: 40.sp,
                                width: 40.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Provider.of<TransactionProvider>(context,
                                        listen: false)
                                    .selectedCardBrand = 'MASTER';
                                navigateToAddCard();
                              },
                              child: Image.asset(
                                "assets/images/MastercardPopup.png",
                                height: 40.sp,
                                width: 40.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Provider.of<TransactionProvider>(context,
                                        listen: false)
                                    .selectedCardBrand = 'MADA';
                                navigateToAddCard();
                              },
                              child: Image.asset(
                                "assets/images/MadaPayPopup.png",
                                height: 45.sp,
                                width: 44.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                      ],
                    ),
                  )),
            );
          });
        },
      ).then((value) => onCloseHandler());
    } else {
      onCloseHandler();
    }
  }

  String formatCurrency(String? numberString) {
    // Check if the string is null or empty
    if (numberString == null || numberString.isEmpty) {
      return "0"; // Return a default value if input is invalid
    }

    try {
      // Convert the string to a number (num handles both int and double)
      num number = num.parse(numberString);
      final formatter = NumberFormat("#,##0.##", "en_US");
      return formatter.format(number);
    } catch (e) {
      // Handle any format exceptions and return a fallback
      return "Invalid Number";
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      print('args params' + args['params']);
      params = args['params'] ?? "N/A";
      paramsMap = jsonDecode(params);
      operation = args['operation'] ?? "N/A";
      walletAddress = args['walletAddress'] ?? "N/A";
      fees = args['fees'] ?? "N/A";
      feesMap = jsonDecode(fees);
      country = args['country'] ?? "N/A";
      transactionType = args['transactionType'] ?? "N/A";
      transactionID = args['transactionID'] ?? "N/A";
      mintingFee = args['mintingFee'] ?? "N/A";
      networkFee = args['networkFee'] ?? "N/A";
      paymentProcessingFee = args['paymentProcessingFee'] ?? "N/A";
      totalTransactionAmount = args['totalTransactionAmount'] ?? "N/A";
      userWalletID = args['userWalletID'] ?? "N/A";
      creatorRolaity = args['creatorRolaity'] ?? "N/A";
      tokenstatus = args['tokenstatus'] ?? "N/A";
      ownerid = args['ownerid'] ?? "N/A";
      creatorId = args['creatorId'] ?? "N/A";
      itemCollectionID = args['itemCollectionID'] ?? "N/A";
    }
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final formattedText = addSpacesToText(displayedText);
    List<dynamic> feeses = feesMap!.values.toList();
    final paymentCards =
        Provider.of<UserProvider>(context, listen: false).paymentCards;
    var trPro = Provider.of<TransactionProvider>(context, listen: false);
    if (trPro.selectedCardNum == null || trPro.selectedCardNum == "") {
      if (paymentCards.isNotEmpty) {
        trPro.selectedCardNum = paymentCards[0].bin;
        trPro.selectedCardLast4Digits = paymentCards[0].last4Digits;
        trPro.selectedCardBrand = paymentCards[0].cardBrand;
      }
    }
    if (trPro.selectedCardTokenId == null || trPro.selectedCardTokenId == "") {
      if (paymentCards.isNotEmpty) {
        trPro.selectedCardTokenId = paymentCards[0].id;
      }
    }
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      setThemeDark = themeNotifier.isDark;
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(
                  title: "Transaction Request".tr(),
                  // height: IsScrolled ? 12.h : 21.h,
                  IsScrolled: IsScrolled,
                ),

                Container(
                  height: 88.h,
                  // color: Colors.yellow,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 3.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.sp),
                          child: Container(
                            height: 10.6.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.showDialogClr,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment: isEnglish
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  if (currentLocale.languageCode == 'en')
                                    Image.asset(
                                      "assets/images/neo.png",
                                      height: 5.5.h,
                                      // width: 104,
                                    ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Column(
                                    crossAxisAlignment: isEnglish
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'From:'.tr(),
                                        style: TextStyle(
                                            color: AppColors.textColorGrey,
                                            fontSize: 8.5.sp,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 3.sp,
                                      ),
                                      Text(
                                        'https://neo-nft.com',
                                        style: TextStyle(
                                            color: AppColors.textColorToska,
                                            // color: themeNotifier.isDark
                                            //     ? AppColors.textColorWhite
                                            //     : AppColors.textColorBlack,
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  if (currentLocale.languageCode == 'ar')
                                    SizedBox(
                                      width: 15,
                                    ),
                                  if (currentLocale.languageCode == 'ar')
                                    Image.asset(
                                      "assets/images/neo.png",
                                      height: 5.5.h,
                                      // width: 104,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.transactionReqBorderWhole,
                              // border: Border(
                              //   bottom: BorderSide(
                              //     color: Colors.black, // Border color
                              //     width: 1.0, // Border width
                              //   ),
                              // ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.sp),
                                // Adjust the radius as needed
                                topRight: Radius.circular(15.sp),
                              )),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.sp, vertical: 20.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaction Details'.tr(),
                                  style: TextStyle(
                                      color: themeNotifier.isDark
                                          ? AppColors.textColorWhite
                                          : AppColors.textColorBlack,
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                                Divider(
                                  color: AppColors.transactionFeeBorder,
                                ),
                                SizedBox(
                                  height: 1.h,
                                ),
                                transactionDetailsWidget(
                                  title: 'Timestamp'.tr(),
                                  details: DateFormat('MMMM dd, yyyy')
                                      .format(unformatted),
                                  isDark: themeNotifier.isDark ? true : false,
                                ),
                                transactionDetailsWidget(
                                  title: 'Tx Type:'.tr(),
                                  details: capitalizeFirstLetter(operation),
                                  isDark: themeNotifier.isDark ? true : false,
                                ),
                                transactionDetailsWidget(
                                  title: operation == 'MintCollection' ||
                                          operation == 'listCollection' ||
                                          operation ==
                                              'listAuctionCollection' ||
                                          operation == 'burnCollection' ||
                                          operation == 'makeOfferCollection' ||
                                          operation == 'purchaseCollection' ||
                                          operation ==
                                              'acceptCollectionCounterOffer'
                                      ? 'Collection ID:'.tr()
                                      : 'Token ID:'.tr(),
                                  details: replaceMiddleWithDotsTokenId(
                                      paramsMap!['id'].toString()),
                                  isDark: themeNotifier.isDark ? true : false,
                                  color: AppColors.textColorToska,
                                ),
                                if (paramsMap!['Offeredby'] != null)
                                  transactionDetailsWidget(
                                    title: 'Offered by:'.tr(),
                                    details: 'N/A',
                                    isDark: themeNotifier.isDark ? true : false,
                                  ),
                                if (paramsMap!['creatorRoyaltyPercent'] != null)
                                  transactionDetailsWidget(
                                    title: 'Creator royalty:'.tr(),
                                    details: paramsMap!['creatorRoyaltyPercent']
                                            .toString() +
                                        '%',
                                    isDark: themeNotifier.isDark ? true : false,
                                  ),
                                if (paramsMap!['owner'] != null)
                                  transactionDetailsWidget(
                                    title: 'Owner:'.tr(),
                                    details: replaceMiddleWithDots(
                                            paramsMap!['owner'])
                                        .toString(),
                                    isDark: themeNotifier.isDark ? true : false,
                                  ),
                                if (paramsMap!['listedBy'] != null ||
                                    paramsMap!['creatorWalletAddress'] != null)
                                  transactionDetailsWidget(
                                    title: operation == 'listNFT' ||
                                            operation == 'listCollection' ||
                                            operation ==
                                                'listAuctionCollection' ||
                                            operation == 'listAuctionNFT'
                                        ? 'Listed By:'
                                        : 'Creator ID:'.tr(),
                                    details: replaceMiddleWithDots(
                                        operation == 'listNFT' ||
                                                operation == 'listCollection' ||
                                                operation ==
                                                    'listAuctionCollection' ||
                                                operation == 'listAuctionNFT'
                                            ? paramsMap!['listedBy'].toString()
                                            : paramsMap!['creatorWalletAddress']
                                                .toString()),
                                    isDark: themeNotifier.isDark ? true : false,
                                  ),
                                if (paramsMap!['offerAmount'] != null)
                                  transactionDetailsWidget(
                                    title: 'Counter Offer Amount:'.tr(),
                                    details:
                                        paramsMap!['offerAmount'].toString() +
                                            " SAR",
                                    isDark: themeNotifier.isDark ? true : false,
                                  ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.transactionFeeContainer,
                                    borderRadius: BorderRadius.circular(10.sp),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 13.sp,
                                        left: 13.sp,
                                        right: 13.sp,
                                        bottom: 7.sp),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // SizedBox(
                                        //   height: 4.h,
                                        // ),
                                        Text(
                                          'Transaction fees'.tr(),
                                          style: TextStyle(
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                              fontSize: 12.5.sp,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Divider(
                                          color: AppColors.textColorGrey,
                                        ),
                                        SizedBox(
                                          height: 1.h,
                                        ),
                                        // if (feesMap!['nftMintingFee'] != null)
                                        //   transactionFeesWidget(
                                        //     title: feesMap!['nftMintingFee']
                                        //     ['label']
                                        //         .toString(),
                                        //     details: feesMap!['nftMintingFee']
                                        //     ['value']
                                        //         .toString(),
                                        //     showCurrency: true,
                                        //     isDark: themeNotifier.isDark
                                        //         ? true
                                        //         : false,
                                        //   ),
                                        if (feesMap != null)
                                          ListView.builder(
                                            padding: EdgeInsets.zero,
                                            controller: scrollController,
                                            itemCount: feesMap!.length,
                                            shrinkWrap: true,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final feeKey = feesMap!.keys
                                                  .elementAt(
                                                      index); // Get the key at index
                                              final fee = feesMap![
                                                  feeKey]; // Get the fee object

                                              String feeLabel =
                                                  fee['label'].toString();
                                              String feeValue =
                                                  fee['value'].toString();
                                              bool isDebit =
                                                  fee['type'].toString() ==
                                                          'debit'
                                                      ? true
                                                      : false;
                                              bool lastIndex =
                                                  index == feesMap!.length - 1;
                                              feeLabel == 'Total'
                                                  ? Provider.of<TransactionProvider>(
                                                              context,
                                                              listen: false)
                                                          .totalForDialog =
                                                      formatCurrency(feeValue)
                                                  : '';
                                              return Column(
                                                children: [
                                                  if (lastIndex)
                                                    Divider(
                                                      color: AppColors
                                                          .textColorGrey,
                                                    ),
                                                  transactionFeesWidget(
                                                    title: feeLabel,
                                                    // details: isDebit ? '- '+ feeValue : '' + feeValue,
                                                    details: formatCurrency(
                                                        feeValue),
                                                    showCurrency: true,
                                                    isDark: themeNotifier.isDark
                                                        ? true
                                                        : false,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        Text(
                                          operation != "acceptCounterOffer" &&
                                                  operation !=
                                                      "acceptCollectionCounterOffer"
                                              ? 'The transaction request is automatically signed and submitted to the Blockchain once this transaction is paid.'.tr()
                                              : 'Your original offer amount will be fully refunded once the counter offer amount is confirmed.'.tr()
                                                  .tr(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.5.sp,
                                              color: operation !=
                                                          "acceptNFTCounterOffer" &&
                                                      operation !=
                                                          "acceptCollectionCounterOffer"
                                                  ? AppColors
                                                      .textColorGreyShade2
                                                  : AppColors
                                                      .activeButtonColor),
                                        ),
                                        SizedBox(
                                          height: 2.h,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 3.h,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Payments Types'.tr(),
                                          style: TextStyle(
                                              fontSize: 11.7.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack),
                                        ),
                                        Spacer(),
                                        GestureDetector(
                                          onTap: () async {
                                            confirmBrandDialogue(
                                              () async {},
                                              showPopup: true,
                                            );
                                            // confirmBrandDialogue(
                                            //   () async {
                                            //     var result = await Provider.of<
                                            //                 TransactionProvider>(
                                            //             context,
                                            //             listen: false)
                                            //         .tokenizeCardRequest(
                                            //             token: accessToken,
                                            //             brand: Provider.of<
                                            //                         TransactionProvider>(
                                            //                     context,
                                            //                     listen: false)
                                            //                 .selectedCardBrand,
                                            //             context: context);
                                            //     if (result ==
                                            //         AuthResult.success) {
                                            //       Navigator.push(
                                            //         context,
                                            //         MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               WalletAddCard(
                                            //             fromTransactionReq:
                                            //                 true,
                                            //             tokenizedCheckoutId: Provider
                                            //                     .of<TransactionProvider>(
                                            //                         context,
                                            //                         listen:
                                            //                             false)
                                            //                 .tokenizedCheckoutId,
                                            //           ),
                                            //         ),
                                            //       );
                                            //     }
                                            //   },
                                            //   showPopup: true,
                                            // );

                                            // return showDialog(
                                            //   context: context,
                                            //   builder: (BuildContext context) {
                                            //     final screenWidth =
                                            //         MediaQuery.of(context)
                                            //             .size
                                            //             .width;
                                            //     final dialogWidth =
                                            //         screenWidth * 0.85;
                                            //
                                            //     return StatefulBuilder(builder:
                                            //         (BuildContext context,
                                            //             StateSetter setState) {
                                            //       return Dialog(
                                            //         shape:
                                            //             RoundedRectangleBorder(
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   8.0),
                                            //         ),
                                            //         backgroundColor:
                                            //             Colors.transparent,
                                            //         child: BackdropFilter(
                                            //             filter:
                                            //                 ImageFilter.blur(
                                            //                     sigmaX: 7,
                                            //                     sigmaY: 7),
                                            //             child: Container(
                                            //               height: 35.h,
                                            //               width: dialogWidth,
                                            //               decoration:
                                            //                   BoxDecoration(
                                            //                 border: Border.all(
                                            //                     width: 0.1.h,
                                            //                     color: AppColors
                                            //                         .textColorGrey),
                                            //                 color: themeNotifier.isDark
                                            //                     ? AppColors
                                            //                         .showDialogClr
                                            //                     : AppColors
                                            //                         .textColorWhite,
                                            //                 borderRadius:
                                            //                     BorderRadius
                                            //                         .circular(
                                            //                             15),
                                            //               ),
                                            //               child: Column(
                                            //                 mainAxisAlignment:
                                            //                     MainAxisAlignment
                                            //                         .start,
                                            //                 children: [
                                            //                   SizedBox(
                                            //                     height: 4.h,
                                            //                   ),
                                            //                   Text(
                                            //                     "Enter card number \n to continue!",
                                            //                     textAlign:
                                            //                         TextAlign
                                            //                             .center,
                                            //                     // '2320   3000   0000   1234',
                                            //                     style: TextStyle(
                                            //                         fontSize:
                                            //                             13.sp,
                                            //                         color: AppColors
                                            //                             .whiteColorWithOpacity),
                                            //                   ),
                                            //                   SizedBox(
                                            //                       height: 4.h),
                                            //                   Padding(
                                            //                     padding: const EdgeInsets
                                            //                         .symmetric(
                                            //                         horizontal:
                                            //                             20),
                                            //                     child:
                                            //                         Container(
                                            //                       height: 6.5.h,
                                            //                       child: TextField(
                                            //                           maxLength: 16,
                                            //                           inputFormatters: [LengthLimitingTextInputFormatter(16)],
                                            //                           controller: _cardnumberController,
                                            //                           keyboardType: TextInputType.number,
                                            //                           scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 150),
                                            //                           style: TextStyle(
                                            //                               fontSize: 10.2.sp,
                                            //                               color: themeNotifier.isDark ? AppColors.textColorWhite : AppColors.textColorBlack,
                                            //                               fontWeight: FontWeight.w400,
                                            //                               // Off-white color,
                                            //                               fontFamily: 'Inter'),
                                            //                           decoration: InputDecoration(
                                            //                             contentPadding: EdgeInsets.symmetric(
                                            //                                 vertical:
                                            //                                     10.0,
                                            //                                 horizontal:
                                            //                                     16.0),
                                            //                             counterStyle: TextStyle(
                                            //                                 color:
                                            //                                     Colors.transparent,
                                            //                                 fontSize: 0),
                                            //                             hintText:
                                            //                                 'Enter card number'.tr(),
                                            //                             hintStyle: TextStyle(
                                            //                                 fontSize: 10.2.sp,
                                            //                                 color: AppColors.textColorGrey,
                                            //                                 fontWeight: FontWeight.w400,
                                            //                                 // Off-white color,
                                            //                                 fontFamily: 'Inter'),
                                            //                             enabledBorder: OutlineInputBorder(
                                            //                                 borderRadius: BorderRadius.circular(8.0),
                                            //                                 borderSide: BorderSide(
                                            //                                   color: AppColors.textColorGrey,
                                            //                                   // Off-white color
                                            //                                   width: 1.0,
                                            //                                 )),
                                            //                             focusedBorder: OutlineInputBorder(
                                            //                                 borderRadius: BorderRadius.circular(8.0),
                                            //                                 borderSide: BorderSide(
                                            //                                   color: AppColors.textColorGrey,
                                            //                                   // Off-white color
                                            //                                   width: 1.0,
                                            //                                 )),
                                            //                             // labelText: 'Enter your password',
                                            //                           ),
                                            //                           onChanged: (value) {
                                            //                             // Update the displayedText whenever the text changes
                                            //                             setState(
                                            //                                 () {
                                            //                               displayedText =
                                            //                                   value;
                                            //                             });
                                            //                           },
                                            //                           cursorColor: AppColors.textColorGrey),
                                            //                     ),
                                            //                   ),
                                            //                   Expanded(
                                            //                     child: SizedBox(
                                            //                         // height: 4.h,
                                            //                         ),
                                            //                   ),
                                            //                   Padding(
                                            //                     padding: EdgeInsets
                                            //                         .symmetric(
                                            //                             horizontal:
                                            //                                 20.sp),
                                            //                     child:
                                            //                         AppButton(
                                            //                       title:
                                            //                           'Add card'
                                            //                               .tr(),
                                            //                       isactive: _cardnumberController
                                            //                               .text
                                            //                               .isNotEmpty
                                            //                           ? true
                                            //                           : false,
                                            //                       handler:
                                            //                           () async {
                                            //                         setState(
                                            //                             () {
                                            //                           isLoading =
                                            //                               true;
                                            //                         });
                                            //                         final result = await Provider.of<TransactionProvider>(
                                            //                                 context,
                                            //                                 listen:
                                            //                                     false)
                                            //                             .tokenizeCardRequest(
                                            //                           token:
                                            //                               accessToken,
                                            //                           context:
                                            //                               context,
                                            //                           bin: _cardnumberController
                                            //                               .text,
                                            //                         );
                                            //                         setState(
                                            //                             () {
                                            //                           isLoading =
                                            //                               false;
                                            //                         });
                                            //                         if (result ==
                                            //                             AuthResult
                                            //                                 .success) {
                                            //                           print(Provider.of<TransactionProvider>(
                                            //                                   context,
                                            //                                   listen: false)
                                            //                               .tokenizedCheckoutId);
                                            //                         }
                                            //                       },
                                            //                       isLoading:
                                            //                           isLoading,
                                            //                       isGradient:
                                            //                           true,
                                            //                       color: Colors
                                            //                           .transparent,
                                            //                       // textColor: AppColors.textColorGreyShade2,
                                            //                     ),
                                            //                   ),
                                            //                   SizedBox(
                                            //                     height: 4.h,
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             )),
                                            //       );
                                            //     });
                                            //   },
                                            // );
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10.sp,
                                                height: 10.sp,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      color: AppColors
                                                          .textColorGreyShade2),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 10,
                                                  color: themeNotifier.isDark
                                                      ? AppColors
                                                          .textColorGreyShade2
                                                      : AppColors
                                                          .textColorBlack,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 1.w,
                                              ),
                                              Text(
                                                'Add new'.tr(),
                                                style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors
                                                        .textColorGreyShade2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 1.h,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      border: Border.all(
                                        color: _isSelected
                                            ? AppColors.transactionFeeBorder
                                            : Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isSelected = !_isSelected;
                                              Provider.of<TransactionProvider>(
                                                          context,
                                                          listen: false)
                                                      .selectedPaymentMethod =
                                                  "cards";
                                            });
                                          },
                                          child: Container(
                                            height: 6.5.h,
                                            decoration: BoxDecoration(
                                              color: AppColors
                                                  .transactionFeeContainer,
                                              border: Border.all(
                                                color: _isSelected
                                                    ? Colors.transparent
                                                    :
                                                    // themeNotifier.isDark
                                                    //         ?
                                                    Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? AppColors
                                                            .textColorGrey
                                                        // .selectedCardAndBankBorder // 12 June
                                                        : AppColors
                                                            .selectedCardAndBankBorder,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8.0),
                                                // Radius for top-left corner
                                                topRight: Radius.circular(8.0),
                                                bottomLeft: Radius.circular(
                                                    _isSelected ? 0.0 : 8.0),
                                                bottomRight: Radius.circular(
                                                    _isSelected
                                                        ? 0.0
                                                        : 8.0), // Radius for top-right corner
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10.sp, right: 5.sp),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // SizedBox(
                                                  //   width: 0.5.h,
                                                  // ),
                                                  Text(
                                                    // trPro.selectedCardNum ==
                                                    //             "" ||
                                                    //         trPro.selectedCardNum ==
                                                    //             null
                                                    paymentCards.isEmpty
                                                        ? "Add payment method".tr()
                                                        : trPro.selectedCardNum +
                                                            " **********",
                                                    // "2561 **** **** 1234",
                                                    style: TextStyle(
                                                        fontSize: 11.7.sp,
                                                        fontFamily: 'Inter',
                                                        fontWeight: paymentCards
                                                                .isEmpty
                                                            ? FontWeight.w700
                                                            : FontWeight.w700,
                                                        color: Provider.of<TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? AppColors
                                                                .textColorGrey //12 June
                                                            : AppColors
                                                                .selectedCardAndBankBorder
                                                        // color: themeNotifier
                                                        //     .isDark
                                                        //     ? AppColors
                                                        //     .textColorWhite
                                                        //     : AppColors
                                                        //     .textColorBlack
                                                        ),
                                                  ),

                                                  // SizedBox(
                                                  //   width: 0.5.h,
                                                  // ),
                                                  Spacer(),
                                                  // Image.asset(
                                                  //   "assets/images/Visa.png",
                                                  //   height: 20.sp,
                                                  //   color: themeNotifier.isDark
                                                  //       ? AppColors
                                                  //           .textColorWhite
                                                  //       : AppColors
                                                  //           .textColorBlack,
                                                  //   // width: 20.sp,
                                                  // ),
                                                  SizedBox(
                                                    width: 1.w,
                                                  ),
                                                  if (paymentCards.isEmpty)
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5.sp),
                                                      width: 12.sp,
                                                      height: 12.sp,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Colors.transparent,
                                                        border: Border.all(
                                                            color: AppColors
                                                                .textColorGreyShade2),
                                                      ),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 10.sp,
                                                        color: themeNotifier
                                                                .isDark
                                                            ? AppColors
                                                                .textColorGreyShade2
                                                            : AppColors
                                                                .textColorBlack,
                                                      ),
                                                    ),
                                                  if (paymentCards.isNotEmpty)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 0.sp),
                                                      child: Icon(
                                                        _isSelected
                                                            ? Icons
                                                                .keyboard_arrow_up
                                                            : Icons
                                                                .keyboard_arrow_down,
                                                        size: 28.sp,
                                                        color: themeNotifier
                                                                .isDark
                                                            ? AppColors
                                                                .textColorWhite
                                                            : AppColors
                                                                .textColorBlack,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_isSelected &&
                                            paymentCards.isNotEmpty)
                                          isCardLoading
                                              ? CircularProgressIndicator(
                                                  color:
                                                      AppColors.gradientColor1,
                                                )
                                              : Container(
                                                  child: ListView.builder(
                                                      controller:
                                                          scrollController,
                                                      itemCount:
                                                          paymentCards.length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (context, index) {
                                                        bool isFirst =
                                                            index == 0;

                                                        bool isLast = index ==
                                                            paymentCards
                                                                    .length -
                                                                1;

                                                        return GestureDetector(
                                                          onTap: () {
                                                            print(trPro
                                                                .selectedCardTokenId);
                                                            setState(() {
                                                              trPro.selectedCardNum =
                                                                  paymentCards[
                                                                          index]
                                                                      .bin;
                                                              trPro.selectedCardLast4Digits =
                                                                  paymentCards[
                                                                          index]
                                                                      .last4Digits;
                                                              trPro.selectedCardBrand =
                                                                  paymentCards[
                                                                          index]
                                                                      .cardBrand;
                                                              _isSelected =
                                                                  false;
                                                              trPro.selectedCardTokenId =
                                                                  paymentCards[
                                                                          index]
                                                                      .id;
                                                            });
                                                          },
                                                          child: paymentTypes(
                                                              isFirst: isFirst,
                                                              isDark:
                                                                  themeNotifier
                                                                          .isDark
                                                                      ? true
                                                                      : false,
                                                              index: index,
                                                              isLast: isLast,
                                                              cardNum:
                                                                  paymentCards[
                                                                          index]
                                                                      .bin,
                                                              isCardSelected: trPro
                                                                          .selectedCardNum ==
                                                                      paymentCards[
                                                                              index]
                                                                          .bin
                                                                  ? true
                                                                  : false),
                                                        );
                                                        // Card(
                                                        //   margin: EdgeInsets.all(8.0),
                                                        //   child: ListTile(
                                                        //     title: Text('Card ${index + 1}'),
                                                        //     subtitle: Text(
                                                        //       'BIN: ${paymentCards[index].bin}',
                                                        //       style: TextStyle(
                                                        //           color: Colors.red),
                                                        //     ),
                                                        //     onTap: () {
                                                        //       // Handle card tap if needed
                                                        //     },
                                                        //   ));
                                                      }),
                                                )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: OS.Platform.isIOS ? 2.h : 2.h),
                                if (OS.Platform.isIOS)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        Provider.of<TransactionProvider>(
                                                    context,
                                                    listen: false)
                                                .selectedPaymentMethod =
                                            "apple_pay";
                                      });
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: Container(
                                        height: 6.5.h,
                                        margin: EdgeInsets.only(bottom: 1.h),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: Provider.of<TransactionProvider>(
                                                            context,
                                                            listen: false)
                                                        .selectedPaymentMethod !=
                                                    "cards"
                                                ? AppColors
                                                    .selectedCardAndBankBorder
                                                :
                                                //12 June
                                                AppColors.transactionFeeBorder,
                                            // Off-white color
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.sp),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 1.w,
                                              ),
                                              Text(
                                                "Apple Pay".tr(),
                                                style: TextStyle(
                                                    fontSize: 11.7.sp,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    color: themeNotifier.isDark
                                                        ? AppColors
                                                            .textColorWhite
                                                        : AppColors
                                                            .textColorBlack),
                                              ),
                                              Spacer(),
                                              Image.asset(
                                                "assets/images/apple_logo.png",
                                                height: 15.sp,
                                                color: themeNotifier.isDark
                                                    ? AppColors.textColorWhite
                                                    : AppColors.textColorBlack,
                                                // width: 20.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                // SizedBox(
                                //   height: 3.h,
                                // ),
                                Container(
                                  decoration: BoxDecoration(
                                      // color: themeNotifier.isDark
                                      //     ? AppColors.transactionFeeContainer
                                      //     : AppColors.textColorWhite,
                                      // border: Border(
                                      //   top: BorderSide(
                                      //     color: AppColors.textColorGrey, // Border color
                                      //     width: 1.0, // Border width
                                      //   ),
                                      // ),
                                      ),
                                  // margin: EdgeInsets.symmetric(horizontal: 20.sp),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0.sp),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 2.5.h),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: Column(children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text:
                                                          'By continuing you agree to the'
                                                              .tr(),
                                                      style: TextStyle(
                                                          // height: 2,
                                                          color: AppColors
                                                              .textColorWhite,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 10.sp,
                                                          fontFamily: 'Inter')),
                                                  TextSpan(
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              // Navigator.push(
                                                              //   context,
                                                              //   MaterialPageRoute(
                                                              //       builder:
                                                              //           (context) =>
                                                              //               TermsAndConditions()),
                                                              // );
                                                            },
                                                      text: ' Terms & Conditions'
                                                              .tr() +
                                                          " ",
                                                      style: TextStyle(
                                                          // decoration:
                                                          //     TextDecoration
                                                          //         .underline,
                                                          height: 1.5,
                                                          color: AppColors
                                                              .textColorToska,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 10.sp,
                                                          fontFamily: 'Inter')),
                                                  TextSpan(
                                                      text:
                                                          '  of Hesa Wallet Payments.'
                                                              .tr(),
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .textColorWhite,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 10.sp,
                                                          fontFamily: 'Inter'))
                                                ],
                                              ),
                                            )
                                          ]),
                                        ),

                                        SizedBox(height: 1.5.h),
                                        AppButton(
                                          title: "Reject request".tr(),
                                          handler: () {
                                            // if(operation=="MintNFT"){
                                            rejectTransactions();
                                            // }
                                          },
                                          isGradient: false,
                                          isGradientWithBorder: true,
                                          buttonWithBorderColor:
                                              AppColors.errorColor,
                                          color: AppColors.deleteAccountBtnColor
                                              .withOpacity(0.10),
                                          textColor: themeNotifier.isDark
                                              ? AppColors.textColorWhite
                                              : AppColors.textColorBlack
                                                  .withOpacity(0.8),
                                          // color: AppColors.appSecondButton
                                          //     .withOpacity(0.10)
                                        ),
                                        SizedBox(height: 2.h),
                                        AppButton(
                                            title: "Pay".tr(),
                                            handler: () async {
                                              setState(() {
                                                isValidating = true;
                                              });

                                              setState(() {
                                                isLoading = true;
                                              });
                                              // var result;
                                              TransactionProvider
                                                  transactionProvider = Provider
                                                      .of<TransactionProvider>(
                                                          context,
                                                          listen: false);

                                              UserProvider userProvider =
                                                  Provider.of<UserProvider>(
                                                      context,
                                                      listen: false);

                                              confirmBrandDialogue(() async {
                                                if (operation ==
                                                    'MintCollection') {
                                                  print(
                                                      'running mint collection');
                                                  print(itemCollectionID);
                                                  final collectionResult =
                                                      await transactionProvider
                                                          .mintCollectionpayableTransactionSend(
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    country: country,
                                                    mintCollectionId:
                                                        itemCollectionID,
                                                    ownerId: userProvider
                                                        .walletAddress!,
                                                    params: params,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId.collection");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                                // "PAYPAL",
                                                                // "STC_PAY",
                                                                // "APPLEPAY"
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                  });
                                                } else if (operation ==
                                                    'MintNFT') {
                                                  // Uncomment this block if needed, adjust parameters accordingly
                                                  print('running mint nft');
                                                  final nftResult =
                                                      await transactionProvider
                                                          .mintNftpayableTransactionSend(
                                                              params: params,
                                                              token:
                                                                  accessToken,
                                                              context: context,
                                                              //12 june
                                                              brand: Provider.of<TransactionProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .selectedPaymentMethod !=
                                                                      "cards"
                                                                  ? 'APPLEPAY'
                                                                  : Provider.of<
                                                                              TransactionProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .selectedCardBrand,
                                                              walletAddress:
                                                                  userProvider
                                                                      .walletAddress!,
                                                              tokenId: paymentCards
                                                                      .isEmpty
                                                                  ? ""
                                                                  : trPro
                                                                      .selectedCardTokenId,
                                                              country: country,
                                                              operation:
                                                                  operation)
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'MintNFTWithEditions') {
                                                  final nftResult = await transactionProvider
                                                      .mintNFTWithEditions(
                                                          params: params,
                                                          token: accessToken,
                                                          context: context,
                                                          brand: Provider.of<TransactionProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .selectedPaymentMethod !=
                                                                  "cards"
                                                              ? 'APPLEPAY'
                                                              : Provider.of<
                                                                          TransactionProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .selectedCardBrand,
                                                          walletAddress:
                                                              userProvider
                                                                  .walletAddress!,
                                                          tokenId: paymentCards
                                                                  .isEmpty
                                                              ? ""
                                                              : trPro
                                                                  .selectedCardTokenId,
                                                          country: country,
                                                          operation: operation)
                                                      .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'purchaseNFT') {
                                                  final purchasenftResult = await transactionProvider
                                                      .purchaseNft(
                                                          params: params,
                                                          token: accessToken,
                                                          context: context,
                                                          brand: Provider.of<TransactionProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .selectedPaymentMethod !=
                                                                  "cards"
                                                              ? 'APPLEPAY'
                                                              : Provider.of<
                                                                          TransactionProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .selectedCardBrand,
                                                          walletAddress:
                                                              userProvider
                                                                  .walletAddress!,
                                                          tokenId: paymentCards
                                                                  .isEmpty
                                                              ? ""
                                                              : trPro
                                                                  .selectedCardTokenId,
                                                          country: country,
                                                          operation: operation)
                                                      .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'purchaseCollection') {
                                                  final purchaseCollectionResult = await transactionProvider
                                                      .purchaseCollection(
                                                          params: params,
                                                          token: accessToken,
                                                          context: context,
                                                          brand: Provider.of<TransactionProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .selectedPaymentMethod !=
                                                                  "cards"
                                                              ? 'APPLEPAY'
                                                              : Provider.of<
                                                                          TransactionProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .selectedCardBrand,
                                                          walletAddress:
                                                              userProvider
                                                                  .walletAddress!,
                                                          tokenId: paymentCards
                                                                  .isEmpty
                                                              ? ""
                                                              : trPro
                                                                  .selectedCardTokenId,
                                                          country: country,
                                                          operation: operation)
                                                      .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'listNFT') {
                                                  // Uncomment this block if needed, adjust parameters accordingly
                                                  final listNftFixedPrice =
                                                      await transactionProvider
                                                          .listNftFixedPrice(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'listCollection') {
                                                  // Uncomment this block if needed, adjust parameters accordingly
                                                  final listCollectionFixedPrice =
                                                      await transactionProvider
                                                          .listCollectionFixedPrice(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'listAuctionNFT') {
                                                  // Uncomment this block if needed, adjust parameters accordingly
                                                  final listNftForAuction =
                                                      await transactionProvider
                                                          .listNftForAuction(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'listAuctionCollection') {
                                                  // Uncomment this block if needed, adjust parameters accordingly
                                                  final listCollectionForAuction =
                                                      await transactionProvider
                                                          .listCollectionForAuction(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'burnNFT') {
                                                  // Uncomment this block if needed, adjust parameters accordingly
                                                  final burnNFT =
                                                      await transactionProvider
                                                          .burnNFT(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'burnCollection') {
                                                  // Uncomment this block if needed, adjust parameters accordingly
                                                  final burnCollection =
                                                      await transactionProvider
                                                          .burnCollection(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'makeOfferNFT') {
                                                  final makeOffer =
                                                      await transactionProvider
                                                          .makeOffer(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'makeOfferCollection') {
                                                  final makeOfferCollection =
                                                      await transactionProvider
                                                          .makeOfferCollection(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'acceptNFTCounterOffer') {
                                                  final acceptNFTCounterOffer =
                                                      await transactionProvider
                                                          .acceptCounterOffer(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else if (operation ==
                                                    'acceptCollectionCounterOffer') {
                                                  final acceptCollectionCounterOffer =
                                                      await transactionProvider
                                                          .acceptCollectionCounterOffer(
                                                    params: params,
                                                    token: accessToken,
                                                    context: context,
                                                    brand: Provider.of<TransactionProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .selectedPaymentMethod !=
                                                            "cards"
                                                        ? 'APPLEPAY'
                                                        : Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedCardBrand,
                                                    walletAddress: userProvider
                                                        .walletAddress!,
                                                    tokenId: paymentCards
                                                            .isEmpty
                                                        ? ""
                                                        : trPro
                                                            .selectedCardTokenId,
                                                    operation: operation,
                                                  )
                                                          .then((value) {
                                                    print(
                                                        "transactionProvider.checkoutId");
                                                    print(transactionProvider
                                                        .checkoutId);
                                                    payRequestNowReadyUI(
                                                        operation: operation,
                                                        brandsName: Provider.of<
                                                                            TransactionProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .selectedPaymentMethod !=
                                                                "cards"
                                                            ? ['APPLEPAY']
                                                            : [
                                                                "VISA",
                                                                "MASTER",
                                                                "MADA",
                                                              ],
                                                        checkoutId: Provider.of<
                                                                    TransactionProvider>(
                                                                context,
                                                                listen: false)
                                                            .checkoutId);
                                                    // });
                                                    // }
                                                  });
                                                } else {}
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              },
                                                  showPopup: Provider.of<
                                                                      UserProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .paymentCards
                                                              .isEmpty &&
                                                          Provider.of<TransactionProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .selectedPaymentMethod !=
                                                              "apple_pay"
                                                      ? true
                                                      : false
                                                  //
                                                  //         Provider.of<TransactionProvider>(
                                                  //             context,
                                                  //             listen:
                                                  //             false)
                                                  //             .selectedPaymentMethod !=
                                                  //             "cards")
                                                  // ||
                                                  //         Provider.of<TransactionProvider>(
                                                  //         context,
                                                  //         listen:
                                                  //         false)
                                                  //         .selectedPaymentMethod !=
                                                  //         "apple_pay"
                                                  );

                                              // if (result == AuthResult.success) {
                                              //   showDialog(
                                              //     context: context,
                                              //     builder: (BuildContext context) {
                                              //       final screenWidth =
                                              //           MediaQuery.of(context).size.width;
                                              //       final dialogWidth = screenWidth * 0.85;
                                              //       return StatefulBuilder(builder:
                                              //           (BuildContext context,
                                              //               StateSetter setState) {
                                              //         return Dialog(
                                              //           shape: RoundedRectangleBorder(
                                              //             borderRadius: BorderRadius.circular(8.0),
                                              //           ),
                                              //           backgroundColor: Colors.transparent,
                                              //           child: BackdropFilter(
                                              //               filter: ImageFilter.blur(
                                              //                   sigmaX: 7, sigmaY: 7),
                                              //               child: Container(
                                              //                 height: 55.h,
                                              //                 width: dialogWidth,
                                              //                 decoration: BoxDecoration(
                                              //
                                              //                   color: themeNotifier.isDark
                                              //                       ? AppColors.showDialogClr
                                              //                       : AppColors.textColorWhite,
                                              //                   borderRadius:
                                              //                       BorderRadius.circular(15),
                                              //                 ),
                                              //                 child: Column(
                                              //                   children: [
                                              //                     SizedBox(
                                              //                       height: 3.h,
                                              //                     ),
                                              //                     Align(
                                              //                       alignment:
                                              //                           Alignment.bottomCenter,
                                              //                       child: Image.asset(
                                              //                         "assets/images/svg_icon.png",
                                              //                         height: 5.9.h,
                                              //                         width: 5.6.h,
                                              //                       ),
                                              //                     ),
                                              //                     SizedBox(height: 2.h),
                                              //                     Text(
                                              //                       'OTP verification'.tr(),
                                              //                       style: TextStyle(
                                              //                           fontWeight: FontWeight.w600,
                                              //                           fontSize: 17.5.sp,
                                              //                           color: themeNotifier.isDark
                                              //                               ? AppColors
                                              //                                   .textColorWhite
                                              //                               : AppColors
                                              //                                   .textColorBlack),
                                              //                     ),
                                              //                     SizedBox(
                                              //                       height: 2.h,
                                              //                     ),
                                              //                     Row(
                                              //                       mainAxisAlignment:
                                              //                           MainAxisAlignment.center,
                                              //                       children: [
                                              //                         otpContainer(
                                              //                           controller: otp1Controller,
                                              //                           focusNode:
                                              //                               firstFieldFocusNode,
                                              //                           previousFocusNode:
                                              //                               firstFieldFocusNode,
                                              //                           handler: () => FocusScope
                                              //                                   .of(context)
                                              //                               .requestFocus(
                                              //                                   secondFieldFocusNode),
                                              //                         ),
                                              //                         SizedBox(
                                              //                           width: 1.h,
                                              //                         ),
                                              //                         otpContainer(
                                              //                           controller: otp2Controller,
                                              //                           focusNode:
                                              //                               secondFieldFocusNode,
                                              //                           previousFocusNode:
                                              //                               firstFieldFocusNode,
                                              //                           handler: () => FocusScope
                                              //                                   .of(context)
                                              //                               .requestFocus(
                                              //                                   thirdFieldFocusNode),
                                              //                         ),
                                              //                         SizedBox(
                                              //                           width: 1.h,
                                              //                         ),
                                              //                         otpContainer(
                                              //                           controller: otp3Controller,
                                              //                           focusNode:
                                              //                               thirdFieldFocusNode,
                                              //                           previousFocusNode:
                                              //                               secondFieldFocusNode,
                                              //                           handler: () => FocusScope
                                              //                                   .of(context)
                                              //                               .requestFocus(
                                              //                                   forthFieldFocusNode),
                                              //                         ),
                                              //                         SizedBox(
                                              //                           width: 1.h,
                                              //                         ),
                                              //                         otpContainer(
                                              //                           controller: otp4Controller,
                                              //                           focusNode:
                                              //                               forthFieldFocusNode,
                                              //                           previousFocusNode:
                                              //                               thirdFieldFocusNode,
                                              //                           handler: () => FocusScope
                                              //                                   .of(context)
                                              //                               .requestFocus(
                                              //                                   fifthFieldFocusNode),
                                              //                         ),
                                              //                         SizedBox(
                                              //                           width: 1.h,
                                              //                         ),
                                              //                         otpContainer(
                                              //                           controller: otp5Controller,
                                              //                           focusNode:
                                              //                               fifthFieldFocusNode,
                                              //                           previousFocusNode:
                                              //                               forthFieldFocusNode,
                                              //                           handler: () => FocusScope
                                              //                                   .of(context)
                                              //                               .requestFocus(
                                              //                                   sixthFieldFocusNode),
                                              //                         ),
                                              //                         SizedBox(
                                              //                           width: 1.h,
                                              //                         ),
                                              //                         otpContainer(
                                              //                           controller: otp6Controller,
                                              //                           focusNode:
                                              //                               sixthFieldFocusNode,
                                              //                           previousFocusNode:
                                              //                               fifthFieldFocusNode,
                                              //                           handler: () => null,
                                              //                         ),
                                              //                       ],
                                              //                     ),
                                              //                     SizedBox(
                                              //                       height: 1.h,
                                              //                     ),
                                              //                     Text(
                                              //                       '*Incorrect verification code'
                                              //                           .tr(),
                                              //                       style: TextStyle(
                                              //                           color: AppColors.errorColor,
                                              //                           fontSize: 10.2.sp,
                                              //                           fontWeight:
                                              //                               FontWeight.w400),
                                              //                     ),
                                              //                     SizedBox(
                                              //                       height: 2.h,
                                              //                     ),
                                              //                     Text(
                                              //                       'Please enter sms verification code sent to your mobile number'
                                              //                           .tr(),
                                              //                       textAlign: TextAlign.center,
                                              //                       style: TextStyle(
                                              //                           height: 1.4,
                                              //                           color:
                                              //                               AppColors.textColorGrey,
                                              //                           fontSize: 10.2.sp,
                                              //                           fontWeight:
                                              //                               FontWeight.w400),
                                              //                     ),
                                              //                     Expanded(child: SizedBox()),
                                              //                     Padding(
                                              //                       padding:
                                              //                           const EdgeInsets.symmetric(
                                              //                               horizontal: 22),
                                              //                       child: Consumer<UserProvider>(
                                              //                           builder:
                                              //                               (context, user, child) {
                                              //                         return AppButton(
                                              //                           title: 'Verify'.tr(),
                                              //                           handler: () async {
                                              //                             if (otp1Controller.text.isNotEmpty &&
                                              //                                 otp2Controller.text
                                              //                                     .isNotEmpty &&
                                              //                                 otp3Controller.text
                                              //                                     .isNotEmpty &&
                                              //                                 otp4Controller.text
                                              //                                     .isNotEmpty &&
                                              //                                 otp5Controller.text
                                              //                                     .isNotEmpty &&
                                              //                                 otp6Controller.text
                                              //                                     .isNotEmpty) {
                                              //                               setState(() {
                                              //                                 isLoading = true;
                                              //                               });
                                              //                               final result = await Provider.of<
                                              //                                           TransactionProvider>(
                                              //                                       context,
                                              //                                       listen: false)
                                              //                                   .nonPayableTransactionSend(
                                              //                                       token: accessToken,
                                              //                                       walletAddress: user
                                              //                                           .walletAddress!,
                                              //                                       code: otp1Controller.text +
                                              //                                           otp2Controller
                                              //                                               .text +
                                              //                                           otp3Controller
                                              //                                               .text +
                                              //                                           otp4Controller
                                              //                                               .text +
                                              //                                           otp5Controller
                                              //                                               .text +
                                              //                                           otp6Controller
                                              //                                               .text,
                                              //                                       context:
                                              //                                           context);
                                              //
                                              //                               setState(() {
                                              //                                 isLoading = false;
                                              //                               });
                                              //                               if (result ==
                                              //                                   AuthResult
                                              //                                       .success) {
                                              //                                 Navigator.push(
                                              //                                   context,
                                              //                                   MaterialPageRoute(
                                              //                                     builder: (context) =>
                                              //                                         TermsAndConditions(),
                                              //                                   ),
                                              //                                 );
                                              //                               }
                                              //                             }
                                              //                           },
                                              //                           isLoading: isLoading,
                                              //                           isGradient: true,
                                              //                           color: Colors.transparent,
                                              //                           textColor: AppColors
                                              //                               .textColorBlack,
                                              //                         );
                                              //                       }),
                                              //                     ),
                                              //                     SizedBox(height: 2.h),
                                              //                     Padding(
                                              //                       padding:
                                              //                           const EdgeInsets.symmetric(
                                              //                               horizontal: 22),
                                              //                       child: AppButton(
                                              //                           title: 'Resend code 06:00'
                                              //                               .tr(),
                                              //                           handler: () {
                                              //                             // Navigator.push(
                                              //                             //   context,
                                              //                             //   MaterialPageRoute(
                                              //                             //     builder: (context) => TermsAndConditions(),
                                              //                             //   ),
                                              //                             // );
                                              //                           },
                                              //                           isGradient: false,
                                              //                           textColor: themeNotifier
                                              //                                   .isDark
                                              //                               ? AppColors
                                              //                                   .textColorWhite
                                              //                               : AppColors
                                              //                                   .textColorBlack
                                              //                                   .withOpacity(0.8),
                                              //                           color: Colors.transparent),
                                              //                     ),
                                              //                     Expanded(child: SizedBox()),
                                              //                   ],
                                              //                 ),
                                              //               )),
                                              //         );
                                              //       });
                                              //     },
                                              //   );
                                              // }
                                            },
                                            // isLoading: isLoading,
                                            isGradient: true,
                                            color: AppColors.textColorBlack),

                                        // SizedBox(
                                        //   height: 3.h,
                                        // )
                                      ],
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   height: 10.h,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // )),
              ],
            ),
          ),
          if (isLoading)
            Positioned(
                top: 12.h,
                bottom: 0,
                left: 0,
                right: 0,
                child: LoaderBluredScreen())
        ],
      );
    });
  }

  Widget transactionDetailsWidget(
      {required String title,
      required String details,
      Color? color,
      bool isDark = true}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                color: isDark
                    ? AppColors.textColorWhite
                    : AppColors.textColorBlack,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500),
          ),
          Spacer(),
          Text(
            details,
            style: TextStyle(
                color: color == null ? AppColors.textColorGreyShade2 : color,
                fontSize: 11.sp,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget transactionFeesWidget({
    required String title,
    required String details,
    bool isDark = true,
    bool showCurrency = false,
    bool boldDetails = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // color: Colors.yellow,
            width: title == "Total" ? 25.w : 45.w,
            child: Text(
              title,
              style: TextStyle(
                  color: AppColors.textColorWhite,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(
            width: 5.sp,
          ),
          Container(
            // color: Colors.red,
            width: title == "Total" ? 45.w : 25.w,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                details != 'N/A' && showCurrency ? details + ' SAR' : details,
                style: TextStyle(
                    color: isDark
                        ? AppColors.textColorWhite
                        : AppColors.textColorBlack,
                    fontSize: 11.sp,
                    fontWeight:
                        boldDetails ? FontWeight.w800 : FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentCardWidget({bool isDark = true}) {
    return Container(
      height: 5.5.h,
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppColors.textColorGrey, // Off-white color
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 1.w,
            ),
            Text(
              "2561 **** **** 1234",
              style: TextStyle(
                  fontSize: 11.7.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppColors.textColorWhite
                      : AppColors.textColorBlack),
            ),
            Spacer(),
            Image.asset(
              "assets/images/Visa.png",
              height: 20.sp,
              // width: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentTypes(
      {bool isFirst = false,
      bool isLast = false,
      bool isDark = true,
      bool isCardSelected = false,
      required int index,
      required String cardNum}) {
    return Column(
      children: [
        if (isFirst)
          Divider(
            color: AppColors.paymentTypesBorder,
          ),
        Container(
          height: 5.5.h,
          decoration: BoxDecoration(
            // color: Colors.red,
            // border: Border.all(
            //   color:
            //   // _isSelected ? Colors.transparent :
            //   AppColors.textColorGrey,
            //   width: 1.0,
            // ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  cardNum + " ********** ",
                  style: TextStyle(
                      fontSize: 11.7.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      color: isCardSelected
                          ? AppColors.selectedCardAndBankBorder
                          : isDark
                              ? AppColors.textColorWhite
                              : AppColors.textColorBlack),
                ),
                if (isCardSelected)
                  Container(
                    margin: EdgeInsets.only(left: 2.w),
                    width: 2.h,
                    height: 2.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.activeButtonColor, width: 1.sp),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 10.sp,
                        color: AppColors.selectedCardAndBankBorder,
                      ),
                    ),
                  ),
                Spacer(),
                Image.asset(
                  // cardNum.startsWith('4',0) ?
                  "assets/images/Visa.png",
                  // "assets/images/master_card.png",

                  height: 20.sp,
                  color: isDark
                      ? AppColors.textColorWhite
                      : AppColors.textColorBlack,
                  // width: 20.sp,
                ),
                // SizedBox(
                //   width: 0.5.h,
                // ),
                SizedBox(
                  width: 2.w,
                ),
                GestureDetector(
                  onTap: () => showPopupCardRemove(
                    isDark: isDark,
                    cardNumber: " ********** " + cardNum,
                    index: index,
                  ),
                  // Provider.of<CardProvider>(context, listen: false)
                  // .deletePaymentCards(
                  //     token: accessToken, index: index, context: context),
                  child: Image.asset(
                    "assets/images/cancel.png",
                    height: 20.sp,
                    color: AppColors.textColorGrey,
                    // color: isDark
                    //     ? AppColors.textColorWhite
                    //     : AppColors.textColorBlack,
                    // width: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (!isLast)
          SizedBox(
            height: 1.h,
          ),
        // Divider(
        //   color: AppColors.textColorGrey,
        // ),
        if (isLast)
          SizedBox(
            height: 1.h,
          ),
      ],
    );
  }

  void confirmationRequestDialogue({bool isDark = true}) {
    // Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.90;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: 23.h,
                width: dialogWidth,
                decoration: BoxDecoration(
                  // border:
                  //     Border.all(width: 0.1.h, color: AppColors.textColorGrey),
                  color: isDark
                      ? AppColors.showDialogClr
                      : AppColors.textColorWhite,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textColorBlack.withOpacity(0.95),
                      offset: Offset(0, 0),
                      blurRadius: 10,
                      spreadRadius: 0.4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirmation sent'.tr(),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack,
                            fontWeight: FontWeight.w600,
                            fontSize: 17.5.sp,
                          ),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Container(
                          width: 2.h,
                          height: 2.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.activeButtonColor,
                                width: 1.sp),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 10.sp,
                              color: AppColors.activeButtonColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Column(children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: 'Tx ID:'.tr(),
                                style: TextStyle(
                                    // height: 2,
                                    color: AppColors.textColorWhite,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11.7.sp,
                                    fontFamily: 'Inter')),
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                                text: ' xyeafa...wrbqwurqw'.tr(),
                                style: TextStyle(
                                    // decoration: TextDecoration.underline,
                                    // height: 1.5,
                                    color: AppColors.textColorToska,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.7.sp,
                                    fontFamily: 'Inter')),
                          ],
                        ),
                      )
                    ]),
                    SizedBox(
                      height: 3.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28.sp),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Transaction is sent to blockchain for execution.'
                              .tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack,
                            fontWeight: FontWeight.w400,
                            fontSize: 10.2.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }

  void paymentSuccesfullDialogue({
    bool isDark = true,
    String amount = '',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.90;

        Future.delayed(Duration(seconds: 2), () async {
          await Navigator.of(context)
              .pushNamedAndRemoveUntil(
              'nfts-page', (Route d) => false,
              arguments: {}); // Close the dialog
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: 28.h,
                width: dialogWidth,
                decoration: BoxDecoration(
                  // border:
                  //     Border.all(width: 0.1.h, color: AppColors.textColorGrey),
                  color: isDark
                      ? AppColors.showDialogClr
                      : AppColors.textColorWhite,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textColorBlack.withOpacity(0.95),
                      offset: Offset(0, 0),
                      blurRadius: 10,
                      spreadRadius: 0.4,
                    ),
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(
                      //   height: 3.h,
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Payment Successful'.tr(),
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.5.sp,
                            ),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          Image.asset(
                            "assets/images/check_circle_white.png",
                            height: 16.sp,
                            width: 16.sp,
                            color: AppColors.textColorWhite,
                          ),
                          // Container(
                          //   width: 2.h,
                          //   height: 2.h,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(20),
                          //     border: Border.all(
                          //         color: AppColors.textColorWhite, width: 1.sp),
                          //   ),
                          //   child: Center(
                          //     child: Icon(
                          //       Icons.check_rounded,
                          //       size: 10.sp,
                          //       color: AppColors.textColorWhite,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        amount + ' SAR'.tr(),
                        style: TextStyle(
                          fontSize: 27.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.activeButtonColor,
                        ),
                      ),
                      SizedBox(
                        height: 1.5.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'You’ll receive a confirmation on your transaction shortly.'
                              .tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textColorGreyShade2,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      // RichText(
                      //   text: TextSpan(
                      //     children: [
                      //       TextSpan(
                      //           text:
                      //           'From:'.tr(),
                      //           style: TextStyle(
                      //             // height: 2,
                      //               color: AppColors.textColorWhite,
                      //               fontWeight: FontWeight.w400,
                      //               fontSize: 10.2.sp,
                      //               fontFamily: 'Inter')),
                      //       TextSpan(
                      //           recognizer: TapGestureRecognizer()
                      //             ..onTap = () {
                      //             },
                      //           text: ' https://neo-nftmarket.com'.tr(),
                      //           style: TextStyle(
                      //             // decoration: TextDecoration.underline,
                      //             // height: 1.5,
                      //               color: AppColors.textColorToska,
                      //               fontWeight: FontWeight.w400,
                      //               fontSize: 10.2.sp,
                      //               fontFamily: 'Inter')),
                      //     ],
                      //   ),
                      // ),
                    ]
                    // SizedBox(height: 3.5.h,),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //       horizontal: 20.sp),
                    //   child: Container(
                    //     height: 6.5.h,
                    //     margin:
                    //     EdgeInsets.only(bottom: 1.h),
                    //     decoration: BoxDecoration(
                    //       borderRadius:
                    //       BorderRadius.circular(8.0),
                    //       border: Border.all(
                    //         color: AppColors
                    //             .textColorGrey.withOpacity(0.50),
                    //         // Off-white color
                    //         width: 1.0,
                    //       ),
                    //     ),
                    //     child: Padding(
                    //       padding: EdgeInsets.symmetric(
                    //           horizontal: 10.sp),
                    //       child: Row(
                    //         mainAxisAlignment:
                    //         MainAxisAlignment.start,
                    //         crossAxisAlignment:
                    //         CrossAxisAlignment.center,
                    //         children: [
                    //           SizedBox(
                    //             width: 1.w,
                    //           ),
                    //           Text(
                    //             "Riyad Bank".tr(),
                    //             style: TextStyle(
                    //                 fontSize: 11.7.sp,
                    //                 fontFamily: 'Inter',
                    //                 fontWeight:
                    //                 FontWeight.w500,
                    //                 color:
                    //                 isDark
                    //                     ? AppColors
                    //                     .textColorWhite
                    //                     : AppColors
                    //                     .textColorBlack),
                    //           ),
                    //           Spacer(),
                    //           Text(
                    //             "**** 1234".tr(),
                    //             style: TextStyle(
                    //                 fontSize: 11.7.sp,
                    //                 fontFamily: 'Inter',
                    //                 fontWeight:
                    //                 FontWeight.w400,
                    //                 color:
                    //                     isDark
                    //                     ? AppColors
                    //                     .textColorWhite
                    //                     : AppColors
                    //                     .textColorBlack),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 2.h,),

                    ),
              )),
        );
      },
    );
  }

  void paymentFailedDialogue({bool isDark = true,  String amount = '',}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.90;

        Future.delayed(Duration(seconds: 2), () async {
          await Navigator.of(context)
              .pushNamedAndRemoveUntil(
              'nfts-page', (Route d) => false,
              arguments: {}); // Close the dialog
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: 30.h,
                width: dialogWidth,
                decoration: BoxDecoration(
                  // border:
                  //     Border.all(width: 0.1.h, color: AppColors.textColorGrey),
                  color: isDark
                      ? AppColors.showDialogClr
                      : AppColors.textColorWhite,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textColorBlack.withOpacity(0.95),
                      offset: Offset(0, 0),
                      blurRadius: 10,
                      spreadRadius: 0.4,
                    ),
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(
                      //   height: 3.h,
                      // ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Text(
                           'Payment Failed'.tr(),
                           style: TextStyle(
                             color: isDark
                                 ? AppColors.textColorWhite
                                 : AppColors.textColorBlack,
                             fontWeight: FontWeight.w600,
                             fontSize: 17.5.sp,
                           ),
                         ),
                       ],
                     ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        amount + ' SAR'.tr(),
                        style: TextStyle(
                          fontSize: 27.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.paymentFailedDialog,
                        ),
                      ),
                      SizedBox(
                        height: 1.5.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.sp),
                          child: Text(
                            'Your payment has failed, please try again.'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textColorGreyShade2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      // RichText(
                      //   text: TextSpan(
                      //     children: [
                      //       TextSpan(
                      //           text:
                      //           'From:'.tr(),
                      //           style: TextStyle(
                      //             // height: 2,
                      //               color: AppColors.textColorWhite,
                      //               fontWeight: FontWeight.w400,
                      //               fontSize: 10.2.sp,
                      //               fontFamily: 'Inter')),
                      //       TextSpan(
                      //           recognizer: TapGestureRecognizer()
                      //             ..onTap = () {
                      //             },
                      //           text: ' https://neo-nftmarket.com'.tr(),
                      //           style: TextStyle(
                      //             // decoration: TextDecoration.underline,
                      //             // height: 1.5,
                      //               color: AppColors.textColorToska,
                      //               fontWeight: FontWeight.w400,
                      //               fontSize: 10.2.sp,
                      //               fontFamily: 'Inter')),
                      //     ],
                      //   ),
                      // ),
                    ]
                    // SizedBox(height: 3.5.h,),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //       horizontal: 20.sp),
                    //   child: Container(
                    //     height: 6.5.h,
                    //     margin:
                    //     EdgeInsets.only(bottom: 1.h),
                    //     decoration: BoxDecoration(
                    //       borderRadius:
                    //       BorderRadius.circular(8.0),
                    //       border: Border.all(
                    //         color: AppColors
                    //             .textColorGrey.withOpacity(0.50),
                    //         // Off-white color
                    //         width: 1.0,
                    //       ),
                    //     ),
                    //     child: Padding(
                    //       padding: EdgeInsets.symmetric(
                    //           horizontal: 10.sp),
                    //       child: Row(
                    //         mainAxisAlignment:
                    //         MainAxisAlignment.start,
                    //         crossAxisAlignment:
                    //         CrossAxisAlignment.center,
                    //         children: [
                    //           SizedBox(
                    //             width: 1.w,
                    //           ),
                    //           Text(
                    //             "Riyad Bank".tr(),
                    //             style: TextStyle(
                    //                 fontSize: 11.7.sp,
                    //                 fontFamily: 'Inter',
                    //                 fontWeight:
                    //                 FontWeight.w500,
                    //                 color:
                    //                 isDark
                    //                     ? AppColors
                    //                     .textColorWhite
                    //                     : AppColors
                    //                     .textColorBlack),
                    //           ),
                    //           Spacer(),
                    //           Text(
                    //             "**** 1234".tr(),
                    //             style: TextStyle(
                    //                 fontSize: 11.7.sp,
                    //                 fontFamily: 'Inter',
                    //                 fontWeight:
                    //                 FontWeight.w400,
                    //                 color:
                    //                     isDark
                    //                     ? AppColors
                    //                     .textColorWhite
                    //                     : AppColors
                    //                     .textColorBlack),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 2.h,),

                    ),
              )),
        );
      },
    );
  }

  void transactionFailed({bool isDark = true,  String amount = '',}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.90;

        Future.delayed(Duration(seconds: 2), () async {
          await Navigator.of(context)
              .pushNamedAndRemoveUntil(
              'nfts-page', (Route d) => false,
              arguments: {}); // Close the dialog
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: 18.h,
                width: dialogWidth,
                decoration: BoxDecoration(
                  // border:
                  //     Border.all(width: 0.1.h, color: AppColors.textColorGrey),
                  color: isDark
                      ? AppColors.showDialogClr
                      : AppColors.textColorWhite,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textColorBlack.withOpacity(0.95),
                      offset: Offset(0, 0),
                      blurRadius: 10,
                      spreadRadius: 0.4,
                    ),
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(
                      //   height: 3.h,
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Transaction failed'.tr(),
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.paymentFailedDialog
                                  : AppColors.paymentFailedDialog,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.5.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.sp),
                          child: Text(
                            'Something went wrong, please try again.'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textColorGreyShade2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ]

                ),
              )),
        );
      },
    );
  }

  Future showPopupCardRemove({
    required bool isDark,
    required String cardNumber,
    required int index,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.85;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Colors.transparent,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    height: 43.h,
                    width: dialogWidth,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.showDialogClr
                          : AppColors.textColorWhite,
                      // border: Border.all(
                      //     width: 0.1.h, color: AppColors.textColorGrey),
                      // color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textColorBlack.withOpacity(0.95),
                          offset: Offset(0, 0),
                          blurRadius: 10,
                          spreadRadius: 0.4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Are you sure you want to remove this Card?'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.sp),
                          height: 6.5.h,
                          decoration: BoxDecoration(
                            color: AppColors.textColorWhite.withOpacity(0.15),
                            // border: Border.all(
                            //   color: AppColors.textFieldParentDark,
                            //   width: 1.0,
                            // ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Spacer(),
                                Text(
                                  cardNumber,
                                  // "**** 1234",
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.textColorWhite
                                        : AppColors.textColorBlack,
                                  ),
                                ),
                                SizedBox(
                                  width: 2.w,
                                ),
                                Image.asset(
                                  "assets/images/Visa.png",
                                  height: 18.sp,
                                  color: isDark
                                      ? AppColors.textColorWhite
                                      : AppColors.textColorBlack,
                                  // width: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: AppButton(
                            title: 'Remove'.tr(),
                            handler: () async {
                              setState(() {
                                isDialogLoading = true;
                              });
                              var result = await Provider.of<CardProvider>(
                                      context,
                                      listen: false)
                                  .deletePaymentCards(
                                      token: accessToken,
                                      tokenId: Provider.of<TransactionProvider>(
                                              context,
                                              listen: false)
                                          .selectedCardTokenId,
                                      context: context);
                              setState(() {
                                isDialogLoading = false;
                              });
                              if (result == AuthResult.success) {
                                Navigator.pop(context);
                                // Navigator.pop(context);
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (BuildContext context) {
                                //       return TransactionRequest(); // Replace NewScreen() with the widget for your new screen
                                //     },
                                //   ),
                                // );
                              }
                            },
                            isLoading: isDialogLoading,
                            isGradient: true,
                            // color: Colors.transparent,
                            color: AppColors.appSecondButton.withOpacity(0.10),
                            textColor: AppColors.textColorBlack,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: AppButton(
                              title: 'Cancel'.tr(),
                              handler: () {
                                Navigator.pop(context);
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => TermsAndConditions(),
                                //   ),
                                // );
                              },
                              isGradient: false,
                              textColor: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack.withOpacity(0.8),
                              color:
                                  AppColors.appSecondButton.withOpacity(0.10)),
                        ),
                        Expanded(child: SizedBox())
                      ],
                    ),
                  )));
        });
      },
    );
  }
}
