import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/screens/user_profile_pages/connected_sites.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/app_deep_linking.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../signup_signin/signin_with_email.dart';
import '../signup_signin/terms_conditions.dart';

class ConnectDapp extends StatefulWidget {
  static const routeName = 'connection-request';
  final Function? disconnectHandler;

  const ConnectDapp({Key? key, this.disconnectHandler}) : super(key: key);

  @override
  State<ConnectDapp> createState() => _ConnectDappState();
}

class _ConnectDappState extends State<ConnectDapp> {
  var wstoken = "";
  var accessToken = "";
  bool _isLoading = false;

  List<String> accountDefinitions = [
    'Wallet Public ID'.tr(),
    'Username'.tr(),
    'Display icon'.tr(),
    'NFTs and Collections (owned/created)'.tr(),
    'Wallet activity (specific to the App)'.tr(),
    'Email'.tr(),
  ];

  List<String> accountDefinitions2 = [
    'Send transaction requests'.tr(),
    'Send payment requests'.tr(),
  ];

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    // wstoken = prefs.getString('wsToken')!;
    accessToken = prefs.getString('accessToken')!;
    // print(wstoken);
    print(accessToken);
  }

  init() async {
    await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
  }

  @override
  void initState() {
    setState(() {
      _isLoading=true;
    });
    init();
    setState(() {
      _isLoading=false;
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    return Consumer<UserProvider>(builder: (context, user, child) {
      return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: themeNotifier.isDark
                  ? AppColors.backgroundColor
                  : AppColors.textColorWhite,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    MainHeader(
                      title: 'Connection Request'.tr(),
                      handler: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WalletTokensNfts()),
                      ),
                      showBackBtn: false,
                    ),
                    Container(
                      height: 85.h,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.8.sp,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 4.h,
                            ),
                            // Text(
                            //   "Connect to this site?".tr(),
                            //   style: TextStyle(
                            //       color: themeNotifier.isDark ? AppColors.textColorWhite : AppColors.textColorBlack
                            //       ,
                            //       fontWeight: FontWeight.w600,
                            //       fontSize: 17.5.sp,
                            //       fontFamily: 'Inter'),
                            // ),
                            // SizedBox(
                            //   height: 1.h,
                            // ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.5.sp),
                              child: Container(
                                // color: Colors.red,
                                height: 10.6.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.connectedSitesDialog,
                                  borderRadius: BorderRadius.circular(10),
                                  // border: Border.all(
                                  //     color: AppColors.textColorGrey,
                                  //     width: 1)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        currentLocale.languageCode == 'en'
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.end,
                                    children: [
                                      if (currentLocale.languageCode == 'en')
                                        Image.asset(
                                          "assets/images/neo.png",
                                          height: 5.5.h,
                                          // width: 104,
                                        ),
                                      if (currentLocale.languageCode == 'en')
                                        SizedBox(
                                          width: 15,
                                        ),
                                      Column(
                                        crossAxisAlignment:
                                            currentLocale.languageCode == 'en'
                                                ? CrossAxisAlignment.start
                                                : CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'https://neonft.com',
                                            style: TextStyle(
                                                color: themeNotifier.isDark
                                                    ? AppColors.bluishClr
                                                    : AppColors.textColorBlack,
                                                fontSize: 12.5.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: 0.5.h,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Icon(
                                              //   Icons.fiber_manual_record,
                                              //   size: 7.sp,
                                              //   color: AppColors
                                              //       .textColorGreen,
                                              // ),
                                              // SizedBox(width: 1.w,),
                                              Text(
                                                'Chain: MJR-B01'.tr(),
                                                style: TextStyle(
                                                    color: themeNotifier.isDark
                                                        ? AppColors
                                                            .textColorWhite
                                                        : AppColors
                                                            .textColorBlack,
                                                    fontSize: 10.sp,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
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
                                      // SizedBox(
                                      //   width: 15,
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Text(
                              "This App has requested to connect with your wallet. Always make sure you trust this site before connecting."
                                  .tr(),
                              style: TextStyle(
                                  color: AppColors.textColorWhite,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11.7.sp,
                                  fontFamily: 'Inter'),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Text(
                              "Information that site will utilize:".tr(),
                              style: TextStyle(
                                  color: AppColors.textColorWhite,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                  fontFamily: 'Inter'),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            ListView.builder(
                              padding: EdgeInsets.only(left: 20.sp),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: accountDefinitions.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 4.0, right: 8.0),
                                      child: Icon(
                                        Icons.fiber_manual_record,
                                        size: 7.sp,
                                        color: AppColors.textColorWhite,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 3),
                                        child: Text(
                                          accountDefinitions[index],
                                          style: TextStyle(
                                              color: AppColors.textColorWhite,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.2.sp,
                                              fontFamily: 'Inter'),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Text(
                              "Functionalities that site will be able to request:"
                                  .tr(),
                              style: TextStyle(
                                  color: AppColors.textColorWhite,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                  fontFamily: 'Inter'),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            ListView.builder(
                              padding: EdgeInsets.only(left: 20.sp),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: accountDefinitions2.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 4.0, right: 8.0),
                                      child: Icon(
                                        Icons.fiber_manual_record,
                                        size: 7.sp,
                                        color: AppColors.textColorWhite,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 3),
                                        child: Text(
                                          accountDefinitions2[index],
                                          style: TextStyle(
                                              color: AppColors.textColorWhite,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.2.sp,
                                              fontFamily: 'Inter'),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            Expanded(child: SizedBox()),
                            Text(
                              "If you did not attempt to connect to this wallet please  REJECT this request."
                                  .tr(),
                              style: TextStyle(
                                  color: AppColors.errorColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10.sp,
                                  fontFamily: 'Inter'),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),

                            AppButton(
                              title: 'Reject'.tr(),
                              handler: () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                Provider.of<UserProvider>(context, listen: false)
                                    .navigateToNeoForConnectWallet=false;
                                await Future.delayed(const Duration(seconds: 1));
                                setState(() {
                                  _isLoading = false;
                                });

                                await AppDeepLinking().openNftApp(
                                  {
                                    "operation": "connectWallet",
                                    "response": 'Connection request rejected.'
                                  },
                                );

                                await Future.delayed(const Duration(milliseconds: 500));
                                await Restart.restartApp();

                              },
                              isGradientWithBorder: true,
                              buttonWithBorderColor: AppColors.errorColor,
                              color: AppColors.deleteAccountBtnColor
                                  .withOpacity(0.10),
                              isGradient: false,
                              textColor: themeNotifier.isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack.withOpacity(0.8),

                            ),
                            SizedBox(height: 2.h),
                            AppButton(
                              title: 'Connect'.tr(),
                              handler: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                var result = await Provider.of<UserProvider>(
                                        context,
                                        listen: false)
                                    .connectDapps(
                                        siteUrl: 'https://neonft.com',
                                        // siteUrl: 'https://instagram.com',
                                        token: accessToken,
                                        context: context);
                                setState(() {
                                  _isLoading = false;
                                });
                                if (result == AuthResult.success) {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      final screenWidth =
                                          MediaQuery.of(context).size.width;
                                      final dialogWidth = screenWidth * 0.85;
                                      Future<void> closeDialogAndNavigate() async {
                                        // Pop the dialog
                                        // Navigator.of(context).pop();
                                        // Add a short delay before the next pop
                                        await Future.delayed(Duration(milliseconds: 100));
                                        // Pop the previous screen
                                        Navigator.of(context).pop();
                                        // Add another short delay before pushing the new route
                                        await Future.delayed(Duration(milliseconds: 100));
                                        // Push the new route
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => WalletTokensNfts()),
                                        );
                                        await AppDeepLinking().openNftApp(
                                          {
                                            "operation": "connectWallet",
                                            "walletAddress":
                                                Provider.of<UserProvider>(
                                                        context,
                                                        listen: false)
                                                    .walletAddress,
                                            "userName":
                                                Provider.of<UserProvider>(
                                                        context,
                                                        listen: false)
                                                    .userName,
                                            "userIcon":
                                                Provider.of<UserProvider>(
                                                        context,
                                                        listen: false)
                                                    .userAvatar,
                                            "response":
                                                'Wallet connected successfully'
                                          },
                                        );
                                      }

                                      Future.delayed(
                                          Duration(milliseconds: 1500),
                                          closeDialogAndNavigate);
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 7, sigmaY: 7),
                                            child: Container(
                                              height:
                                                  currentLocale.languageCode ==
                                                          'en'
                                                      ? 35.h
                                                      : 35.h,
                                              width: dialogWidth,
                                              decoration: BoxDecoration(
                                                color: themeNotifier.isDark
                                                    ? AppColors.showDialogClr
                                                    : AppColors.textColorWhite,
                                                // border: Border.all(
                                                //     width: 0.1.h,
                                                //     color: AppColors
                                                //         .textColorGrey
                                                // ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 5.h,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Image.asset(
                                                      "assets/images/neo.png",
                                                      height: 6.h,
                                                      // width: 104,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 50),
                                                    child: Text(
                                                      'Connected to NEO NFT Market'
                                                          .tr(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 17.5.sp,
                                                          color: themeNotifier
                                                                  .isDark
                                                              ? AppColors
                                                                  .textColorWhite
                                                              : AppColors
                                                                  .textColorBlack),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 1.5.h,
                                                  ),
                                                  Text(
                                                    'http://neonft.com',
                                                    style: TextStyle(
                                                        color: themeNotifier
                                                                .isDark
                                                            ? AppColors
                                                                .textColorWhite
                                                                .withOpacity(
                                                                    0.4)
                                                            : AppColors
                                                                .textColorBlack
                                                                .withOpacity(
                                                                    0.4),
                                                        fontSize: 10.2.sp,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  SizedBox(
                                                    height: 2.h,
                                                  ),

                                                  // Row(
                                                  //   crossAxisAlignment: CrossAxisAlignment
                                                  //       .center,
                                                  //   mainAxisAlignment: MainAxisAlignment
                                                  //       .center,
                                                  //   children: [
                                                  //     Icon(
                                                  //       Icons
                                                  //           .fiber_manual_record,
                                                  //       size: 5.sp,
                                                  //       color: AppColors
                                                  //           .textColorGreen,
                                                  //     ),
                                                  //     SizedBox(width: 1.w,),
                                                  //     Text(
                                                  //       'MJRA-B01'.tr(),
                                                  //       style: TextStyle(
                                                  //           color: themeNotifier
                                                  //               .isDark
                                                  //               ? AppColors
                                                  //               .textColorWhite
                                                  //               .withOpacity(
                                                  //               0.4)
                                                  //               : AppColors
                                                  //               .textColorBlack
                                                  //               .withOpacity(
                                                  //               0.4),
                                                  //           fontSize: 10.sp,
                                                  //           fontWeight: FontWeight
                                                  //               .w400),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                  // SizedBox(height: 2.h,),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 2.h,
                                                        height: 2.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          border: Border.all(
                                                              color: AppColors
                                                                  .textColorGreen),
                                                        ),
                                                        child: Icon(
                                                          Icons.check_rounded,
                                                          size: 10,
                                                          color: AppColors
                                                              .textColorGreen,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 2.w,
                                                      ),
                                                      Text(
                                                        'Connected'.tr(),
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textColorGreen,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                        ),
                                                      )
                                                    ],
                                                  ),

                                                  SizedBox(
                                                    height: 2.h,
                                                  ),
                                                ],
                                              ),
                                            )),
                                      );
                                    },
                                  );
                                }
                                ;
                                // else{
                                //
                                // }
                              },
                              // isLoading:_isLoading,
                              isGradient: true,
                              color: Colors.transparent,
                              textColor: AppColors.textColorBlack,
                            ),

                            // SizedBox(
                            //   height: 3.h,
                            // )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading) LoaderBluredScreen()
          ],
        );
      });
    });
  }
}
