import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_deep_linking.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';

class ConnectDapp extends StatefulWidget {
  static const routeName = 'connection-request';

  const ConnectDapp({Key? key}) : super(key: key);

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
    accessToken = prefs.getString('accessToken')!;
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
      _isLoading = true;
    });
    init();
    setState(() {
      _isLoading = false;
    });
    super.initState();
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
    final String base64String =
        Provider.of<TransactionProvider>(context, listen: false).logoFromNeo;
    final String siteUrl =
        Provider.of<TransactionProvider>(context, listen: false).siteUrl;
    Uint8List bytes = base64Decode(base64String);
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
                      height: 88.h,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.8.sp,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 4.h,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.5.sp),
                                child: Container(
                                  // color: Colors.red,
                                  height: 10.6.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.connectedSitesDialog,
                                    borderRadius: BorderRadius.circular(10),
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
                                          Image.memory(
                                            bytes,
                                            height: 5.h,
                                            width: 30.w,
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
                                            GestureDetector(
                                              onTap:()=>_launchURL(siteUrl),
                                              child: Container(
                                                width:40.w,
                                                child: Text(
                                                  siteUrl,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: themeNotifier.isDark
                                                          ? AppColors.bluishClr
                                                          : AppColors.textColorBlack,
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 0.5.h,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
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
                                          Image.memory(
                                            bytes,
                                            height: 5.h,
                                            width: 30.w,
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
                              SizedBox(
                                height: 2.h,
                              ),
                              // Expanded(child: SizedBox()),
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
                                        
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .navigateToNeoForConnectWallet = false;
                                  await Future.delayed(
                                      const Duration(seconds: 1));
                                  setState(() {
                                    _isLoading = false;
                                  });
                                        
                                  await AppDeepLinking().openNftApp(
                                    {
                                      "operation": "connectWallet",
                                      "response": 'Connection request rejected.'
                                    },
                                  );
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => WalletTokensNfts()),
                                        (Route<dynamic> route) => false,
                                  );
                                  // SystemNavigator.pop();
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
                                  await Future.delayed(
                                      const Duration(seconds: 1));
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      final screenWidth =
                                          MediaQuery.of(context).size.width;
                                      final dialogWidth = screenWidth * 0.85;
                                      Future<void>
                                          closeDialogAndNavigate() async {
                                        await Future.delayed(
                                            Duration(milliseconds: 100));
                                        Navigator.of(context).pop();
                                        await Future.delayed(
                                            Duration(milliseconds: 100));
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  WalletTokensNfts()),
                                        );
                                        await AppDeepLinking().openNftApp(
                                          {
                                            "operation": "connectWallet",
                                            "walletAddress":
                                                Provider.of<UserProvider>(context,
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
                                                'Wallet connected successfully'
                                          },
                                        );
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.setString(
                                            'siteUrl',  Provider.of<TransactionProvider>(context,listen: false).siteUrl);
                                        await prefs.setString(
                                            'logoFromNeo',  Provider.of<TransactionProvider>(context,listen: false).logoFromNeo);
                                        await prefs.setString('connectionTime',
                                            DateTime.now().toString());
                                        await  prefs.setBool('isConnected', true);
                                      }
                                        
                                      Future.delayed(Duration(milliseconds: 1500),
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
                                                      ? 38.h
                                                      : 38.h,
                                              width: dialogWidth,
                                              decoration: BoxDecoration(
                                                color: themeNotifier.isDark
                                                    ? AppColors.showDialogClr
                                                    : AppColors.textColorWhite,
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
                                                    child:  Image.memory(
                                                      bytes,
                                                      height: 5.h,
                                                      width: 30.w,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
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
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 1.5.h,
                                                  ),
                                                    Container(
                                                      width:40.w,
                                                      child: Text(
                                                        siteUrl,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: themeNotifier
                                                                  .isDark
                                                              ? AppColors
                                                                  .textColorWhite
                                                                  .withOpacity(0.4)
                                                              : AppColors
                                                                  .textColorBlack
                                                                  .withOpacity(0.4),
                                                          fontSize: 10.2.sp,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                                                                      ),
                                                    ),
                                                  SizedBox(
                                                    height: 2.h,
                                                  ),
                                        
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 2.h,
                                                        height: 2.h,
                                                        decoration: BoxDecoration(
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
                                },
                                // isLoading:_isLoading,
                                isGradient: true,
                                color: Colors.transparent,
                                textColor: AppColors.textColorBlack,
                              ),
                              SizedBox(height: 10.h),
                            ],
                          ),
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
