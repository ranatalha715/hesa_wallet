import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/providers/card_provider.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/button.dart';
import 'package:hyperpay_plugin/model/ready_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:io' as OS;
import 'package:hyperpay_plugin/flutter_hyperpay.dart';
import 'dart:convert';
import '../../constants/app_deep_linking.dart';
import '../../constants/configs.dart';
import '../../constants/inapp_settings.dart';
import '../../constants/string_utils.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/main_header.dart';
import '../userpayment_and_bankingpages/wallet_add_card.dart';

class TransactionRequest extends StatefulWidget {
  const TransactionRequest({Key? key}) : super(key: key);

  static const routeName = 'transactionRequest';

  @override
  State<TransactionRequest> createState() => _TransactionRequestState();
}

class _TransactionRequestState extends State<TransactionRequest> {
  bool _isSelected = false;
  var params;
  var operation;
  var metaData;
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
  late FToast fToast;
  late FlutterHyperPay flutterHyperPay;
  String displayedText = '';
  String formattedExpiryDate = '';
  String displayedName = '';
  final TextEditingController _cardnumberController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
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
          merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
          countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
          companyNameApplePayIOS: "LIMAR INTERNATIONAL TECHNOLGIES",
          themColorHexIOS: "#000000",
          setStorePaymentDetailsMode: true,
        ),
      );
      print(paymentResultData.paymentResult);
      if (paymentResultData.paymentResult == PaymentResult.success ||
          paymentResultData.paymentResult == PaymentResult.sync) {
        setState(() {
          isLoading = true;
        });
        paymentSuccesfullDialogue(
            amount: Provider.of<TransactionProvider>(context, listen: false)
                .totalForDialog);
        Provider.of<TransactionProvider>(context, listen: false)
            .functionToNavigateAfterPayable(
                paymentResultData.paymentResult.toString(), operation, context,
                statusCode: '201', paramsToSend: paramsMap.toString());
        setState(() {
          isLoading = false;
        });
      } else {
        paymentFailedDialogue(
            amount: Provider.of<TransactionProvider>(context, listen: false)
                .totalForDialog);
        Provider.of<TransactionProvider>(context, listen: false)
            .functionToNavigateAfterPayable(
                paymentResultData.paymentResult.toString(), operation, context,
                statusCode: '400', paramsToSend: paramsMap.toString());
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      paymentFailedDialogue(
          amount: Provider.of<TransactionProvider>(context, listen: false)
              .totalForDialog);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    init();
    fToast = FToast();
    fToast.init(context);
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

  rejectTransactions() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(seconds: 1), () async {
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
            fromTransactionReq: true,
          ),
        ),
      );
      // Refresh the paymentCards list
      var pc = Provider.of<UserProvider>(context, listen: false).paymentCards;
      await Provider.of<UserProvider>(context, listen: false)
          .getUserDetails(token: accessToken, context: context);
      // setState(() {
      //   pc = Provider.of<UserProvider>(context, listen: false).getUpdatedPaymentCards(); // Replace this with your method to fetch the updated list.
      // });
    }
  }


  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      params = args['params'] ?? "N/A";
      paramsMap = jsonDecode(params);
      operation = args['operation'] ?? "N/A";
      metaData = args['metaData'] ?? "N/A";
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
    final filteredFees = feesMap!.entries
        .where((entry) => entry.value['label'] != 'Total')
        .toList();
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      setThemeDark = themeNotifier.isDark;
      Provider.of<UserProvider>(context, listen: false)
          .refreshCards((paymentCards));
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
                  IsScrolled: IsScrolled,
                ),
                Container(
                  height: 88.h,
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
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.sp),
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
                                  title: 'Timestamp:'.tr(),
                                  details: DateFormat('MMMM dd, yyyy')
                                      .format(unformatted),
                                  isDark: themeNotifier.isDark ? true : false,
                                ),
                                transactionDetailsWidget(
                                  title: 'Tnx Type:'.tr(),
                                  details: tnxLabelingWithPayload(operation),
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
                                        if (feesMap != null)
                                          ListView.builder(
                                            padding: EdgeInsets.zero,
                                            controller: scrollController,
                                            itemCount: filteredFees.length + 1,
                                            // Add one for the "Total" item at the end
                                            shrinkWrap: true,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (index ==
                                                  filteredFees.length) {
                                                final totalFee = feesMap!
                                                    .entries
                                                    .firstWhere((entry) =>
                                                        entry.value['label'] ==
                                                        'Total');
                                                String totalLabel = totalFee
                                                    .value['label']
                                                    .toString();
                                                String totalValue = totalFee
                                                    .value['value']
                                                    .toString();
                                                Provider.of<TransactionProvider>(
                                                            context,
                                                            listen: false)
                                                        .totalForDialog =
                                                    formatCurrency(totalValue);
                                                return Column(
                                                  children: [
                                                    Divider(
                                                        color: AppColors
                                                            .textColorGrey),
                                                    transactionFeesWidget(
                                                      title: totalLabel,
                                                      details: formatCurrency(
                                                          totalValue),
                                                      showCurrency: true,
                                                      isDark:
                                                          themeNotifier.isDark,
                                                    ),
                                                  ],
                                                );
                                              }
                                              final fee =
                                                  filteredFees[index].value;
                                              String feeLabel =
                                                  fee['label'].toString();
                                              String feeValue =
                                                  fee['value'].toString();
                                              return transactionFeesWidget(
                                                title: feeLabel,
                                                details:
                                                    formatCurrency(feeValue),
                                                showCurrency: true,
                                                isDark: themeNotifier.isDark,
                                              );
                                            },
                                          ),
                                        Text(
                                          operation != "acceptCounterOffer" &&
                                                  operation !=
                                                      "acceptCollectionCounterOffer"
                                              ? 'The transaction request is automatically signed and submitted to the Blockchain once this transaction is paid.'
                                                  .tr()
                                              : 'Your original offer amount will be fully refunded once the counter offer amount is confirmed.'
                                                  .tr()
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
                                                        : AppColors
                                                            .selectedCardAndBankBorder,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8.0),
                                                topRight: Radius.circular(8.0),
                                                bottomLeft: Radius.circular(
                                                    _isSelected ? 0.0 : 8.0),
                                                bottomRight: Radius.circular(
                                                    _isSelected ? 0.0 : 8.0),
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
                                                  Text(
                                                    paymentCards.isEmpty
                                                        ? "Add payment method"
                                                            .tr()
                                                        : trPro.selectedCardNum +
                                                            " **********",
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
                                                                .textColorGrey
                                                            : AppColors
                                                                .selectedCardAndBankBorder),
                                                  ),
                                                  Spacer(),
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
                                                        size: 22.sp,
                                                        color: themeNotifier
                                                                .isDark
                                                            ?
                                                        AppColors.textColorGrey
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
                                                  color: AppColors.hexaGreen,
                                                )
                                              : Container(child:
                                                  StatefulBuilder(builder:
                                                      (BuildContext context,
                                                          StateSetter
                                                              setState) {
                                                  return ListView.builder(
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
                                                              _isSelected =
                                                                  !_isSelected;
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
                                                              cardBrand:
                                                                  paymentCards[
                                                                          index]
                                                                      .cardBrand,
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
                                                      });
                                                }))
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
                                                : AppColors
                                                    .transactionFeeBorder,
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
                                Container(
                                  decoration: BoxDecoration(),
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
                                                            ..onTap = () {},
                                                      text:
                                                          ' Terms & Conditions'
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
                                            rejectTransactions();
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
                                                  });
                                                } else if (operation ==
                                                    'MintNFT') {
                                                  final nftResult = await transactionProvider
                                                      .mintNftpayableTransactionSend(
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
                                                  });
                                                } else if (operation ==
                                                    'listNFT') {
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
                                                  });
                                                } else if (operation ==
                                                    'listCollection') {
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
                                                  });
                                                } else if (operation ==
                                                    'listAuctionNFT') {
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
                                                  });
                                                } else if (operation ==
                                                    'listAuctionCollection') {
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
                                                  });
                                                } else if (operation ==
                                                    'burnNFT') {
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
                                                  });
                                                } else if (operation ==
                                                    'burnCollection') {
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
                                                      : false);
                                            },
                                            isGradient: true,
                                            color: AppColors.textColorBlack),
                                      ],
                                    ),
                                  ),
                                ),
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
            width: title == "Total" ? 45.w : 28.w,
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
          color: AppColors.textColorGrey,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentTypes({
    bool isFirst = false,
    bool isLast = false,
    bool isDark = true,
    bool isCardSelected = false,
    required int index,
    required String cardNum,
    required String cardBrand,
  }) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            if (isFirst)
              Divider(
                color: AppColors.paymentTypesBorder,
              ),
            Container(
              height: 5.5.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "$cardNum ********** ",
                      style: TextStyle(
                        fontSize: 11.7.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: isCardSelected
                            ? AppColors.selectedCardAndBankBorder
                            : isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack,
                      ),
                    ),
                    if (isCardSelected)
                      Container(
                        margin: EdgeInsets.only(left: 2.w),
                        width: 2.h,
                        height: 2.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.activeButtonColor,
                            width: 1.sp,
                          ),
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
                    cardBrand == 'VISA'
                        ? Image.asset(
                            "assets/images/Visa.png",
                            height: 17.5.sp,
                          )
                        : Container(
                            height: 2.7.h,
                            decoration: BoxDecoration(
                              color: AppColors.textColorGreyShade2
                                  .withOpacity(0.27),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.8.sp, vertical: 0.sp),
                              child: Image.asset(
                                cardBrand == 'MASTER'
                                    ? "assets/images/master2.png"
                                    : "assets/images/mada_pay.png",
                                height: 18.sp,
                                width: 18.sp,
                              ),
                            ),
                          ),
                    SizedBox(
                      width: 2.w,
                    ),
                    GestureDetector(
                      onTap: () => showPopupCardRemove(
                        isDark: isDark,
                        cardNumber: " ********** $cardNum",
                        index: index,
                        cardBrand: cardBrand,
                      ),
                      child: Image.asset(
                        "assets/images/cancel.png",
                        height: 16.sp,
                        color: AppColors.textColorGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isLast || isLast)
              SizedBox(
                height: 1.h,
              ),
          ],
        );
      },
    );
  }

  void confirmationRequestDialogue({bool isDark = true}) {
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
          await Navigator.of(context).pushNamedAndRemoveUntil(
              'nfts-page', (Route d) => false,
              arguments: {});
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

  void paymentFailedDialogue({
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
          await Navigator.of(context).pushNamedAndRemoveUntil(
              'nfts-page', (Route d) => false,
              arguments: {});
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

  void transactionFailed({
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
          await Navigator.of(context).pushNamedAndRemoveUntil(
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
                    ]),
              )),
        );
      },
    );
  }

  Future showPopupCardRemove({
    required bool isDark,
    required String cardNumber,
    required int index,
    required String cardBrand,
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
                          margin: EdgeInsets.symmetric(horizontal: 18.sp),
                          height: 6.5.h,
                          decoration: BoxDecoration(
                            color: AppColors.textColorGrey.withOpacity(0.10),
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
                                cardBrand == 'VISA'
                                    ? Image.asset(
                                        "assets/images/Visa.png",
                                        height: 18.sp,
                                      )
                                    : Container(
                                  // height: 2.7.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.textColorGreyShade2
                                              .withOpacity(0.27),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.2.sp,
                                              vertical: 1.5.sp),
                                          child: Image.asset(
                                            cardBrand == 'MASTER'
                                                ? "assets/images/master2.png"
                                                : "assets/images/mada_pay.png",
                                            height: 16.sp,
                                            width: 18.sp,
                                          ),
                                        ),
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
                              }
                            },
                            isLoading: isDialogLoading,
                            isGradient: false,
                            color: AppColors.deleteAccountBtnColor
                                .withOpacity(0.10),
                            textColor: AppColors.textColorWhite,
                            buttonWithBorderColor: AppColors.errorColor,
                            isGradientWithBorder: true,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: AppButton(
                            title: 'Cancel'.tr(),
                            handler: () {
                              Navigator.pop(context);
                            },
                            isGradient: false,
                            textColor: isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack.withOpacity(0.8),
                            color: AppColors.appSecondButton.withOpacity(0.10),
                            isGradientWithBorder: true,
                            secondBtnBorderClr: true,
                          ),
                        ),
                        Expanded(child: SizedBox())
                      ],
                    ),
                  )));
        });
      },
    );
  }

  _showToast(String message, {int duration = 1000}) {
    Widget toast = Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: AppColors.textColorWhite.withOpacity(0.5),
      ),
      child: Row(
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
                style: TextStyle(
                        color: AppColors.backgroundColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold)
                    .apply(fontWeightDelta: -2),
              ),
            ),
          ),
        ],
      ),
    );
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
}
