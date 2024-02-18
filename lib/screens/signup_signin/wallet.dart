import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/constants/footer_text.dart';
import 'package:hesa_wallet/screens/signup_signin/signin_with_mobile.dart';
import 'package:hesa_wallet/screens/signup_signin/signup_with_mobile.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';

class Wallet extends StatefulWidget {
   const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  var _isLoading = false;


  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                Container(
                  height: 60.h,
                  color: themeNotifier.isDark
                      ? AppColors.backgroundColor
                      : AppColors.textColorWhite,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 70),
                    child: Container(
                      decoration: BoxDecoration(
                          color: themeNotifier.isDark
                              ? AppColors.textColorWhite.withOpacity(0.05)
                              : AppColors.backgroundColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(22)),
                      // child: Align(
                      //   alignment: Alignment.center,
                      //   child: Image.asset(
                      //     "assets/images/hesa_wallet_logo.png",
                      //     height: 13.8.h,
                      //     width: 13.8.h,
                      //   ),
                      // ),
                    ),
                  ),
                ),
                Container(
                  height: 40.h,
                  width: double.infinity,
                  color: themeNotifier.isDark
                      ? AppColors.backgroundColor
                      : AppColors.textColorWhite,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            'Hello Web3 KSA'.tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 25.sp,
                                fontFamily: 'Blogger Sans'),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Your Digital World Secured'.tr(),
                            style: TextStyle(
                                fontSize: 11.7.sp,
                                color: AppColors.textColorGrey,
                                fontWeight: FontWeight.w400, // Off-white color,
                                fontFamily: 'Inter'),
                          ),
                          SizedBox(height: 5.h),
                          AppButton(
                              title: 'Create a Wallet'.tr(),
                              handler: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await Future.delayed(Duration(milliseconds: 1500),
                                        (){});
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupWithMobile(),
                                  ),
                                );
                              },
                              isGradient: true,
                              color: Colors.transparent),
                          SizedBox(height: 2.h),
                          AppButton(
                            title: 'I already have an account'.tr(),
                            handler: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await Future.delayed(Duration(milliseconds: 1500),
                                      (){});
                              setState(() {
                                _isLoading = false;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SigninWithMobile(),
                                ),
                              );
                            },
                            isGradient: false,
                            color: AppColors.appSecondButton.withOpacity(0.10),
                            textColor: themeNotifier.isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack.withOpacity(0.8),
                          ),
                          SizedBox(height: isEnglish ? 5.h : 2.h),
                          // Expanded(
                          //   child: SizedBox(
                          //     // height: 4.h,
                          //   ),
                          // ),
                          // Text(
                          //   'Powered by'.tr(),
                          //   style: TextStyle(
                          //       color: AppColors.textColorGrey,
                          //       fontSize: 8.7.sp,
                          //       fontWeight: FontWeight.w400),
                          // ),
                          // FooterText(),
                          SizedBox(
                            height: isEnglish ? 2.h : 3.h,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(_isLoading)
            LoaderBluredScreen()
        ],
      );
    });
  }



}
