import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

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

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // accessToken = prefs.getString('accessToken')!;
    print('accessToken'+accessToken);
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
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        id = args['id'];
        type = args['type'];
        print('Aik bhi' + id + type);
      }
      setState(() {
        _isLoading = true;
      });
      Future.delayed(Duration(milliseconds: 1000), () {});
     await getAccessToken();
      await Provider.of<TransactionProvider>(context, listen: false).getTransactionSummary(
          accessToken: accessToken, id: id, type: type, context: context).then((value) =>
          setState(() {
        _isLoading = false;
      }));
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
  }

  String replaceMiddleWithDotstxId(String input) {
    if (input.length <= 30) {
      return input;
    }

    final int middleIndex = input.length ~/ 2; // Find the middle index
    final int startIndex = middleIndex - 24; // Calculate the start index
    final int endIndex = middleIndex + 24; // Calculate the end index

    // Split the input string into three parts and join them with '...'
    final String result =
        input.substring(0, startIndex) + '....' + input.substring(endIndex);

    return result;
  }
  String replaceMiddleWithDotsTokenId(String input) {
    if (input.length <= 30) {
      return input;
    }

    final int middleIndex = input.length ~/ 2; // Find the middle index
    final int startIndex = middleIndex - 10; // Calculate the start index
    final int endIndex = middleIndex + 10; // Calculate the end index

    // Split the input string into three parts and join them with '...'
    final String result =
        input.substring(0, startIndex) + '....' + input.substring(endIndex);

    return result;
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
        input.substring(0, startIndex) + '....' + input.substring(endIndex);

    return result;
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
    final transactionSummary = Provider.of<TransactionProvider>(context,listen: false);

    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
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
                                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                        Container(
                                          width: 47.w,
                                          // color: Colors.yellow,
                                          child: Text(
                                            args!['site'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: themeNotifier.isDark
                                                    ? AppColors.textColorToska
                                                    : AppColors.textColorToska,
                                                fontSize: 10.5.sp,
                                                fontWeight: FontWeight.w600),
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
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Payment Successful'.tr(),
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
                                      Container(
                                        width: 2.h,
                                        height: 2.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                              color: AppColors.hexaGreen,
                                              width: 1.sp),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 10.sp,
                                            color: AppColors.hexaGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 1.h,
                                  ),
                                  Text(
                                    transactionSummary.totalFees + ' SAR',
                                    style: TextStyle(
                                      fontSize: 26.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.hexaGreen,
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 1.h,
                                  // ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.sp, vertical: 5.sp),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset( transactionSummary.txCrdBrand== 'VISA'? "assets/images/Visa.png" : "assets/images/master_card.png",
                                            height: 23.sp, width: 23.sp),
                                        SizedBox(
                                          width: 3.sp,
                                        ),
                                        if(transactionSummary.txCrdBrand!='VISA' && transactionSummary.txCrdBrand!='MASTER')
                                        Text(
                                          transactionSummary.txCrdBrand,
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack),
                                        ),
                                        SizedBox(
                                          width: 4.w,
                                        ),
                                        // Spacer(),
                                        Text(
                                          transactionSummary.txCrdNum,
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack),
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
                            decoration: BoxDecoration(
                                color: AppColors.transactionReqBorderWhole,
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
                                    details: DateFormat('MMMM dd, yyyy HH:mm:ss')
                                        .format(DateTime.parse(transactionSummary.txTimeStamp)),
                                    isDark: themeNotifier.isDark ? true : false,
                                  ),
                                  transactionDetailsWidget(
                                    title: 'Tx Type:'.tr(),
                                    details: transactionSummary.txType,
                                    isDark: themeNotifier.isDark ? true : false,
                                  ),
                                  transactionDetailsWidget(
                                    title: 'Tx ID:'.tr(),
                                    details: replaceMiddleWithDotstxId(transactionSummary.txId),
                                    isDark: themeNotifier.isDark ? true : false,
                                    color: AppColors.textColorToska,
                                  ),
                                  transactionDetailsWidget(
                                      title: 'Tx Status:'.tr(),
                                      details: transactionSummary.txStatus,
                                      isDark: themeNotifier.isDark ? true : false,
                                      color: AppColors.hexaGreen),
                                  transactionDetailsWidget(
                                    title: 'Token ID:'.tr(),
                                    details: replaceMiddleWithDotsTokenId(transactionSummary.txTokenId),
                                    isDark: themeNotifier.isDark ? true : false,
                                    color: AppColors.textColorToska,
                                  ),
                                  transactionDetailsWidget(
                                    title: 'Creator royalty:'.tr(),
                                    details: transactionSummary.txCreatorRoyalityPercent + "%",
                                    isDark: themeNotifier.isDark ? true : false,
                                  ),
                                  transactionDetailsWidget(
                                    title: 'Creator ID:'.tr(),
                                    details: replaceMiddleWithDots(transactionSummary.txCreatorId),
                                    isDark: themeNotifier.isDark ? true : false,
                                  ),
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.transactionFeeContainer,
                                        borderRadius: BorderRadius.circular(10.sp),
                                        border: Border.all(
                                            color: AppColors.transactionFeeBorder)),
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
                                          transactionFeesWidget(
                                            title: transactionSummary.assetListingLabel,
                                            details: transactionSummary.assetListingFee + ' SAR',
                                            isDark:
                                                themeNotifier.isDark ? true : false,
                                          ),
                                          transactionFeesWidget(
                                            title: transactionSummary.networkLabel,
                                            details: transactionSummary.networkFees + ' SAR',
                                            isDark:
                                            themeNotifier.isDark ? true : false,
                                          ),
                                          transactionFeesWidget(
                                            title: transactionSummary.paymentProcessingLabel,
                                            details: transactionSummary.paymentProcessingFee
                                                + ' SAR',
                                            isDark:
                                            themeNotifier.isDark ? true : false,
                                          ),
                                          // transactionFeesWidget(
                                          //   title: 'Platform sale commission'.tr(),
                                          //   details: '-50.00 SAR'.tr(),
                                          //   isDark:
                                          //       themeNotifier.isDark ? true : false,
                                          // ),
                                          // transactionFeesWidget(
                                          //   title: 'Network fee'.tr(),
                                          //   details: '-32.00 SAR'.tr(),
                                          //   isDark:
                                          //       themeNotifier.isDark ? true : false,
                                          // ),
                                          // transactionFeesWidget(
                                          //   title: 'Payment processing fee'.tr(),
                                          //   details: '-22.00 SAR'.tr(),
                                          //   isDark:
                                          //       themeNotifier.isDark ? true : false,
                                          // ),
                                          Column(
                                            children: [
                                              Divider(
                                                color: AppColors.textColorGrey,
                                              ),
                                              transactionFeesWidget(
                                                title: transactionSummary.totalLabel,
                                                details: transactionSummary.totalFees + ' SAR',
                                                isDark:
                                                themeNotifier.isDark ? true : false,
                                              ),
                                            ],

                                          ),
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
      // if (_isLoading) LoaderBluredScreen(),
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
          Container(
            width: 50.w,
            // color: Colors.green,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                details,
                style: TextStyle(
                    color: color == null ? AppColors.textColorGreyShade2 : color,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400),
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
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: AppColors.textColorWhite,
                fontSize: 11.sp,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(
            width: 5.sp,
          ),
          Text(
            details,
            style: TextStyle(
                color: isDark
                    ? AppColors.textColorWhite
                    : AppColors.textColorBlack,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
