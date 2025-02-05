import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/string_utils.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/main_header.dart';

class TransactionSummary extends StatefulWidget {
  const TransactionSummary({Key? key}) : super(key: key);

  static const routeName = 'transactionsummary';

  @override
  State<TransactionSummary> createState() => _TransactionSummaryState();
}

class _TransactionSummaryState extends State<TransactionSummary> {
  var accessToken = "";
  var _isLoading = false;
  var _isInit = true;
  var id;
  var type;

  final ScrollController scrollController = ScrollController();

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // accessToken = prefs.getString('accessToken')!;
    print('accessToken' + accessToken);
    // print(accessToken);
  }

  init() async {
    await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
  }

  @override
  initState() {
    // TODO: implement initState
    init();
    super.initState();
  }

  @override
  didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        id = args['id'];
        type = args['type'];
      }

      try {
        await getAccessToken();
        await Provider.of<TransactionProvider>(context, listen: false)
            .clearTxSummaryData();
        Locale currentLocale = context.locale;
        bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
        await Future.delayed(Duration(milliseconds: 500), () {});
        await Provider.of<TransactionProvider>(context, listen: false)
            .getTransactionSummary(
                accessToken: accessToken, id: id, type: type, context: context, isEnglish: isEnglish);
        print('this is type' + type);
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        // Handle error here
        print('Error occurred: $error');
        setState(() {
          _isLoading = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
    _isInit = false;
  }
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      id = args['id'];
      type = args['type'];
      print('Aik bhi' + id + type);
    }
    final txSummary = Provider.of<TransactionProvider>(context, listen: false);
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(txSummary.txTimeStamp);
    } catch (e) {
      print('Error parsing date: $e');
      // Provide a fallback mechanism here, for example:
      parsedDate = DateTime.now(); // Or any other fallback value
    }
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Consumer<TransactionProvider>(
          builder: (context, transactionSummary, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: themeNotifier.isDark
                  ? AppColors.backgroundColor
                  : AppColors.textColorWhite,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainHeader(
                    title: "Transaction Summary".tr(),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 4.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25.sp),
                              child: Container(
                                // color: Colors.red,
                                height: 10.6.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.connectedSitesPopupsClr,
                                  borderRadius: BorderRadius.circular(10),
                                  // border: Border.all(
                                  //     color: AppColors.transactionSummNeoBorder,
                                  //     width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    children: [
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
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'From:'.tr(),
                                            style: TextStyle(
                                                color: AppColors.textColorWhite,
                                                fontSize: 8.5.sp,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          SizedBox(
                                            height: 3.sp,
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                _launchURL(args!['site']),
                                            child: Container(
                                              width: 47.w,
                                              // color: Colors.yellow,
                                              child: Text(
                                                args!['site'],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: themeNotifier.isDark
                                                        ? AppColors
                                                            .textColorToska
                                                        : AppColors
                                                            .textColorToska,
                                                    fontSize: 10.5.sp,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Container(
                              // color: Colors.red,
                              // height: 13.5.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.circular(10),
                                  // border: Border.all(
                                  //     color: AppColors.textColorGrey, width: 1)
                                  ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          transactionSummary
                                                      .receiverBankDetails !=
                                                  'null'
                                              ? 'Payout'
                                              : transactionSummary.txType
                                                          .contains("Cancel") ||
                                                      transactionSummary.txType
                                                          .contains("Reject") ||
                                                      txSummary.txType ==
                                                          'Reject Counter Offer' ||
                                                      txSummary.txType ==
                                                          'Make Counter Offer'
                                                  ? 'Transaction Successful'
                                                  : 'Payment Successful'.tr(),
                                          style: TextStyle(
                                            color: themeNotifier.isDark
                                                ? AppColors.textColorWhite
                                                : AppColors.textColorBlack,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.5.sp,
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
                                      height: 1.h,
                                    ),
                                    if (txSummary.txType ==
                                            'Cancel Auction Listing' ||
                                        txSummary.txType == 'Cancel Listing' ||
                                        txSummary.txType == 'Reject Offer' ||
                                        txSummary.txType ==
                                            'Reject Counter Offer' ||
                                        txSummary.txType ==
                                            'rejectCollectionOfferReceived'||
                                        txSummary.txType ==
                                            'Make Counter Offer' ||
                                        txSummary.txType ==
                                            'Make Collection Counter Offer'
                                    )
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 2.h),
                                        child: Text(
                                          transactionSummary.txType
                                                  .contains("Counter")
                                              ? truncateTo13Digits(
                                                  transactionSummary.txId)
                                              : truncateTo13Digits(
                                                  transactionSummary.txId),
                                          style: TextStyle(
                                            color: themeNotifier.isDark
                                                ? AppColors.textColorGreyShade2
                                                : AppColors.textColorBlack,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    if (!transactionSummary.txType
                                            .contains("Cancel") &&
                                        !transactionSummary.txType
                                            .contains("Reject") &&
                                    txSummary.txType !=
                                    'Make Counter Offer'  &&
                                        txSummary.txType !=
                                            'Make Collection Counter Offer')
                                      Text(
                                        formatCurrency(transactionSummary
                                                .txTotalAmount) +
                                            ' SAR'.tr(),
                                        style: TextStyle(
                                          fontSize: 26.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              transactionSummary.txAmountType ==
                                                      'credit'
                                                  ? AppColors.hexaGreen
                                                  : AppColors.hexaGreen,
                                        ),
                                      ),
                                    if (transactionSummary
                                            .receiverBankDetails !=
                                        'null')
                                      Text(
                                        "Deposit to",
                                        style: TextStyle(
                                          color: themeNotifier.isDark
                                              ? AppColors.textColorGreyShade2
                                              : AppColors.textColorBlack,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 8.sp,
                                        ),
                                      ),
                                    if (transactionSummary.txCrdBrand !=
                                        'Unknown')
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.sp, vertical: 5.sp),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            transactionSummary
                                                        .receiverBankDetails !=
                                                    "null"
                                                ? Image.network(
                                                    transactionSummary
                                                        .txBankImage,
                                                    // "assets/images/bank.png",
                                                    height: 23.sp,
                                                    width: 23.sp,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Icon(Icons
                                                          .error); // Fallback UI
                                                    },
                                                  )
                                                : transactionSummary.receiverCardDetails != 'null' ?
                                            transactionSummary
                                                            .txCrdBrand ==
                                                        'VISA'
                                                    ? Image.asset(
                                                        "assets/images/Visa.png",
                                                        height: 23.sp,
                                                        width: 23.sp)
                                                    : Container(
                                                        height: 2.7.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .textColorGreyShade2
                                                              .withOpacity(
                                                                  0.27),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal:
                                                                  transactionSummary
                                                                              .txCrdBrand ==
                                                                          'MASTER'
                                                                      ? 5.8.sp
                                                                      : 3.8.sp,
                                                              vertical: transactionSummary
                                                                          .txCrdBrand ==
                                                                      'MASTER'
                                                                  ? 4.sp
                                                                  : 3.7.sp),
                                                          child: Image.asset(
                                                            transactionSummary
                                                                        .txCrdBrand ==
                                                                    'Unknown'
                                                                ? "assets/images/unknown_card.png"
                                                                : transactionSummary
                                                                            .txCrdBrand ==
                                                                        'MASTER'
                                                                    ? "assets/images/master2.png"
                                                                    : "assets/images/mada_pay.png",
                                                            // height: 18.sp,
                                                            // width: 18.sp
                                                          ),
                                                        ),
                                                      ): SizedBox(),
                                            SizedBox(
                                              width: 3.sp,
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            // Spacer(),
                                            Text(
                                              transactionSummary
                                                          .receiverBankDetails !=
                                                      "null"
                                                  ? transactionSummary
                                                      .txBankAccNum
                                                  : transactionSummary.txCrdNum,
                                              style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: themeNotifier.isDark
                                                      ? AppColors.textColorWhite
                                                      : AppColors
                                                          .textColorBlack),
                                            ),
                                          ],
                                        ),
                                      ),
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height:
                            txSummary.txType ==
                            'Make Collection Counter Offer' || txSummary.txType == 'Make Counter Offer' ||
                                          txSummary.txType
                                              .toString()
                                              .contains('Cancel') ||
                                          txSummary.txType
                                              .toString()
                                              .contains('Reject')
                                      ? 64.h
                                      : null,
                              decoration: BoxDecoration(
                                  // color: AppColors.errorColor,
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
                                          .format(parsedDate),
                                      isDark:
                                          themeNotifier.isDark ? true : false,
                                    ),
                                    transactionDetailsWidget(
                                      title: 'Tx Type:'.tr(),
                                      details: tnxLabelingWithApi(transactionSummary.txType),
                                      isDark:
                                          themeNotifier.isDark ? true : false,
                                    ),
                                    transactionDetailsWidget(
                                      title: 'Tx ID:'.tr(),
                                      func: () => _launchURL(
                                          "https://www.mjraexplorer.com/tx/" +
                                              transactionSummary.txId),
                                      details: type == 'counter-offer'
                                          ? truncateTo13Digits(
                                              transactionSummary.txId)
                                          : truncateTo13Digits(
                                              transactionSummary.txId),
                                      isDark:
                                          themeNotifier.isDark ? true : false,
                                      color: AppColors.textColorToska,
                                    ),
                                    transactionDetailsWidget(
                                        title: 'Tx Status:'.tr(),
                                        details: transactionSummary.txStatus,
                                        isSuccess: true,
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                        color: AppColors.hexaGreen),
                                    transactionDetailsWidget(
                                      func: () => _launchURL(
                                          "https://www.mjraexplorer.com/$type/${transactionSummary.txTokenId}"),
                                      title: type == 'collection'
                                          ? "Collection ID:"
                                          : "Token ID:".tr(),
                                      details:
                                          transactionSummary.txTokenId != ""
                                              ? truncateTo13Digits(
                                                  transactionSummary.txTokenId)
                                              : 'N/A',
                                      isDark:
                                          themeNotifier.isDark ? true : false,
                                      color: AppColors.textColorToska,
                                    ),
                                    if (transactionSummary
                                            .txCreatorRoyalityPercent !=
                                        'null')
                                      transactionDetailsWidget(
                                        title: 'Creator royalty:'.tr(),
                                        details: transactionSummary
                                                .txCreatorRoyalityPercent +
                                            "%",
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                      ),
                                    transactionDetailsWidget(
                                      func: () => _launchURL(
                                          "https://www.mjraexplorer.com/address/${transactionSummary.txCreatorId}"),
                                      title: 'Creator ID:'.tr(),
                                      details: truncateTo13Digits(
                                          transactionSummary.txCreatorId),
                                      isDark:
                                          themeNotifier.isDark ? true : false,
                                      color: AppColors.textColorToska,
                                    ),
                                    if (transactionSummary.txOfferedBy != 'N/A')
                                      transactionDetailsWidget(
                                        title: 'Offered by:'.tr(),
                                        details: truncateTo13Digits(
                                            transactionSummary.txOfferedBy),
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                      ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    if (transactionSummary
                                            .transactionFeeses.length !=
                                        0)
                                      Container(
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.transactionFeeContainer,
                                          borderRadius:
                                              BorderRadius.circular(10.sp),
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
                                                        ? AppColors
                                                            .textColorWhite
                                                        : AppColors
                                                            .textColorBlack,
                                                    fontSize: 12.5.sp,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Divider(
                                                color: AppColors.textColorGrey,
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              ListView.builder(
                                                itemCount: transactionSummary
                                                    .transactionFeeses.length,
                                                controller: scrollController,
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context, index) {
                                                  final feeItem =
                                                      transactionSummary
                                                              .transactionFeeses[
                                                          index];
                                                  final String secondLabel =
                                                      feeItem.keys.elementAt(1);
                                                  final String secondValue =
                                                      feeItem[secondLabel]
                                                          .toString();
                                                  final String label =
                                                      feeItem.keys.last;
                                                  final String value =
                                                      transactionSummary
                                                                  .receiverBankDetails !=
                                                              'null'
                                                          ? formatCurrency(
                                                              feeItem[label]
                                                                  .toString())
                                                          : '' +
                                                              formatCurrency(
                                                                  feeItem[label]
                                                                      .toString());
                                                  bool lastIndex = index ==
                                                      transactionSummary
                                                              .transactionFeeses
                                                              .length -
                                                          1;

                                                  return Column(
                                                    children: [
                                                      if (lastIndex)
                                                        Divider(
                                                          color: AppColors
                                                              .textColorGrey,
                                                        ),
                                                      transactionFeesWidget(
                                                        title:
                                                            secondValue ?? "",
                                                        details: value + ' SAR'.tr(),
                                                        isDark:
                                                            themeNotifier.isDark
                                                                ? true
                                                                : false,
                                                        isEnglish: isEnglish,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   height: 4.h,
                            // ),

                            // SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (_isLoading)
              Positioned(
                  top: 12.h,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LoaderBluredScreen())
          ],
        );
      });
    });
  }

  Widget transactionDetailsWidget(
      {required String title,
      required String details,
      Color? color,
      bool isDark = true,
      bool isSuccess = false,
      Function? func}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        children: [
          Container(
            width: 30.w,
            // color: Colors.yellow,
            child: Text(
              title,
              style: TextStyle(
                  color: isDark
                      ? AppColors.textColorWhite
                      : AppColors.textColorBlack,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () => func!(),
            child: Container(
              width: 50.w,
              // color: Colors.green,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color:
                              color == null ? AppColors.textColorGreyShade2 : color,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400),
                    ),
                    if(isSuccess)
                      Padding(
                        padding:  EdgeInsets.only(left: 2.sp),
                        child: Image.asset(
                          "assets/images/check_circle_white.png",
                          height: 11.sp,
                          width: 11.sp,
                          color: AppColors.hexaGreen,
                        ),
                      ),
                  ],
                ),
              ),
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
    bool isEnglish =true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: title == "Total" ? 25.w : 45.w,
            child: Text(
              title,
              // maxLines: 1,
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
            // color: Colors.blue,
            child: Text(
              details,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isEnglish ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                  color: isDark
                      ? AppColors.textColorWhite
                      : AppColors.textColorBlack,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
