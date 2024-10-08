import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/constants/colors.dart';
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
import '../../providers/bank_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';
import '../userpayment_and_bankingpages/wallet_add_bank.dart';
import '../userpayment_and_bankingpages/wallet_add_card.dart';

class TransactionRequestAcceptReject extends StatefulWidget {
  static const routeName = 'transactionRequestAcceptReject';

  const TransactionRequestAcceptReject({Key? key}) : super(key: key);

  @override
  State<TransactionRequestAcceptReject> createState() =>
      _TransactionRequestAcceptRejectState();
}

class _TransactionRequestAcceptRejectState
    extends State<TransactionRequestAcceptReject> {
  bool _isSelected = false;
  var _selectedBankDetails = false;
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
  var isValidating = false;
  var setThemeDark = true;
  var unformatted = DateTime.now();
  var wstoken = "";
  var accessToken = "";
  bool isOtpButtonActive = false;
  bool _isTimerActive = false;
  var _isLoadingResend = false;
  Timer? _timer;
  int _timeLeft = 60;
  late StreamController<int> _events;
  var params;
  var fees = "";
  Map<String, dynamic>? feesMap;
  Map<String, dynamic>? paramsMap;
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
  var counterId;
  var counterOffererId;
  var counterOffererAmount;

  late FlutterHyperPay flutterHyperPay;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
    print(accessToken);
  }

  init() async {
    await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
  }

  // Future<String?> getCheckOut() async {
  //   final url = Uri.parse('https://dev.hyperpay.com/hyperpay-demo/getcheckoutid.php');
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     dev.log(json.decode(response.body)['id'].toString(), name: "checkoutId");
  //     print('successful response');
  //     print(json.decode(response.body));
  //     return json.decode(response.body)['id'];
  //   }else{
  //     dev.log(response.body.toString(), name: "STATUS CODE ERROR");
  //     return null;
  //   }
  // }

  // void payRequestNowReadyUI(
  //     {required List<String> brandsName, required String checkoutId}) async {
  //   try {
  //     PaymentResultData paymentResultData;
  //     paymentResultData = await flutterHyperPay.readyUICards(
  //       readyUI: ReadyUI(
  //         brandsName: brandsName,
  //         checkoutId: checkoutId,
  //         // checkoutId: checkoutId,
  //         merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
  //         countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
  //         companyNameApplePayIOS: "Test Co",
  //         themColorHexIOS: "#000000",
  //         // FOR IOS ONLY
  //         setStorePaymentDetailsMode:
  //             true, // store payment details for future use
  //       ),
  //     );
  //     print("paymentResultData.paymentResult=");
  //     print(paymentResultData.paymentResult);
  //     if (paymentResultData.paymentResult == PaymentResult.success ||
  //         paymentResultData.paymentResult == PaymentResult.sync) {
  //       Provider.of<TransactionProvider>(context, listen: false).payableTransactionProcess(token: accessToken,
  //           paymentId: paymentResultData.paymentResult.toString()
  //           //         Provider.of<TransactionProvider>(context, listen: false)
  //           //             .checkoutId
  //           , context: context);
  //       // InAppPaymentSetting.getShopperResultUrl(
  //       //     Provider.of<TransactionProvider>(context, listen: false)
  //       //         .checkoutId);
  //       print('Payment successful');
  //       print('ye response ${paymentResultData}');
  //       // Handle success
  //     } else {
  //       print('Payment failed');
  //       // Handle failure
  //       print('Failure Reason: ${paymentResultData.errorString}');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   }
  // }

  void startTimer() {
    // Cancel the previous timer if it's active
    _timer?.cancel();
    _timeLeft = 60;
    _isTimerActive = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
      }
      print(_timeLeft);
      _events.add(_timeLeft);
    });
  }

  void _updateOtpButtonState() {
    setState(() {
      isOtpButtonActive = otp1Controller.text.isNotEmpty &&
          otp2Controller.text.isNotEmpty &&
          otp3Controller.text.isNotEmpty &&
          otp4Controller.text.isNotEmpty &&
          otp5Controller.text.isNotEmpty &&
          otp6Controller.text.isNotEmpty;
    });
  }

  Future<void> getpaymentstatus(String checkoutid) async {
    var status;

    Uri myUrl = Uri.parse(
        'https://dev.hyperpay.com/hyperpay-demo/getpaymentstatus.php?id=$checkoutid');
    final response = await http.post(
      myUrl,
      headers: {'Accept': 'application/json'},
    );
    status = response.body.contains('error');

    var data = json.decode(response.body);

    print("payment_status: ${data["result"].toString()}");

    // setState(() {
    //   _resultText = data["result"].toString();
    // });
  }

  void payRequestNowReadyUI(
      {required List<String> brandsName, required String checkoutId}) async {
    PaymentResultData paymentResultData;
    paymentResultData = await flutterHyperPay.readyUICards(
      readyUI: ReadyUI(
        brandsName: brandsName,
        // checkoutId: checkoutId,
        checkoutId: 'D58564B5E402CF1DC6E8981CC6E87FC9.uat01-vm-tx02',
        merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
        countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
        companyNameApplePayIOS: "Test Co",
        themColorHexIOS: "#000000",
        // FOR IOS ONLY
        setStorePaymentDetailsMode: true, // default
      ),
    );
    if (paymentResultData.paymentResult == PaymentResult.success ||
        paymentResultData.paymentResult == PaymentResult.sync) {
      Provider.of<TransactionProvider>(context, listen: false)
          .payableTransactionProcess(
              token: accessToken, paymentId: checkoutId, context: context);
      print('testing payment');
      print(paymentResultData);
      getpaymentstatus(checkoutId);
    } else {
      print('it is not running');
      _showToast('Pay'
          'ment Failed');
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
    //   paymentRecievedDialogue(isDark: setThemeDark);  }
    // );

    init();
    _events = new StreamController<int>();
    _events.add(60);
    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);
    fToast = FToast();
    fToast.init(context);
    flutterHyperPay = FlutterHyperPay(
      shopperResultUrl:
          // getShopperResultUrl(
          //     Provider.of<TransactionProvider>(context, listen: false).checkoutId
          // ),
          // "http://161.35.16.112:3001/payable-transactions/process?paymentId=" + Provider.of<TransactionProvider>(context, listen: false).checkoutId,
          // InAppPaymentSetting.getShopperResultUrl(''),
          InAppPaymentSetting.shopperResultUrl,
      paymentMode: PaymentMode.test,
      lang: 'eng',
    );
    super.initState();
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
    // If the input length is less than or equal to 30, return it as is
    if (input.length <= 65) {
      return input;
    }

    final int middleIndex = input.length ~/ 2; // Find the middle index
    final int startIndex = middleIndex - 32; // Calculate the start index
    final int endIndex = middleIndex + 32; // Calculate the end index

    // Split the input string into two parts, removing the middle 30 characters and adding '....'
    final String result =
        input.substring(0, startIndex) + '....' + input.substring(endIndex);

    return result;
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  //rejectFuncTosendmuamil
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
    });
  }

  String formatCurrency(String? numberString) {
    // Check if the string is null or empty
    if (numberString == null || numberString.isEmpty) {
      return "0"; // Return a default value if input is invalid
    }

    try {
      // Convert the string to a number (num handles both int and double)
      num number = num.parse(numberString);

      // Create a NumberFormat object for Saudi currency style
      final formatter = NumberFormat("#,##0.##", "en_US");

      // Format the number with commas
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
      // Your code here
      print('args params' + args['params']);
      params = args['params'] ?? "N/A";
      paramsMap = jsonDecode(params);
      fees = args['fees'] ?? "N/A";
      feesMap = fees != "" ? jsonDecode(fees) : null;
      counterId = args['id'] ?? "N/A";
      counterOffererId = args['offererId'].toString() ?? "N/A";
      counterOffererAmount = args['offerAmount'] ?? "N/A";
      operation = args['operation'] ?? "N/A";
      walletAddress = args['walletAddress'] ?? "N/A";
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
    final banks = Provider.of<UserProvider>(context, listen: false).banks;
    final bankpro = Provider.of<BankProvider>(context, listen: false);
    final formattedText = addSpacesToText(displayedText);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      setThemeDark = themeNotifier.isDark;
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MainHeader(
                      title: "Transaction Request".tr(),
                    ),
                    // SizedBox(
                    //   height: 3.h,
                    // ),
                    isCardLoading
                        ? Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Center(
                                child: CircularProgressIndicator(
                              color: AppColors.activeButtonColor,
                            )),
                          )
                        : Expanded(
                            child: Container(
                              // color: Colors.red,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                child: Container(
                                  height: 73.5.h,
                                  decoration: BoxDecoration(
                                      // color: AppColors
                                      //      .errorColor,
                                      //     .transactionReqBorderWhole,
                                      // borderRadius: BorderRadius.only(
                                      //   topLeft: Radius.circular(15.sp),
                                      //   // Adjust the radius as needed
                                      //   topRight: Radius.circular(15.sp),
                                      // )
                                      ),
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 3.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.sp),
                                          child: Container(
                                            height: 10.6.h,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: AppColors.showDialogClr,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              // border: Border.all(
                                              //     color: AppColors.transactionSummNeoBorder,
                                              //     width: 1)
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Row(
                                                mainAxisAlignment: isEnglish
                                                    ? MainAxisAlignment.start
                                                    : MainAxisAlignment.end,
                                                children: [
                                                  if (currentLocale
                                                          .languageCode ==
                                                      'en')
                                                    Image.asset(
                                                      "assets/images/neo.png",
                                                      height: 5.5.h,
                                                      // width: 104,
                                                    ),
                                                  SizedBox(
                                                    width: 4.w,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        isEnglish
                                                            ? CrossAxisAlignment
                                                                .start
                                                            : CrossAxisAlignment
                                                                .end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'From:'.tr(),
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .textColorGrey,
                                                            fontSize: 8.5.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      SizedBox(
                                                        height: 3.sp,
                                                      ),
                                                      Text(
                                                        'https://neo-nft.com',
                                                        style: TextStyle(
                                                            color: themeNotifier.isDark
                                                                ? AppColors
                                                                    .textColorToska
                                                                : AppColors
                                                                    .textColorBlack,
                                                            fontSize: 10.5.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ],
                                                  ),
                                                  if (currentLocale
                                                          .languageCode ==
                                                      'ar')
                                                    SizedBox(
                                                      width: 15,
                                                    ),
                                                  if (currentLocale
                                                          .languageCode ==
                                                      'ar')
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
                                          height: operation ==
                                                      'AcceptNFTOfferReceived' ||
                                                  operation ==
                                                      'AcceptCollectionOffer'
                                              ? null
                                              : 75.h,
                                          decoration: BoxDecoration(
                                              color: AppColors
                                                  // .greenBorderClr,
                                                  .transactionReqBorderWhole,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15.sp),
                                                // Adjust the radius as needed
                                                topRight:
                                                    Radius.circular(15.sp),
                                              )),
                                          // color:
                                          // Colors.green,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25.sp,
                                                vertical: 20.sp),
                                            child: SingleChildScrollView(
                                              controller: scrollController,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Transaction Details'.tr(),
                                                    style: TextStyle(
                                                        color: themeNotifier
                                                                .isDark
                                                            ? AppColors
                                                                .textColorWhite
                                                            : AppColors
                                                                .textColorBlack,
                                                        fontSize: 12.5.sp,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Divider(
                                                    color: AppColors
                                                        .transactionFeeBorder,
                                                  ),
                                                  SizedBox(
                                                    height: 1.h,
                                                  ),
                                                  transactionDetailsWidget(
                                                    title: 'Timestamp:'.tr(),
                                                    details: DateFormat(
                                                            'MMMM dd, yyyy')
                                                        .format(unformatted),
                                                    isDark: themeNotifier.isDark
                                                        ? true
                                                        : false,
                                                  ),
                                                  transactionDetailsWidget(
                                                    title: 'Tx Type:'.tr(),
                                                    details:
                                                        capitalizeFirstLetter(
                                                            operation),
                                                    isDark: themeNotifier.isDark
                                                        ? true
                                                        : false,
                                                  ),
                                                  transactionDetailsWidget(
                                                    title: operation ==
                                                                'makeCollectionCounterOffer' ||
                                                            operation ==
                                                                'AcceptCollectionOffer' ||
                                                            operation ==
                                                                'rejectCollectionCounterOffer' ||
                                                            operation ==
                                                                'CancelCollectionAuctionListing' ||
                                                            operation ==
                                                                'CancelCollectionListing' ||
                                                            operation ==
                                                                'CancelCollectionOfferMade'
                                                        ? 'Collection ID:'.tr()
                                                        : 'Token ID:'.tr(),
                                                    details:
                                                        replaceMiddleWithDotsTokenId(
                                                            paramsMap!['id']
                                                                .toString()),
                                                    isDark: themeNotifier.isDark
                                                        ? true
                                                        : false,
                                                    color: AppColors
                                                        .textColorToska,
                                                  ),
                                                  if (paramsMap!['offererId'] !=
                                                          null ||
                                                      paramsMap![
                                                              'Creator ID'] !=
                                                          null)
                                                    transactionDetailsWidget(
                                                      title: operation ==
                                                                  'makeNFTCounterOffer' ||
                                                              operation ==
                                                                  'rejectNFTCounterOffer' ||
                                                              operation ==
                                                                  'makeCollectionCounterOffer' ||
                                                              operation ==
                                                                  'AcceptNFTOfferReceived' ||
                                                              operation ==
                                                                  'AcceptCollectionOffer' ||
                                                              operation ==
                                                                  'rejectNFTOfferReceived' ||
                                                              operation ==
                                                                  'rejectCollectionOfferReceived' ||
                                                              operation ==
                                                                  'rejectCollectionCounterOffer' ||
                                                              operation ==
                                                                  'CancelNFTOfferMade' ||
                                                              operation ==
                                                                  'CancelCollectionOfferMade'
                                                          ? 'Offerer ID:'
                                                          : 'Creator ID:'.tr(),
                                                      details: replaceMiddleWithDots(operation ==
                                                                  'makeNFTCounterOffer' ||
                                                              operation ==
                                                                  'makeCollectionCounterOffer' ||
                                                              operation ==
                                                                  'rejectNFTCounterOffer' ||
                                                              operation ==
                                                                  'AcceptNFTOfferReceived' ||
                                                              operation ==
                                                                  'AcceptCollectionOffer' ||
                                                              operation ==
                                                                  'rejectNFTOfferReceived' ||
                                                              operation ==
                                                                  'rejectCollectionOfferReceived' ||
                                                              operation ==
                                                                  'rejectCollectionCounterOffer' ||
                                                              operation ==
                                                                  'CancelNFTOfferMade' ||
                                                              operation ==
                                                                  'CancelCollectionOfferMade'
                                                          ? paramsMap![
                                                                  'offererId']
                                                              .toString()
                                                          : paramsMap![
                                                                  'creatorWalletAddress']
                                                              .toString()),
                                                      isDark:
                                                          themeNotifier.isDark
                                                              ? true
                                                              : false,
                                                    ),
                                                  if (paramsMap![
                                                          'offerAmount'] !=
                                                      null)
                                                    transactionDetailsWidget(
                                                      title: operation !=
                                                                  "AcceptNFTOfferReceived" &&
                                                              operation !=
                                                                  "AcceptCollectionOffer" &&
                                                              operation !=
                                                                  "rejectNFTOfferReceived" &&
                                                              operation !=
                                                                  "rejectCollectionOfferReceived"
                                                          ? 'Counter Offer Amount:'
                                                              .tr()
                                                          : 'Offer Amount:'
                                                              .tr(),
                                                      details: paramsMap![
                                                                  'offerAmount']
                                                              .toString() +
                                                          " SAR",
                                                      isDark:
                                                          themeNotifier.isDark
                                                              ? true
                                                              : false,
                                                    ),
                                                  SizedBox(
                                                    height: 2.h,
                                                  ),
                                                  if (operation != "makeNFTCounterOffer" &&
                                                      operation !=
                                                          "makeCollectionCounterOffer" &&
                                                      operation !=
                                                          "rejectNFTOfferReceived" &&
                                                      operation !=
                                                          "rejectCollectionOfferReceived" &&
                                                      operation !=
                                                          "rejectNFTCounterOffer" &&
                                                      operation !=
                                                          "rejectCollectionCounterOffer" &&
                                                      operation !=
                                                          "CancelAuctionListing" &&
                                                      operation !=
                                                          "CancelCollectionAuctionListing" &&
                                                      operation !=
                                                          "CancelListing" &&
                                                      operation !=
                                                          "CancelCollectionListing" &&
                                                      operation !=
                                                          "CancelNFTOfferMade" &&
                                                      operation !=
                                                          "CancelCollectionOfferMade")
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .transactionFeeContainer,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    10.sp),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 13.sp,
                                                                left: 13.sp,
                                                                right: 13.sp,
                                                                bottom: 7.sp),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // SizedBox(
                                                            //   height: 4.h,
                                                            // ),
                                                            Text(
                                                              'Transaction fees'
                                                                  .tr(),
                                                              style: TextStyle(
                                                                  color: themeNotifier.isDark
                                                                      ? AppColors
                                                                          .textColorWhite
                                                                      : AppColors
                                                                          .textColorBlack,
                                                                  fontSize:
                                                                      12.5.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            Divider(
                                                              color: AppColors
                                                                  .textColorGrey,
                                                            ),
                                                            SizedBox(
                                                              height: 1.h,
                                                            ),
                                                            if (feesMap![
                                                                    'offerAmount'] !=
                                                                null)
                                                              transactionFeesWidget(
                                                                title: feesMap![
                                                                            'offerAmount']
                                                                        [
                                                                        'label']
                                                                    .toString(),
                                                                details:
                                                                    formatCurrency(
                                                                  feesMap!['offerAmount']
                                                                          [
                                                                          'value']
                                                                      .toString(),
                                                                ),
                                                                showCurrency:
                                                                    true,
                                                                isDark:
                                                                    themeNotifier
                                                                            .isDark
                                                                        ? true
                                                                        : false,
                                                              ),
                                                            if (feesMap![
                                                                    'saleCommission'] !=
                                                                null)
                                                              transactionFeesWidget(
                                                                title: feesMap![
                                                                            'saleCommission']
                                                                        [
                                                                        'label']
                                                                    .toString(),
                                                                details:
                                                                    formatCurrency(
                                                                  feesMap!['saleCommission']
                                                                          [
                                                                          'value']
                                                                      .toString(),
                                                                ),
                                                                showCurrency:
                                                                    true,
                                                                isDark:
                                                                    themeNotifier
                                                                            .isDark
                                                                        ? true
                                                                        : false,
                                                              ),
                                                            if (feesMap![
                                                                    'creatorRoyalty'] !=
                                                                null)
                                                              transactionFeesWidget(
                                                                title: feesMap![
                                                                            'creatorRoyalty']
                                                                        [
                                                                        'label']
                                                                    .toString(),
                                                                details:
                                                                    formatCurrency(
                                                                  feesMap!['creatorRoyalty']
                                                                          [
                                                                          'value']
                                                                      .toString(),
                                                                ),
                                                                showCurrency:
                                                                    true,
                                                                isDark:
                                                                    themeNotifier
                                                                            .isDark
                                                                        ? true
                                                                        : false,
                                                              ),
                                                            if (feesMap![
                                                                    'networkFees'] !=
                                                                null)
                                                              transactionFeesWidget(
                                                                title: feesMap![
                                                                            'networkFees']
                                                                        [
                                                                        'label']
                                                                    .toString(),
                                                                details:
                                                                    formatCurrency(
                                                                  feesMap!['networkFees']
                                                                          [
                                                                          'value']
                                                                      .toString(),
                                                                ),
                                                                showCurrency:
                                                                    true,
                                                                isDark:
                                                                    themeNotifier
                                                                            .isDark
                                                                        ? true
                                                                        : false,
                                                              ),
                                                            if (feesMap![
                                                                    'total'] !=
                                                                null)
                                                              Column(children: [
                                                                Divider(
                                                                  color: AppColors
                                                                      .textColorGrey,
                                                                ),
                                                                transactionFeesWidget(
                                                                  title: feesMap![
                                                                              'total']
                                                                          [
                                                                          'label']
                                                                      .toString(),
                                                                  details:
                                                                      formatCurrency(
                                                                    feesMap!['total']
                                                                            [
                                                                            'value']
                                                                        .toString(),
                                                                  ),
                                                                  showCurrency:
                                                                      true,
                                                                  isDark: themeNotifier
                                                                          .isDark
                                                                      ? true
                                                                      : false,
                                                                ),
                                                              ]),
                                                            SizedBox(
                                                              height: 1.h,
                                                            ),
                                                            Text(
                                                              'The transaction request is automatically signed and submitted to the Blockchain once you have accepted this transaction.'
                                                                  .tr(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize:
                                                                      10.5.sp,
                                                                  color: AppColors
                                                                      .textColorGreyShade2),
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
                                                  if (operation != "makeNFTCounterOffer" &&
                                                      operation !=
                                                          "makeCollectionCounterOffer" &&
                                                      operation !=
                                                          "rejectNFTCounterOffer" &&
                                                      operation !=
                                                          "rejectCollectionCounterOffer" &&
                                                      operation !=
                                                          "rejectNFTOfferReceived" &&
                                                      operation !=
                                                          "rejectCollectionOfferReceived" &&
                                                      operation !=
                                                          "CancelAuctionListing" &&
                                                      operation !=
                                                          "CancelCollectionAuctionListing" &&
                                                      operation !=
                                                          "CancelListing" &&
                                                      operation !=
                                                          "CancelCollectionListing" &&
                                                      operation !=
                                                          "CancelNFTOfferMade" &&
                                                      operation !=
                                                          "CancelCollectionOfferMade")
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'Bank Account'
                                                                  .tr(),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      13.5.sp,
                                                                  fontFamily:
                                                                      'Inter',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: themeNotifier.isDark
                                                                      ? AppColors
                                                                          .textColorWhite
                                                                      : AppColors
                                                                          .textColorBlack),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(height: 2.h),
                                                  if (operation != "makeNFTCounterOffer" &&
                                                      operation !=
                                                          "makeCollectionCounterOffer" &&
                                                      operation !=
                                                          "rejectNFTCounterOffer" &&
                                                      operation !=
                                                          "rejectCollectionCounterOffer" &&
                                                      operation !=
                                                          "rejectNFTOfferReceived" &&
                                                      operation !=
                                                          "rejectCollectionOfferReceived" &&
                                                      operation !=
                                                          "CancelAuctionListing" &&
                                                      operation !=
                                                          "CancelCollectionAuctionListing" &&
                                                      operation !=
                                                          "CancelListing" &&
                                                      operation !=
                                                          "CancelCollectionListing" &&
                                                      operation !=
                                                          "CancelNFTOfferMade" &&
                                                      operation !=
                                                          "CancelCollectionOfferMade")
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 0),
                                                      child: Container(
                                                        height: 6.5.h,
                                                        margin: EdgeInsets.only(
                                                            bottom: 1.h),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          border: Border.all(
                                                            color: AppColors
                                                                .textColorGrey
                                                                .withOpacity(
                                                                    0.50),
                                                            // Off-white color
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: ListView.builder(
                                                          controller:
                                                              scrollController,
                                                          itemCount:
                                                              banks.length,
                                                          shrinkWrap: true,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          itemBuilder:
                                                              (context, index) {
                                                            bool isFirst =
                                                                index == 0;
                                                            bool isLast = index ==
                                                                banks.length -
                                                                    1;
                                                            String
                                                                lastFourDigits =
                                                                banks[index]
                                                                    .ibanNumber
                                                                    .substring(
                                                                      banks[index]
                                                                              .ibanNumber
                                                                              .length -
                                                                          4,
                                                                    );
                                                            bankpro
                                                                .selectedBank = banks[
                                                                            index]
                                                                        .isPrimary ==
                                                                    "true"
                                                                ? " **** " +
                                                                    banks[index]
                                                                        .ibanNumber
                                                                        .substring(
                                                                            banks[index].ibanNumber.length -
                                                                                4)
                                                                : "";
                                                            print(
                                                                "Selected Bank Name");
                                                            print(bankpro
                                                                .selectedBankName);
                                                            return banks[index]
                                                                        .isPrimary ==
                                                                    'true'
                                                                ? Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .symmetric(
                                                                      horizontal:
                                                                          10.sp,
                                                                      vertical:
                                                                          10.sp,
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              0.5.w,
                                                                        ),
                                                                        Container(
                                                                          // color: Colors.red,
                                                                          width:
                                                                              40.w,
                                                                          child:
                                                                              Text(
                                                                            banks[index].bankName.toString(),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 10.sp,
                                                                              fontFamily: 'Inter',
                                                                              fontWeight: FontWeight.w500,
                                                                              color: themeNotifier.isDark ? AppColors.textColorWhite : AppColors.textColorBlack,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Spacer(),
                                                                        SizedBox(
                                                                          width:
                                                                              1.w,
                                                                        ),
                                                                        Container(
                                                                          // color: Colors.yellow,
                                                                          width:
                                                                              25.w,
                                                                          child:
                                                                              Text(
                                                                            " **** " +
                                                                                banks[index].ibanNumber.substring(banks[index].ibanNumber.length - 4),
                                                                            textAlign:
                                                                                TextAlign.right,
                                                                            // banks[index].ibanNumber,
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                fontSize: 11.sp,
                                                                                fontFamily: 'Inter',
                                                                                fontWeight: FontWeight.w400,
                                                                                color: themeNotifier.isDark ? AppColors.textColorWhite : AppColors.textColorBlack),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : SizedBox();
                                                            // :SizedBox();
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  operation !=
                                                              "makeNFTCounterOffer" &&
                                                          operation !=
                                                              "makeCollectionCounterOffer" &&
                                                          operation !=
                                                              "rejectNFTCounterOffer" &&
                                                          operation !=
                                                              "rejectCollectionCounterOffer" &&
                                                          operation !=
                                                              "rejectNFTOfferReceived" &&
                                                          operation !=
                                                              "rejectCollectionOfferReceived" &&
                                                          operation !=
                                                              "CancelAuctionListing" &&
                                                          operation !=
                                                              "CancelCollectionAuctionListing" &&
                                                          operation !=
                                                              "CancelListing" &&
                                                          operation !=
                                                              "CancelCollectionListing" &&
                                                          operation !=
                                                              "CancelNFTOfferMade" &&
                                                          operation !=
                                                              "CancelCollectionOfferMade"
                                                      ? SizedBox(
                                                          height: 3.h,
                                                        )
                                                      : SizedBox(
                                                          height: 15.h,
                                                        ),
                                                  if (operation ==
                                                          "AcceptNFTOfferReceived" ||
                                                      operation ==
                                                          "AcceptCollectionOffer")
                                                    Container(
                                                      decoration:
                                                          BoxDecoration(),
                                                      // margin: EdgeInsets.symmetric(horizontal: 20.sp),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    0.sp),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                                height: 2.5.h),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          0),
                                                              child: Column(
                                                                  children: [
                                                                    RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                              text: 'By continuing you agree to the  '.tr(),
                                                                              style: TextStyle(
                                                                                  // height: 2,
                                                                                  color: AppColors.textColorWhite,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: 10.sp,
                                                                                  fontFamily: 'Inter')),
                                                                          TextSpan(
                                                                              recognizer: TapGestureRecognizer()
                                                                                ..onTap = () {
                                                                                  // Navigator.push(
                                                                                  //   context,
                                                                                  //   MaterialPageRoute(builder: (context) => TermsAndConditions()),
                                                                                  // );
                                                                                },
                                                                              text: 'Terms & Conditions'.tr() + " ",
                                                                              style: TextStyle(decoration: TextDecoration.underline, height: 1.5, color: AppColors.textColorToska, fontWeight: FontWeight.w600, fontSize: 10.sp, fontFamily: 'Inter')),
                                                                          TextSpan(
                                                                              text: '  of Hesa Wallet Payments.'.tr(),
                                                                              style: TextStyle(color: AppColors.textColorWhite, fontWeight: FontWeight.w400, fontSize: 10.sp, fontFamily: 'Inter'))
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ]),
                                                            ),
                                                            SizedBox(
                                                                height: 1.5.h),
                                                            AppButton(
                                                              title:
                                                                  "Reject request"
                                                                      .tr(),
                                                              handler: () {
                                                                // if(operation=="MintNFT"){
                                                                rejectTransactions();
                                                                // }
                                                              },
                                                              isGradient: false,
                                                              isGradientWithBorder:
                                                                  true,
                                                              buttonWithBorderColor:
                                                                  AppColors
                                                                      .errorColor,
                                                              color: AppColors
                                                                  .deleteAccountBtnColor
                                                                  .withOpacity(
                                                                      0.10),
                                                              textColor: themeNotifier.isDark
                                                                  ? AppColors
                                                                      .textColorWhite
                                                                  : AppColors
                                                                      .textColorBlack
                                                                      .withOpacity(
                                                                          0.8),
                                                            ),
                                                            SizedBox(
                                                              height: 2.h,
                                                            ),
                                                            AppButton(
                                                                title: "Accept"
                                                                    .tr(),
                                                                handler:
                                                                    () async {
                                                                  setState(() {
                                                                    isValidating =
                                                                        true;
                                                                  });
                                                                  setState(() {
                                                                    isLoading =
                                                                        true;
                                                                  });
                                                                  final result = await Provider.of<
                                                                              TransactionProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .nonPayableTransactionSendOTP(
                                                                    token:
                                                                        accessToken,
                                                                    context:
                                                                        context,
                                                                  );
                                                                  setState(() {
                                                                    isLoading =
                                                                        false;
                                                                  });
                                                                  if (result ==
                                                                      AuthResult
                                                                          .success) {
                                                                    startTimer();
                                                                    otpDialog(
                                                                      fromTransaction:
                                                                          true,
                                                                      fromAuth:
                                                                          false,
                                                                      fromUser:
                                                                          false,
                                                                      events:
                                                                          _events,
                                                                      firstBtnHandler:
                                                                          () async {
                                                                        setState(
                                                                            () {
                                                                          isLoading =
                                                                              true;
                                                                        });
                                                                        await Future.delayed(const Duration(
                                                                            milliseconds:
                                                                                500));
                                                                        if (operation ==
                                                                            'AcceptNFTOfferReceived') {
                                                                          final resultAcceptOffer = await Provider.of<TransactionProvider>(context, listen: false).acceptOffer(
                                                                              params: params,
                                                                              token: accessToken,
                                                                              walletAddress: walletAddress,
                                                                              context: context,
                                                                              operation: operation,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                          if (resultAcceptOffer ==
                                                                              AuthResult.success) {
                                                                            paymentRecievedDialogue(
                                                                              amount: formatCurrency(
                                                                                feesMap!['total']['value'].toString(),
                                                                              ),
                                                                            );
                                                                          }
                                                                        } else if (operation ==
                                                                            'AcceptCollectionOffer') {
                                                                          final resultAcceptCollectionOffer = await Provider.of<TransactionProvider>(context, listen: false).acceptCollectionOffer(
                                                                              params: params,
                                                                              token: accessToken,
                                                                              walletAddress: walletAddress,
                                                                              context: context,
                                                                              operation: operation,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                          if (resultAcceptCollectionOffer ==
                                                                              AuthResult.success) {
                                                                            paymentRecievedDialogue(
                                                                              amount: formatCurrency(
                                                                                feesMap!['total']['value'].toString(),
                                                                              ),
                                                                            );
                                                                          }
                                                                        } else if (operation ==
                                                                            'rejectCollectionOfferReceived') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false).rejectCollectionOfferReceived(
                                                                              params: params,
                                                                              token: accessToken,
                                                                              walletAddress: walletAddress,
                                                                              context: context,
                                                                              operation: operation,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                        } else if (operation ==
                                                                            'makeNFTCounterOffer') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false).makeCounterOffer(
                                                                              walletAddress: walletAddress,
                                                                              // params: params,
                                                                              token: accessToken,
                                                                              context: context,
                                                                              operation: operation,
                                                                              id: counterId,
                                                                              offererId: counterOffererId,
                                                                              offerAmount: counterOffererAmount,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                        }
                                                                        if (operation ==
                                                                            'CancelNFTOfferMade') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false)
                                                                              .cancelNFTOfferMade(
                                                                            walletAddress:
                                                                                walletAddress,
                                                                            // params: params,
                                                                            token:
                                                                                accessToken,
                                                                            context:
                                                                                context,
                                                                            operation:
                                                                                operation,
                                                                            params:
                                                                                params,
                                                                            code:
                                                                                Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes,
                                                                          );
                                                                        } else if (operation ==
                                                                            'rejectNFTCounterOffer') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false).rejectNFTCounterOffer(
                                                                              walletAddress: walletAddress,
                                                                              // params: params,
                                                                              token: accessToken,
                                                                              context: context,
                                                                              operation: operation,
                                                                              id: counterId,
                                                                              offererId: counterOffererId,
                                                                              offerAmount: counterOffererAmount,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                        } else if (operation ==
                                                                            'makeCollectionCounterOffer') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false).makeCollectionCounterOffer(
                                                                              walletAddress: walletAddress,
                                                                              // params: params,
                                                                              token: accessToken,
                                                                              context: context,
                                                                              operation: operation,
                                                                              id: counterId,
                                                                              offererId: counterOffererId,
                                                                              offerAmount: counterOffererAmount,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                        } else if (operation ==
                                                                            'rejectCollectionCounterOffer') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false).rejectCollectionCounterOffer(
                                                                              walletAddress: walletAddress,
                                                                              // params: params,
                                                                              token: accessToken,
                                                                              context: context,
                                                                              operation: operation,
                                                                              id: counterId,
                                                                              offererId: counterOffererId,
                                                                              offerAmount: counterOffererAmount,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                        } else if (operation ==
                                                                            'CancelCollectionOfferMade') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false)
                                                                              .cancelCollectionOfferMade(
                                                                            walletAddress:
                                                                                walletAddress,
                                                                            // params: params,
                                                                            token:
                                                                                accessToken,
                                                                            context:
                                                                                context,
                                                                            operation:
                                                                                operation,
                                                                            params:
                                                                                params,
                                                                            code:
                                                                                Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes,
                                                                          );
                                                                        }
                                                                        if (operation ==
                                                                            'CancelAuctionListing') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false)
                                                                              .cancelAuctionListing(
                                                                            walletAddress:
                                                                                walletAddress,
                                                                            token:
                                                                                accessToken,
                                                                            context:
                                                                                context,
                                                                            operation:
                                                                                operation,
                                                                            params:
                                                                                params,
                                                                            code:
                                                                                Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes,
                                                                          );
                                                                        } else if (operation ==
                                                                            'CancelCollectionAuctionListing') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false).cancelCollectionAuctionListing(
                                                                              walletAddress: walletAddress,
                                                                              token: accessToken,
                                                                              context: context,
                                                                              operation: operation,
                                                                              params: params,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                        } else if (operation ==
                                                                            'CancelListing') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false).cancelListing(
                                                                              walletAddress: walletAddress,
                                                                              token: accessToken,
                                                                              context: context,
                                                                              operation: operation,
                                                                              params: params,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                        } else if (operation ==
                                                                            'CancelCollectionListing') {
                                                                          await Provider.of<TransactionProvider>(context, listen: false).cancelCollectionListing(
                                                                              walletAddress: walletAddress,
                                                                              token: accessToken,
                                                                              context: context,
                                                                              operation: operation,
                                                                              params: params,
                                                                              code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes);
                                                                        } else {}
                                                                        Navigator.pop(
                                                                            context);
                                                                        setState(
                                                                            () {
                                                                          isLoading =
                                                                              false;
                                                                        });
                                                                      },
                                                                      secondBtnHandler:
                                                                          () async {
                                                                        if (_timeLeft ==
                                                                            0) {
                                                                          print(
                                                                              'resend function calling');
                                                                          try {
                                                                            setState(() {
                                                                              _isLoadingResend = true;
                                                                            });
                                                                            final otpResult =
                                                                                await Provider.of<TransactionProvider>(context, listen: false).nonPayableTransactionSendOTP(
                                                                              token: accessToken,
                                                                              context: context,
                                                                            );
                                                                            setState(() {
                                                                              _isLoadingResend = false;
                                                                            });
                                                                            if (otpResult ==
                                                                                AuthResult.success) {
                                                                              startTimer();
                                                                            }
                                                                          } catch (error) {
                                                                            print("Error: $error");
                                                                            // _showToast('An error occurred'); // Show an error message
                                                                          } finally {
                                                                            setState(() {
                                                                              _isLoadingResend = false;
                                                                            });
                                                                          }
                                                                        } else {}
                                                                      },
                                                                      firstTitle:
                                                                          'Confirm',
                                                                      secondTitle:
                                                                          'Resend code ',

                                                                      // "${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}",

                                                                      context:
                                                                          context,
                                                                      isDark: themeNotifier
                                                                          .isDark,
                                                                      isFirstButtonActive:
                                                                          isOtpButtonActive,
                                                                      isSecondButtonActive:
                                                                          false,
                                                                      otp1Controller:
                                                                          otp1Controller,
                                                                      otp2Controller:
                                                                          otp2Controller,
                                                                      otp3Controller:
                                                                          otp3Controller,
                                                                      otp4Controller:
                                                                          otp4Controller,
                                                                      otp5Controller:
                                                                          otp5Controller,
                                                                      otp6Controller:
                                                                          otp6Controller,
                                                                      firstFieldFocusNode:
                                                                          firstFieldFocusNode,
                                                                      secondFieldFocusNode:
                                                                          secondFieldFocusNode,
                                                                      thirdFieldFocusNode:
                                                                          thirdFieldFocusNode,
                                                                      forthFieldFocusNode:
                                                                          forthFieldFocusNode,
                                                                      fifthFieldFocusNode:
                                                                          fifthFieldFocusNode,
                                                                      sixthFieldFocusNode:
                                                                          sixthFieldFocusNode,
                                                                      firstBtnBgColor:
                                                                          AppColors
                                                                              .activeButtonColor,
                                                                      firstBtnTextColor:
                                                                          AppColors
                                                                              .textColorBlack,
                                                                      secondBtnBgColor:
                                                                          Colors
                                                                              .transparent,
                                                                      secondBtnTextColor: _timeLeft !=
                                                                              0
                                                                          ? AppColors
                                                                              .textColorBlack
                                                                              .withOpacity(0.8)
                                                                          : AppColors.textColorWhite,
                                                                      // themeNotifier.isDark
                                                                      //     ? AppColors.textColorWhite
                                                                      //     : AppColors.textColorBlack
                                                                      //         .withOpacity(0.8),
                                                                      isLoading:
                                                                          _isLoadingResend,
                                                                    );
                                                                  }
                                                                },
                                                                // isLoading: isLoading,r
                                                                isGradient:
                                                                    true,
                                                                color: AppColors
                                                                    .textColorBlack),
                                                            SizedBox(
                                                                height: 2.h),
                                                            // AppButton(
                                                            //     title:
                                                            //         "Reject request"
                                                            //             .tr(),
                                                            //     handler: () {
                                                            //       // if(operation=="MintNFT"){
                                                            //       rejectTransactions();
                                                            //       // }
                                                            //     },
                                                            //     isGradient: false,
                                                            //     textColor: themeNotifier.isDark
                                                            //         ? AppColors
                                                            //             .textColorWhite
                                                            //         : AppColors
                                                            //             .textColorBlack
                                                            //             .withOpacity(
                                                            //                 0.8),
                                                            //     color: AppColors
                                                            //         .appSecondButton
                                                            //         .withOpacity(
                                                            //             0.10)),
                                                            SizedBox(
                                                              height: operation !=
                                                                          "AcceptNFTOfferReceived" &&
                                                                      operation !=
                                                                          "AcceptCollectionOffer"
                                                                  ? 2.h
                                                                  : 3.h,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                  ],
                ),
                if (operation != "AcceptNFTOfferReceived" &&
                    operation != "AcceptCollectionOffer")
                  Positioned(
                    left: 28,
                    right: 28,
                    bottom: 10,
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.sp),
                        child: Column(
                          children: [
                            SizedBox(height: 2.5.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              child: Column(children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text:
                                              'By continuing you agree to the  '
                                                  .tr(),
                                          style: TextStyle(
                                              // height: 2,
                                              color: AppColors.textColorWhite,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.sp,
                                              fontFamily: 'Inter')),
                                      TextSpan(
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(builder: (context) => TermsAndConditions()),
                                              // );
                                            },
                                          text: 'Terms & Conditions'.tr() + " ",
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              height: 1.5,
                                              color: AppColors.textColorToska,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10.sp,
                                              fontFamily: 'Inter')),
                                      TextSpan(
                                          text:
                                              '  of Hesa Wallet Payments.'.tr(),
                                          style: TextStyle(
                                              color: AppColors.textColorWhite,
                                              fontWeight: FontWeight.w400,
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
                              buttonWithBorderColor: AppColors.errorColor,
                              color: AppColors.deleteAccountBtnColor
                                  .withOpacity(0.10),
                              textColor: themeNotifier.isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack.withOpacity(0.8),
                            ),
                            SizedBox(height: 2.h),
                            AppButton(
                                title: "Accept".tr(),
                                handler: () async {
                                  setState(() {
                                    isValidating = true;
                                  });
                                  setState(() {
                                    isLoading = true;
                                  });
                                  final result =
                                      await Provider.of<TransactionProvider>(
                                              context,
                                              listen: false)
                                          .nonPayableTransactionSendOTP(
                                    token: accessToken,
                                    context: context,
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (result == AuthResult.success) {
                                    startTimer();
                                    otpDialog(
                                      fromTransaction: true,
                                      fromAuth: false,
                                      fromUser: false,
                                      events: _events,
                                      firstBtnHandler: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        if (operation ==
                                            'AcceptNFTOfferReceived') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .acceptOffer(
                                                  params: params,
                                                  token: accessToken,
                                                  walletAddress: walletAddress,
                                                  context: context,
                                                  operation: operation,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else if (operation ==
                                            'rejectNFTOfferReceived') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .rejectNFTOfferReceived(
                                                  params: params,
                                                  token: accessToken,
                                                  walletAddress: walletAddress,
                                                  context: context,
                                                  operation: operation,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else if (operation ==
                                            'AcceptCollectionOffer') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .acceptCollectionOffer(
                                                  params: params,
                                                  token: accessToken,
                                                  walletAddress: walletAddress,
                                                  context: context,
                                                  operation: operation,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else if (operation ==
                                            'rejectCollectionOfferReceived') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .rejectCollectionOfferReceived(
                                                  params: params,
                                                  token: accessToken,
                                                  walletAddress: walletAddress,
                                                  context: context,
                                                  operation: operation,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else if (operation ==
                                            'makeNFTCounterOffer') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .makeCounterOffer(
                                                  walletAddress: walletAddress,
                                                  // params: params,
                                                  token: accessToken,
                                                  context: context,
                                                  operation: operation,
                                                  id: counterId,
                                                  offererId: counterOffererId,
                                                  offerAmount:
                                                      counterOffererAmount,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        }
                                        if (operation == 'CancelNFTOfferMade') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .cancelNFTOfferMade(
                                            walletAddress: walletAddress,
                                            // params: params,
                                            token: accessToken,
                                            context: context,
                                            operation: operation,
                                            params: params,
                                            code: Provider.of<AuthProvider>(
                                                    context,
                                                    listen: false)
                                                .codeFromOtpBoxes,
                                          );
                                        } else if (operation ==
                                            'rejectNFTCounterOffer') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .rejectNFTCounterOffer(
                                                  walletAddress: walletAddress,
                                                  // params: params,
                                                  token: accessToken,
                                                  context: context,
                                                  operation: operation,
                                                  id: counterId,
                                                  offererId: counterOffererId,
                                                  offerAmount:
                                                      counterOffererAmount,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else if (operation ==
                                            'makeCollectionCounterOffer') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .makeCollectionCounterOffer(
                                                  walletAddress: walletAddress,
                                                  // params: params,
                                                  token: accessToken,
                                                  context: context,
                                                  operation: operation,
                                                  id: counterId,
                                                  offererId: counterOffererId,
                                                  offerAmount:
                                                      counterOffererAmount,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else if (operation ==
                                            'rejectCollectionCounterOffer') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .rejectCollectionCounterOffer(
                                                  walletAddress: walletAddress,
                                                  // params: params,
                                                  token: accessToken,
                                                  context: context,
                                                  operation: operation,
                                                  id: counterId,
                                                  offererId: counterOffererId,
                                                  offerAmount:
                                                      counterOffererAmount,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else if (operation ==
                                            'CancelCollectionOfferMade') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .cancelCollectionOfferMade(
                                                  walletAddress: walletAddress,
                                                  // params: params,
                                                  token: accessToken,
                                                  context: context,
                                                  operation: operation,
                                                  params: params,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        }
                                        if (operation ==
                                            'CancelAuctionListing') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .cancelAuctionListing(
                                            walletAddress: walletAddress,
                                            token: accessToken,
                                            context: context,
                                            operation: operation,
                                            params: params,
                                            code: otp1Controller.text +
                                                otp2Controller.text +
                                                otp3Controller.text +
                                                otp4Controller.text +
                                                otp5Controller.text +
                                                otp6Controller.text,
                                          );
                                        } else if (operation ==
                                            'CancelCollectionAuctionListing') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .cancelCollectionAuctionListing(
                                                  walletAddress: walletAddress,
                                                  token: accessToken,
                                                  context: context,
                                                  operation: operation,
                                                  params: params,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else if (operation ==
                                            'CancelListing') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .cancelListing(
                                                  walletAddress: walletAddress,
                                                  token: accessToken,
                                                  context: context,
                                                  operation: operation,
                                                  params: params,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else if (operation ==
                                            'CancelCollectionListing') {
                                          await Provider.of<
                                                      TransactionProvider>(
                                                  context,
                                                  listen: false)
                                              .cancelCollectionListing(
                                                  walletAddress: walletAddress,
                                                  token: accessToken,
                                                  context: context,
                                                  operation: operation,
                                                  params: params,
                                                  code:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .codeFromOtpBoxes);
                                        } else {}
                                        Navigator.pop(context);
                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                      secondBtnHandler: () async {
                                        if (_timeLeft == 0) {
                                          print('resend function calling');
                                          try {
                                            setState(() {
                                              _isLoadingResend = true;
                                            });
                                            final otpResult = await Provider.of<
                                                        TransactionProvider>(
                                                    context,
                                                    listen: false)
                                                .nonPayableTransactionSendOTP(
                                              token: accessToken,
                                              context: context,
                                            );
                                            setState(() {
                                              _isLoadingResend = false;
                                            });
                                            if (otpResult ==
                                                AuthResult.success) {
                                              startTimer();
                                            }
                                          } catch (error) {
                                            print("Error: $error");
                                            // _showToast('An error occurred'); // Show an error message
                                          } finally {
                                            setState(() {
                                              _isLoadingResend = false;
                                            });
                                          }
                                        } else {}
                                      },
                                      firstTitle: 'Confirm',
                                      secondTitle: 'Resend code ',

                                      // "${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}",

                                      context: context,
                                      isDark: themeNotifier.isDark,
                                      isFirstButtonActive: isOtpButtonActive,
                                      isSecondButtonActive: false,
                                      otp1Controller: otp1Controller,
                                      otp2Controller: otp2Controller,
                                      otp3Controller: otp3Controller,
                                      otp4Controller: otp4Controller,
                                      otp5Controller: otp5Controller,
                                      otp6Controller: otp6Controller,
                                      firstFieldFocusNode: firstFieldFocusNode,
                                      secondFieldFocusNode:
                                          secondFieldFocusNode,
                                      thirdFieldFocusNode: thirdFieldFocusNode,
                                      forthFieldFocusNode: forthFieldFocusNode,
                                      fifthFieldFocusNode: fifthFieldFocusNode,
                                      sixthFieldFocusNode: sixthFieldFocusNode,
                                      firstBtnBgColor:
                                          AppColors.activeButtonColor,
                                      firstBtnTextColor:
                                          AppColors.textColorBlack,
                                      secondBtnBgColor: Colors.transparent,
                                      secondBtnTextColor: _timeLeft != 0
                                          ? AppColors.textColorBlack
                                              .withOpacity(0.8)
                                          : AppColors.textColorWhite,
                                      // themeNotifier.isDark
                                      //     ? AppColors.textColorWhite
                                      //     : AppColors.textColorBlack
                                      //         .withOpacity(0.8),
                                      isLoading: _isLoadingResend,
                                    );
                                  }
                                },
                                // isLoading: isLoading,r
                                isGradient: true,
                                color: AppColors.textColorBlack),
                          ],
                        ),
                      ),
                    ),
                  )
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
          Container(
            // color: Colors.red,
            width: 27.w,
            child: Text(
              title,
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: isDark
                      ? AppColors.textColorWhite
                      : AppColors.textColorBlack,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Spacer(),
          Container(
            // color: Colors.yellow,
            width: 50.w,
            child: Text(
              details,
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: color == null ? AppColors.textColorGreyShade2 : color,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400),
            ),
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
            width: 45.w,
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
            width: 25.w,
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
              height: 18.sp,
              // width: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentTypes(
      {bool isFirst = false, bool isLast = false, bool isDark = true}) {
    return Column(
      children: [
        if (isFirst)
          Divider(
            color: AppColors.textColorGrey,
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
                Image.asset(
                  "assets/images/Visa.png",
                  height: 18.sp,
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
                Text(
                  "2561 **** **** 1234",
                  style: TextStyle(
                      fontSize: 11.7.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      color: isFirst
                          ? AppColors.activeButtonColor
                          : isDark
                              ? AppColors.textColorWhite
                              : AppColors.textColorBlack),
                ),
                if (isFirst)
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
                        color: AppColors.activeButtonColor,
                      ),
                    ),
                  ),
                Spacer(),
                Image.asset(
                  "assets/images/cancel.png",
                  height: 16.sp,
                  color: AppColors.textColorGrey,
                  // color: isDark
                  //     ? AppColors.textColorWhite
                  //     : AppColors.textColorBlack,
                  // width: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: AppColors.textColorGrey,
          ),
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
      barrierDismissible: false,
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

  void paymentRecievedDialogue({
    bool isDark = true,
    String amount = '',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                height: 30.h,
                width: dialogWidth,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.showDialogClr
                      : AppColors.textColorWhite,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textColorBlack.withOpacity(0.95),
                      offset: Offset(0, 8),
                      blurRadius: 10,
                      spreadRadius: 0.4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Deposit Underway'.tr(),
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
                      ],
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image.asset("assets/images/bank.png",
                        //     height: 22.sp, width: 22.sp),
                        // SizedBox(width: 1.w,),
                        Text(
                          amount + ' SAR'.tr(),
                          style: TextStyle(
                            fontSize: 27.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.activeButtonColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    Column(children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: 'From:'.tr(),
                                style: TextStyle(
                                    // height: 2,
                                    color: AppColors.textColorWhite,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10.2.sp,
                                    fontFamily: 'Inter')),
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                                text: ' https://neo-nft.com'.tr(),
                                style: TextStyle(
                                    // decoration: TextDecoration.underline,
                                    // height: 1.5,
                                    color: AppColors.textColorToska,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10.2.sp,
                                    fontFamily: 'Inter')),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 1.5.h,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Amount has been processed to be deposit in your bank account, you should receive amount shortly.'
                                .tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textColorGreyShade2
                                  : AppColors.textColorBlack,
                              fontWeight: FontWeight.w400,
                              fontSize: 10.2.sp,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              )),
        );
      },
    );
  }
}
