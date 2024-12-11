import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/screens/signup_signin/signin_with_mobile.dart';
import 'package:hesa_wallet/screens/signup_signin/signup_with_mobile.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';
import 'package:flutter/services.dart';


class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  var _isLoading = false;


  @override
  void initState() {
    super.initState();
    _updateStatusBar();
  }
  void _updateStatusBar() {
    final themeNotifier = Provider.of<ThemeProvider>(context, listen: false);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: themeNotifier.isDark
            ? AppColors.backgroundColor
            : AppColors.textColorWhite,
        statusBarIconBrightness: themeNotifier.isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

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
                  color:
                  themeNotifier.isDark
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

                      child:
                      ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            "assets/images/wallet_logo2.png",
                            fit: BoxFit.cover,
                            width: double.infinity,

                        ),
                      ),
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
                            'Hello Web3'.tr(),
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
                            'Your New Digital World'.tr(),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SigninWithMobile(),
                                ),
                              );
                            },
                            isGradient: false,
                              isGradientWithBorder: true,
                            color: AppColors.appSecondButton.withOpacity(0.10),
                            textColor: themeNotifier.isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack.withOpacity(0.8),
                          ),
                          SizedBox(height: isEnglish ? 1.h : 2.h),

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

}