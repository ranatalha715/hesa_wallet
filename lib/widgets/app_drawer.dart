import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/screens/settings/faq_&_support.dart';
import 'package:hesa_wallet/screens/settings/settings.dart';
import 'package:hesa_wallet/screens/user_profile_pages/connected_sites.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_banking_and_payment_empty.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_deep_linking.dart';
import '../constants/configs.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../screens/signup_signin/wallet.dart';
import '../screens/user_profile_pages/wallet_activity.dart';
import 'button.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var selectedIndex = -1;
  var isLoading = false;
  var accessToken = '';
  var refreshToken = '';
  bool showCopiedMsg = false;
  bool _isPasscodeSet = false;
  bool isConnected=false;

  getaccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    refreshToken = prefs.getString('refreshToken')!;
  }

  getPasscode() async {
    print('printing');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final passcode = prefs.getString('passcode')!;
    if (passcode != "" || passcode != null) {
      _isPasscodeSet = true;
    } else {
      _isPasscodeSet = false;
    }
    print("ispasscodeset" + _isPasscodeSet.toString());
  }

  deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
    prefs.remove('refreshToken');
    prefs.remove('siteUrl');
    prefs.remove('isConnected');
  }

  String replaceMiddleWithDots(String input) {
    if (input.length <= 30) {
      return input;
    }
    final int middleIndex = input.length ~/ 2;
    final int startIndex = middleIndex - 16;
    final int endIndex = middleIndex + 16;
    final String result =
        input.substring(0, startIndex) + '...' + input.substring(endIndex);
    return result;
  }

  init() async {
    await getaccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    await getPasscode();
    final prefs = await SharedPreferences.getInstance();
    isConnected = prefs.getBool("isConnected") ?? false;

  }

  @override
  void initState() {
    // TODO: implement initState
    init();
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.profileHeaderDark,
    ));
  }

  @override
  void dispose() {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: AppColors.profileHeaderDark, // Reset to default color
    // ));
    // TODO: implement dispose
    super.dispose();
  }

  void _launchURL() async {
    final Uri url = Uri.parse('https://hesa-wallet.com/about-us');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final isEmailVerified =
        Provider.of<UserProvider>(context, listen: false).isEmailVerified;
    return Consumer<UserProvider>(builder: (context, user, child) {
      return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Drawer(
            width: 90.w,
            child: Container(
              color: themeNotifier.isDark
                  ? AppColors.backgroundColor
                  : AppColors.textColorWhite,
              child: Column(
                children: [
                  Container(
                    height: 42.h,
                    // color: Colors.blue,
                    // color: themeNotifier.isDark
                    //     ? AppColors.backgroundColor
                    //     : AppColors.textColorWhite,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // SizedBox(
                          //   height: 8.h,
                          // ),
                          Container(
                            child: Image.asset(
                              "assets/images/hesalogo_text.png",
                              height: 21.h,
                              width: 22.h,
                            ),
                          ),
                          Expanded(
                              child: Container(
                            width: double.infinity,
                          )),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.textColorGrey,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(1.sp),
                              child: Container(
                                height: 58.sp,
                                width: 58.sp,
                                decoration: BoxDecoration(
                                    // color: Colors.red,
                                    color: AppColors.backgroundColor,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Padding(
                                  padding: EdgeInsets.all(1.sp),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: user.userAvatar != null
                                        ? Image.network(
                                            user.userAvatar!,
                                            // height: 55.sp,
                                            // width: 55.sp,
                                            fit: BoxFit.cover,
                                          )
                                        : Padding(
                                            padding: EdgeInsets.all(4.sp),
                                            child: Image.asset(
                                              "assets/images/user_placeholder.png",
                                              // height: 55.sp,
                                              // width: 55.sp,
                                              color: AppColors.textColorGrey,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 1.5.h,
                          ),
                          Text(
                            user.userName != null
                                ? user.userName!
                                : 'username.mjra'.tr(),
                            // 'username.mjra'.tr(),
                            style: TextStyle(
                                fontSize: 11.7.sp,
                                fontFamily: 'Blogger Sans',
                                fontWeight: FontWeight.w700,
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.tabColorlightMode
                                // AppColors.textColorBlack
                                ),
                          ),
                          SizedBox(
                            height: 0.5.h,
                          ),
                          GestureDetector(
                            onTap: () => _copyToClipboard(user.walletAddress!),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  user.walletAddress != null
                                      ? replaceMiddleWithDots(
                                          user.walletAddress!)
                                      : "...",
                                  style: TextStyle(
                                      fontSize: 9.5.sp,
                                      fontFamily: 'Blogger Sans',
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColorGrey),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.copy,
                                  size: 10.sp,
                                  color: AppColors.textColorGrey,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 51.h,
                    color: themeNotifier.isDark
                        ? AppColors.drawerOptBackgroundClr
                        : AppColors.drawerDividerlightColor.withOpacity(0.35),
                    // color: Colors.transparent,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // SizedBox(height: 0.2.h,),
                          drawerWidget(
                            title: 'Payments & Banking'.tr(),
                            imagePath: "assets/images/draweroption1.png",
                            imageHeight: 3.2.h,
                            imageWidth: 2.8.h,
                            isDark: themeNotifier.isDark ? true : false,
                            index: 0,
                            handler: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        WalletBankingAndPaymentEmpty()),
                              );
                            },
                          ),
                          drawerWidget(
                              title: 'Activity'.tr(),
                              imagePath: "assets/images/draweroption2.png",
                              imageHeight: 2.4.h,
                              imageWidth: 2.4.h,
                              isDark: themeNotifier.isDark ? true : false,
                              index: 1,
                              handler: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WalletActivity()),
                                );
                              }),
                          drawerWidget(
                              title: 'Connected Apps'.tr(),
                              imagePath: "assets/images/draweroption3.png",
                              imageHeight: 2.8.h,
                              imageWidth: 2.8.h,
                              isDark: themeNotifier.isDark ? true : false,
                              index: 2,
                              handler: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ConnectedSites()),
                                );
                              }),
                          Stack(children: [
                            drawerWidget(
                                title: 'Settings'.tr(),
                                imagePath: "assets/images/draweroption4.png",
                                imageHeight: 2.8.h,
                                imageWidth: 2.8.h,
                                isDark: themeNotifier.isDark ? true : false,
                                index: 3,
                                handler: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Settings()),
                                  );
                                }),
                            if (isEmailVerified != 'true' && !_isPasscodeSet)
                              Positioned(
                                right: isEnglish ? 20 : null,
                                left: isEnglish ? null : 20,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  // color: Colors.yellow,
                                  child: Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/images/warning.png",
                                          color: AppColors.errorColor,
                                          height: 2.2.h,
                                          width: 2.2.h,
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        Text(
                                          'Unprotected'.tr(),
                                          style: TextStyle(
                                              color: selectedIndex == 3
                                                  ? AppColors.errorColor
                                                  : !themeNotifier.isDark
                                                      ? AppColors
                                                          .tabColorlightMode
                                                      : AppColors
                                                          .textColorGreyShade2,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 9.3.sp,
                                              fontFamily: 'Inter'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                          ]),
                          drawerWidget(
                              title: 'FAQ & Support'.tr(),
                              imagePath: "assets/images/draweroption5.png",
                              imageHeight: 2.8.h,
                              imageWidth: 2.8.h,
                              isDark: themeNotifier.isDark ? true : false,
                              index: 4,
                              handler: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FAQAndSupport()),
                                );
                              }),
                          drawerWidget(
                            title: 'About HesaWallet'.tr(),
                            imagePath: "assets/images/draweroption6.png",
                            imageHeight: 2.9.h,
                            imageWidth: 2.9.h,
                            isDark: themeNotifier.isDark ? true : false,
                            index: 5,
                            handler: (){ Navigator.pop(context);
                              _launchURL();
                              },
                          ),
                          drawerWidget(
                            title: 'Logout'.tr(),
                            imagePath: "assets/images/draweroption7.png",
                            imageHeight: 2.9.h,
                            imageWidth: 2.9.h,
                            isDark: themeNotifier.isDark ? true : false,
                            index: 6,
                            isLast: true,
                            handler: () {
                              // Navigator.pop(context);
                              logOutFunction(themeNotifier.isDark);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: Stack(
                    children: [
                      Container(
                        // margin: EdgeInsets.only(top: 1.sp),
                        width: double.infinity,
                        // color: Colors.teal,
                        color: AppColors.drawerOptBackgroundClr,
                        child: Column(
                          children: [
                            Expanded(
                              child: SizedBox(),
                            ),
                            Text(
                              'Version 1.0.0'.tr(),
                              style: TextStyle(
                                  color: AppColors.textColorGrey,
                                  fontSize: 8.7.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                            // FooterText(
                            //   textcolor: themeNotifier.isDark
                            //       ? AppColors.textColorGrey
                            //       : AppColors.tabColorlightMode,
                            // ),
                            SizedBox(
                              height: 3.h,
                            )
                          ],
                        ),
                      ),
                      if (showCopiedMsg)
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 20,
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 4.h,
                              width: 35.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.sp),
                                color: AppColors.profileHeaderDark,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Address copied!',
                                    style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColorWhite,
                                        fontFamily: 'Blogger Sans'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
                  ))
                ],
              ),
            ),
          ),
        );
      });
    });
  }

  Widget drawerWidget({
    required String title,
    required String imagePath,
    required double imageHeight,
    required double imageWidth,
    required int index,
    required Function handler,
    bool isDark = true,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        print(index);
        print(selectedIndex);

        Future.delayed(Duration(milliseconds: 250), () {
          handler();
        });
      },
      child: Container(
        // margin: EdgeInsets.only(
        //     top: isDark ? 1.sp : 0.5.sp, bottom: isLast ? 0 : 0),
        height: 7.5.h,
        decoration: BoxDecoration(color: AppColors.drawerOptBackgroundClr
            // gradient: LinearGradient(
            //   colors: [
            //     index == selectedIndex
            //         ? Color(0xff92B928)
            //         : isDark
            //             ? AppColors.drawerOptBackgroundClr
            //             : AppColors.textColorWhite,
            //     index == selectedIndex
            //         ? Color(0xffC9C317)
            //         : isDark
            //             ? AppColors.drawerOptBackgroundClr
            //             : AppColors.textColorWhite
            //   ],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
            ),
        // color: index == selectedIndex ? Colors.yellow:AppColors.textColorWhite.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Colors.transparent,
                height: 3.h,
                width: 3.h,
                child: Image.asset(
                  imagePath,
                  color: index == selectedIndex
                      ? AppColors.hexaGreen
                      : isDark
                          ? AppColors.textColorWhite
                          : AppColors.tabColorlightMode,
                  // AppColors.textColorBlack,
                  fit: BoxFit.cover,
                  // height: imageHeight,
                  // width: imageWidth,
                ),
              ),
              SizedBox(
                width: 5.w,
              ),
              Text(
                title,
                style: TextStyle(
                    color: index == selectedIndex
                        ? AppColors.hexaGreen
                        : isDark
                            ? AppColors.textColorWhite
                            : AppColors.tabColorlightMode,
                    // AppColors.textColorBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.7.sp,
                    fontFamily: 'Inter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  logOutFunction(bool isDark) {
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
                  height: 35.h,
                  width: dialogWidth,
                  decoration: BoxDecoration(
                    // border: Border.all(
                    //     width: 0.1.h, color: AppColors.textColorGrey),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4.h,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        child: Text(
                          'Are you sure you want to log out?'.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                              color: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack),
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      // Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: AppButton(
                          title: 'Log out'.tr(),
                          handler: () async {
                            // if (isLoading) return;

                            try {
                              setState(() {
                                isLoading = true;
                              });
                              final resultLogout =
                                  await Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .logoutUser(
                                          token: accessToken,
                                          refreshToken: refreshToken,
                                          context: context);

                              setState(() {
                                isLoading = false;
                              });
                              if (resultLogout == AuthResult.success) {
                                print('printing navigator');
                                await deleteToken();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Wallet(),
                                  ),
                                  (route) =>
                                      false,
                                );
                                await AppDeepLinking().openNftApp(
                                  {
                                    "operation": "disconnectWallet",
                                    "walletAddress": Provider.of<UserProvider>(
                                            context,
                                            listen: false)
                                        .walletAddress,
                                    "userName": Provider.of<UserProvider>(
                                            context,
                                            listen: false)
                                        .userName,
                                    "userIcon": Provider.of<UserProvider>(
                                            context,
                                            listen: false)
                                        .userAvatar,
                                    "response":
                                        'Wallet disconnected successfully'
                                  },
                                );
                              } else {
                                print('Logout Failed');
                              }
                            } catch (error) {
                              print("Error: $error");
                              // _showToast('An error occurred'); // Show an error message
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          isLoading: isLoading,
                          isGradient: false,
                          color:
                              AppColors.deleteAccountBtnColor.withOpacity(0.10),
                          textColor: AppColors.textColorBlack,
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
                      Expanded(child: SizedBox()),
                    ],
                  ),
                )),
          );
        });
      },
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      showCopiedMsg = true;
    });
    Future.delayed(Duration(milliseconds: 3000), () {
      setState(() {
        showCopiedMsg = false;
      });
    });
    // fToast = FToast();
    // fToast.init(context);
  }
}
