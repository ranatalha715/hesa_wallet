import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../models/FAQ_model.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/faq_widget.dart';
import '../../widgets/main_header.dart';

class FAQAndSupport extends StatefulWidget {
  const FAQAndSupport({Key? key}) : super(key: key);

  @override
  State<FAQAndSupport> createState() => _FAQAndSupportState();
}

class _FAQAndSupportState extends State<FAQAndSupport> {
  bool _isSelected = false;
  var _selectedIndex = -1;
  var _isLoading = false;
  var _isinit = true;

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (_isinit) {}
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(title: 'FAQ’s'.tr()),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Container(
                    color: Colors.transparent,
                    height: 88.h,
                    child: SingleChildScrollView(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 4.h,
                          ),
                          Text(
                            "Hesa Wallet FAQ’s".tr(),
                            style: TextStyle(
                                color: AppColors.textColorWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                                fontFamily: 'Inter'),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: faqList.length,
                              itemBuilder: (context, index) {
                                return FAQWidget(
                                  faq: faqList[index],
                                );
                              }),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            "Account & Security".tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                                fontFamily: 'Inter'),
                          ),
                          SizedBox(height: 1.h,),
                          ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: faqList.length,
                              itemBuilder: (context, index) {
                                return FAQWidget(
                                  faq: faqSecurity[index],
                                );
                              }),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            "Transactions & Payments".tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                                fontFamily: 'Inter'),
                          ),
                          SizedBox(height: 1.h,),
                          ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: faqList.length,
                              itemBuilder: (context, index) {
                                return FAQWidget(
                                  faq: faqTnxPay[index],
                                );
                              }),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            "Payouts & Withdrawals".tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                                fontFamily: 'Inter'),
                          ),
                          SizedBox(height: 1.h,),
                          ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: faqList.length,
                              itemBuilder: (context, index) {
                                return FAQWidget(
                                  faq: faqPaywithdraw[index],
                                );
                              }),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            "Connected Web3 Applications".tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                                fontFamily: 'Inter'),
                          ),
                          SizedBox(height: 1.h,),
                          ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: faqList.length,
                              itemBuilder: (context, index) {
                                return FAQWidget(
                                  faq: faqConnection[index],
                                );
                              }),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            "Compliance & Security".tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                                fontFamily: 'Inter'),
                          ),
                          SizedBox(height: 1.h,),
                          ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: faqList.length,
                              itemBuilder: (context, index) {
                                return FAQWidget(
                                  faq: faqCompilanceSecurity[index],
                                );
                              }),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            "Support & Troubleshooting".tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 17.sp,
                                fontFamily: 'Inter'),
                          ),
                          SizedBox(height: 1.h,),
                          ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: faqList.length,
                              itemBuilder: (context, index) {
                                return FAQWidget(
                                  faq: faqSupport[index],
                                );
                              }),
                          SizedBox(height:5.h),
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
  }

  Widget supportWidget({bool isDark = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 1.h,
        ),
        Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin ultrices arcu.",
          style: TextStyle(
              color: AppColors.textColorGreyShade2,
              fontWeight: FontWeight.w400,
              fontSize: 11.7.sp,
              fontFamily: 'Inter'),
        ),
        SizedBox(
          height: 2.h,
        ),
        Text(
          "Lorem ipsum dolor sit amet, consect.",
          style: TextStyle(
              color:
                  isDark ? AppColors.textColorWhite : AppColors.textColorBlack,
              fontWeight: FontWeight.w400,
              fontSize: 11.7.sp,
              fontFamily: 'Inter'),
        ),
        SizedBox(
          height: 1.h,
        ),
        Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Eget volutpat quis id ullamcorper porttitor magna ultricies. Eu id faucibus eu, id arcu. Facilisis felis, sagittis, fringilla faucibus neque. Elementum, enim, molestie at urna sed consectetur pellentesque molestie dolor. Et est eget faucibus nulla non.",
          style: TextStyle(
              color: AppColors.textColorGreyShade2,
              fontWeight: FontWeight.w400,
              fontSize: 10.2.sp,
              fontFamily: 'Inter'),
        ),
      ],
    );
  }
}
