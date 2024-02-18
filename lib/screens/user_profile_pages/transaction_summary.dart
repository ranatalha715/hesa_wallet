import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/main_header.dart';

class TransactionSummary extends StatefulWidget {
  const TransactionSummary({Key? key}) : super(key: key);

  @override
  State<TransactionSummary> createState() => _TransactionSummaryState();
}

class _TransactionSummaryState extends State<TransactionSummary> {
  var accessToken = "";

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
    // print(accessToken);
  }

  init() async {
    await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    // await Provider.of<TransactionProvider>(context, listen: false)
    //     .calculateTransactionSummary(
    //   token: accessToken,
    //   assetPrice: '150',
    //   func: 'AcceptOffer',
    //   entries: '1',
    //   creatorRoyaltyPercent: '10',
    //   context: context,
    // );
  }

  @override
  void initState() {
    // TODO: implement initState
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Scaffold(
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
                                    Text(
                                      'https://neo-nft.com',
                                      style: TextStyle(
                                          color: themeNotifier.isDark
                                              ? AppColors.textColorToska
                                              : AppColors.textColorToska,
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.w600),
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
                                    'Payment received'.tr(),
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
                                '350.75 SAR'.tr(),
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
                                    Image.asset("assets/images/bank.png",
                                        height: 23.sp, width: 23.sp),
                                    SizedBox(
                                      width: 3.sp,
                                    ),
                                    Text(
                                      'Riyad Bank'.tr(),
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
                                      '**** 1234',
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
                                details: 'May 24, 2023 04:19:35'.tr(),
                                isDark: themeNotifier.isDark ? true : false,
                              ),
                              transactionDetailsWidget(
                                title: 'Tx Type:'.tr(),
                                details: 'Token Offer Fulfillment'.tr(),
                                isDark: themeNotifier.isDark ? true : false,
                              ),
                              transactionDetailsWidget(
                                title: 'Tx ID:'.tr(),
                                details: 'zvhje...bsxx93'.tr(),
                                isDark: themeNotifier.isDark ? true : false,
                                color: AppColors.textColorToska,
                              ),
                              transactionDetailsWidget(
                                  title: 'Tx Status:'.tr(),
                                  details: 'Success'.tr(),
                                  isDark: themeNotifier.isDark ? true : false,
                                  color: AppColors.hexaGreen),
                              transactionDetailsWidget(
                                title: 'Token ID:'.tr(),
                                details: 'xyeafa...wrbqwurqw'.tr(),
                                isDark: themeNotifier.isDark ? true : false,
                                color: AppColors.textColorToska,
                              ),
                              transactionDetailsWidget(
                                title: 'Offered by:'.tr(),
                                details: 'x383qrhwq..3u372242f'.tr(),
                                isDark: themeNotifier.isDark ? true : false,
                              ),
                              transactionDetailsWidget(
                                title: 'Creator royalty:'.tr(),
                                details: '10%'.tr(),
                                isDark: themeNotifier.isDark ? true : false,
                              ),
                              transactionDetailsWidget(
                                title: 'Creator ID:'.tr(),
                                details: '0dhawfba..wqrjqb23'.tr(),
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
                                        title: 'Sale value'.tr(),
                                        details: '444.44 SAR'.tr(),
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                      ),
                                      transactionFeesWidget(
                                        title: 'Platform sale commission'.tr(),
                                        details: '-50.00 SAR'.tr(),
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                      ),
                                      transactionFeesWidget(
                                        title: 'Network fee'.tr(),
                                        details: '-32.00 SAR'.tr(),
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                      ),
                                      transactionFeesWidget(
                                        title: 'Payment processing fee'.tr(),
                                        details: '-22.00 SAR'.tr(),
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                      ),
                                      Divider(
                                        color: AppColors.textColorGrey,
                                      ),
                                      transactionFeesWidget(
                                        title: 'Total Receivable Amount'.tr(),
                                        details: '350.75 SAR'.tr(),
                                        isDark:
                                            themeNotifier.isDark ? true : false,
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
