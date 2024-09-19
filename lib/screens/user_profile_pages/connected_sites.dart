import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/user_provider.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/button.dart';
import 'package:hesa_wallet/widgets/dialog_button.dart';
import 'dart:io' as OS;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../constants/app_deep_linking.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/main_header.dart';

class ConnectedSites extends StatefulWidget {
  const ConnectedSites({Key? key}) : super(key: key);

  @override
  State<ConnectedSites> createState() => _ConnectedSitesState();
}

class _ConnectedSitesState extends State<ConnectedSites> {
  var isDisconnected = false;
  var accessToken = "";
  bool isLoading = false;
  bool _isInit = true;
  String? lastConnectedSite;

  // bool _isFirstVisit = true;
  bool showConnectionPopup = false;
  bool showDisconnectionPopup = false;
  var siteUrl;
  var logoFromNeo;
  bool isConnected=false;
  late Uint8List bytes;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
    print(accessToken);
  }

  init() async {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(seconds: 3), () {});
    await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    final prefs = await SharedPreferences.getInstance();
    siteUrl = await prefs.getString("siteUrl");
    logoFromNeo = await prefs.getString("logoFromNeo");


     bytes = base64Decode(logoFromNeo);
    isConnected = await prefs.getBool("isConnected") ?? false;
    print('siteUrl locally');
    print(prefs.getString("siteUrl"));
    setState(() {
      lastConnectedSite = siteUrl;
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _checkFirstVisit() async {
    print('checking popup');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasVisited = prefs.getBool('hasVisited') ?? false;

    if (!hasVisited
        && lastConnectedSite != null
        ) {
      showConnectionPopup = true;
      print('showConnectionPopup' + showConnectionPopup.toString());
      prefs.setBool('hasVisited', true);

      Timer(const Duration(seconds: 3), () {
        setState(() {
          showConnectionPopup = false;
        });
        print('showConnectionPopup2' + showConnectionPopup.toString());
      });
    }
    print('checking popup2');
  }

  Future<void> _checkFirstDisconnectionVisit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasVisitedDisconnection =
        prefs.getBool('hasVisitedDisconnection') ?? false;

    if (!hasVisitedDisconnection) {
      setState(() {
        showDisconnectionPopup = true;
      });
      prefs.setBool('hasVisitedDisconnection', true);

      // Set a timer to hide the popup after 3 seconds
      Timer(Duration(seconds: 1), () {
        setState(() {
          showDisconnectionPopup = false;
        });
      });
    }
  }

  @override
  void initState() {
    // init();
    // _checkFirstVisit();
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_isInit) {
      // setState(() {
      //   isLoading = true;
      //
      //   // showConnectionPopup = true;
      // });
      await init();
      await _checkFirstVisit();
      await _checkFirstDisconnectionVisit();


      // await Provider.of<UserProvider>(context, listen: false)
      //     .getUserDetails(token: accessToken, context: context);

      // setState(() {
      //   isLoading = false;
      // });

      // Future.delayed(Duration(seconds: 3), () {}).then((value) => setState(() {
      //       showConnectionPopup = false;
      //     }));
    }
    _isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final connectedSites =
        Provider.of<UserProvider>(context, listen: false).connectedSites;

    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(title: 'Connected Apps'.tr()),
                SizedBox(
                  height: 3.h,
                ),
                // if (connectedSites.isEmpty)
                //   Padding(
                //     padding: EdgeInsets.only(top: 20.h),
                //     child: Text(
                //       "You are not connected to any apps.",
                //       style: TextStyle(
                //           color: themeNotifier.isDark
                //               ? AppColors.textColorGreyShade2
                //               : AppColors.textColorBlack,
                //           fontWeight: FontWeight.w500,
                //           fontSize: 12.sp,
                //           fontFamily: 'Blogger Sans'),
                //     ),
                //   ),

                isConnected
                    ? ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                            ),
                            child: Dismissible(
                              dismissThresholds: const {
                                DismissDirection.endToStart: 0.1
                              },
                              key: Key("0"),
                              // Use a unique key for each item
                              // direction: isEnglish ?  DismissDirection.endToStart : DismissDirection.startToEnd,
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) {
                                return showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final screenWidth =
                                        MediaQuery.of(context).size.width;
                                    final dialogWidth = screenWidth * 0.85;
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
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
                                              height: 48.h,
                                              width: dialogWidth,
                                              decoration: BoxDecoration(
                                                color: themeNotifier.isDark
                                                    ? AppColors.showDialogClr
                                                    : AppColors.textColorWhite,
                                                // border: Border.all(
                                                //     width: 0.1.h,
                                                //     color: AppColors.textColorGrey),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.sp),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 5.h,
                                                    ),
                                                    Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Image.asset(
                                                        "assets/images/disconnect.png",
                                                        height: 5.h,
                                                        color: AppColors
                                                            .textColorWhite,
                                                        // width: 104,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5.h),
                                                    Text(
                                                      'Are you sure you want to disconnect from this App?'
                                                          .tr(),
                                                      textAlign:
                                                          TextAlign.center,
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
                                                    ),
                                                    SizedBox(
                                                      height: 2.h,
                                                    ),
                                                    Text(
                                                      siteUrl,
                                                      // 'https://opensea.io',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .textColorWhite
                                                              .withOpacity(0.4),
                                                          fontSize: 10.2.sp,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    Spacer(),
                                                    DialogButton(
                                                      title: 'Disconnect'.tr(),
                                                      textColor:
                                                          AppColors.errorColor,
                                                      handler: () async {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        await _checkFirstDisconnectionVisit();

                                                        final prefs =
                                                        await SharedPreferences
                                                            .getInstance();


                                                        await prefs.setString('disconnectionTime', DateTime.now().toString());
                                                        await  prefs.setBool('isConnected', false);
                                                        Navigator.pop(
                                                            context);
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                  WalletTokensNfts()), // Pushes the new route
                                                        );// Pops the current route
                                                        await AppDeepLinking()
                                                            .openNftApp(
                                                          {
                                                            "operation":
                                                            "disconnectWallet",
                                                            "walletAddress":
                                                            Provider.of<UserProvider>(
                                                                context,
                                                                listen:
                                                                false)
                                                                .walletAddress,
                                                            "userName": Provider.of<
                                                                UserProvider>(
                                                                context,
                                                                listen:
                                                                false)
                                                                .userName,
                                                            "userIcon": Provider.of<
                                                                UserProvider>(
                                                                context,
                                                                listen:
                                                                false)
                                                                .userAvatar,
                                                            "response":
                                                            'Wallet disconnected successfully'
                                                          },
                                                        );
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                        Timer(
                                                            const Duration(
                                                                seconds: 4),
                                                            () async {



                                                        });
                                                        // var result = await Provider
                                                        //     .of<UserProvider>(
                                                        //     context,
                                                        //     listen: false)
                                                        //     .disconnectDapps(
                                                        //   siteUrl:
                                                        //   connectedSites[index]
                                                        //       .urls,
                                                        //   token: accessToken,
                                                        //   context: context,
                                                        // );

                                                        // Navigator.of(context)
                                                        //     .pop(true);

                                                        // if (result ==
                                                        //     AuthResult.success) {
                                                        // connectedSites.removeAt(index);
                                                        // lastConnectedSite = connectedSites.isNotEmpty ? connectedSites.last.urls : null;


                                                      },
                                                      isLoading: isLoading,
                                                      // isGradient: true,
                                                      color: AppColors
                                                          .appSecondButton
                                                          .withOpacity(0.10),
                                                    ),
                                                    SizedBox(
                                                      height: 2.h,
                                                    ),
                                                    AppButton(
                                                      title: 'Cancel'.tr(),
                                                      handler: () {
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      },
                                                      isGradient: false,
                                                      color: AppColors
                                                          .appSecondButton
                                                          .withOpacity(0.10),
                                                      textColor: themeNotifier
                                                              .isDark
                                                          ? AppColors
                                                              .textColorWhite
                                                          : AppColors
                                                              .textColorBlack
                                                              .withOpacity(0.8),
                                                    ),
                                                    Spacer(),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      );
                                    });
                                  },
                                );
                              },
                              onDismissed: (direction) {
                                setState(() {
                                  // connectedSites.removeAt(index);
                                });
                              },
                              background: Container(
                                height: 10.6.h,
                                margin: EdgeInsets.only(bottom: 10.sp),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: themeNotifier.isDark
                                      ? AppColors.tagFillClrDark
                                      // ? AppColors.textColorWhite.withOpacity(0.05)
                                      : AppColors.textColorGreyShade2
                                          .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  // border: Border.all(color: AppColors.textColorGrey, width: 1)
                                ),
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/disconnect.png",
                                        height: 2.h,
                                        width: 2.h,
                                      ),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      Text(
                                        'Disconnect'.tr(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 9.sp,
                                            color: AppColors.errorColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 10.6.h,
                                    margin: EdgeInsets.only(bottom: 10.sp),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.tagFillClrDark,
                                    ),
                                  ),
                                  Container(
                                    // margin: EdgeInsets.only(bottom: 15.sp),
                                    height: 10.6.h,
                                    margin: EdgeInsets.only(bottom: 10.sp),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.connectedSitesPopupsClr,
                                      borderRadius: BorderRadius.circular(10),
                                      // border:
                                      //     Border.all(color: AppColors.textColorGrey, width: 1)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Row(
                                        mainAxisAlignment: isEnglish
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.end,
                                        children: [
                                          if (currentLocale.languageCode ==
                                              'en')
                                            Image.memory(
                                              bytes,
                                              height: 5.h,
                                              width: 30.w,
                                            ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Container(
                                            width:40.w,
                                            child: Text(
                                              siteUrl,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              // "connectedSites[index].urls",
                                              // 'NEO NFT Market',
                                              style: TextStyle(
                                                  color: themeNotifier.isDark
                                                      ? AppColors.textColorWhite
                                                      : AppColors.textColorBlack,
                                                  fontSize: 10.5.sp,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          if (currentLocale.languageCode ==
                                              'ar')
                                            SizedBox(
                                              width: 15,
                                            ),
                                          if (currentLocale.languageCode ==
                                              'ar')
                                            Image.asset(
                                              "assets/images/neo.png",
                                              height: 5.5.h,
                                              // width: 104,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    : SizedBox(),
                // if (connectedSites.isNotEmpty)
                //   ListView.builder(
                //     shrinkWrap: true,
                //     padding: EdgeInsets.zero,
                //     itemCount: connectedSites.length,
                //     itemBuilder: (BuildContext context, int index) {
                //       lastConnectedSite = connectedSites.isNotEmpty
                //           ? connectedSites.last.urls
                //           : null;
                //
                //       return Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 25, ),
                //         child:Dismissible(
                //           dismissThresholds: const {DismissDirection.endToStart: 0.1},
                //           key: Key(index.toString()), // Use a unique key for each item
                //           // direction: isEnglish ?  DismissDirection.endToStart : DismissDirection.startToEnd,
                //           direction: DismissDirection.endToStart,
                //           confirmDismiss: (direction) {
                //             return showDialog(
                //               context: context,
                //               builder: (BuildContext context) {
                //                 final screenWidth =
                //                     MediaQuery.of(context).size.width;
                //                 final dialogWidth = screenWidth * 0.85;
                //                 return StatefulBuilder(builder:
                //                     (BuildContext context,
                //                         StateSetter setState) {
                //                   return Dialog(
                //                     shape: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(8.0),
                //                     ),
                //                     backgroundColor: Colors.transparent,
                //                     child: BackdropFilter(
                //                         filter: ImageFilter.blur(
                //                             sigmaX: 7, sigmaY: 7),
                //                         child: Container(
                //                           height: 48.h,
                //
                //                           width: dialogWidth,
                //                           decoration: BoxDecoration(
                //                             color: themeNotifier.isDark
                //                                 ? AppColors.showDialogClr
                //                                 : AppColors.textColorWhite,
                //                             // border: Border.all(
                //                             //     width: 0.1.h,
                //                             //     color: AppColors.textColorGrey),
                //                             borderRadius:
                //                                 BorderRadius.circular(15),
                //                           ),
                //                           child: Padding(
                //                             padding: EdgeInsets.symmetric(
                //                                 horizontal: 20.sp),
                //                             child: Column(
                //                               crossAxisAlignment:
                //                                   CrossAxisAlignment.center,
                //                               children: [
                //                                 SizedBox(
                //                                   height: 5.h,
                //                                 ),
                //                                 Align(
                //                                   alignment:
                //                                       Alignment.bottomCenter,
                //                                   child: Image.asset(
                //                                     "assets/images/disconnect.png",
                //                                     height: 5.h,
                //                                     color: AppColors
                //                                         .textColorWhite,
                //                                     // width: 104,
                //                                   ),
                //                                 ),
                //                                 SizedBox(height: 2.5.h),
                //                                 Text(
                //                                   'Are you sure you want to disconnect from this App?'
                //                                       .tr(),
                //                                   textAlign: TextAlign.center,
                //                                   style: TextStyle(
                //                                       fontWeight:
                //                                           FontWeight.w600,
                //                                       fontSize: 17.5.sp,
                //                                       color: themeNotifier
                //                                               .isDark
                //                                           ? AppColors
                //                                               .textColorWhite
                //                                           : AppColors
                //                                               .textColorBlack),
                //                                 ),
                //                                 SizedBox(
                //                                   height: 2.h,
                //                                 ),
                //                                 Text(
                //                                   connectedSites[index].urls,
                //                                   // 'https://opensea.io',
                //                                   style: TextStyle(
                //                                       color: AppColors
                //                                           .textColorWhite
                //                                           .withOpacity(0.4),
                //                                       fontSize: 10.2.sp,
                //                                       fontWeight:
                //                                           FontWeight.w400),
                //                                 ),
                //                                 Spacer(),
                //                                 DialogButton(
                //                                   title: 'Disconnect'.tr(),
                //                                   textColor:
                //                                       AppColors.errorColor,
                //                                   handler: () async {
                //                                     setState(() {
                //                                       isLoading = true;
                //                                     });
                //                                     var result = await Provider
                //                                             .of<UserProvider>(
                //                                                 context,
                //                                                 listen: false)
                //                                         .disconnectDapps(
                //                                       siteUrl:
                //                                           connectedSites[index]
                //                                               .urls,
                //                                       token: accessToken,
                //                                       context: context,
                //                                     );
                //                                     setState(() {
                //                                       isLoading = false;
                //                                     });
                //                                     Navigator.of(context)
                //                                         .pop(true);
                //                                     if (result ==
                //                                         AuthResult.success) {
                //                                       // connectedSites.removeAt(index);
                //                                       // lastConnectedSite = connectedSites.isNotEmpty ? connectedSites.last.urls : null;
                //                                       _checkFirstDisconnectionVisit();
                //                                       Timer(Duration(seconds: 2), () {
                //
                //                                       });
                //                                       await AppDeepLinking().openNftApp(
                //                                         {
                //                                           "operation": "disconnectWallet",
                //                                           "walletAddress":
                //                                           Provider.of<UserProvider>(
                //                                               context,
                //                                               listen: false)
                //                                               .walletAddress,
                //                                           "userName":
                //                                           Provider.of<UserProvider>(
                //                                               context,
                //                                               listen: false)
                //                                               .userName,
                //                                           "userIcon":
                //                                           Provider.of<UserProvider>(
                //                                               context,
                //                                               listen: false)
                //                                               .userAvatar,
                //                                           "response":
                //                                           'Wallet disconnected successfully'
                //                                         },
                //                                       );
                //
                //                                       // Navigator.of(context)
                //                                       //     .pop(true);
                //
                //                                       // await Navigator.of(context)
                //                                       //      .pushReplacement(
                //                                       //    MaterialPageRoute(
                //                                       //        builder: (context) =>
                //                                       //            WalletTokensNfts()),
                //                                       //  );
                //                                     }
                //                                   },
                //                                   isLoading: isLoading,
                //                                   // isGradient: true,
                //                                   color: AppColors
                //                                       .appSecondButton
                //                                       .withOpacity(0.10),
                //                                 ),
                //                                 SizedBox(
                //                                   height: 2.h,
                //                                 ),
                //                                 AppButton(
                //                                   title: 'Cancel'.tr(),
                //                                   handler: () {
                //                                     Navigator.of(context)
                //                                         .pop(false);
                //                                   },
                //                                   isGradient: false,
                //                                   color: AppColors
                //                                       .appSecondButton
                //                                       .withOpacity(0.10),
                //                                   textColor: themeNotifier
                //                                           .isDark
                //                                       ? AppColors.textColorWhite
                //                                       : AppColors.textColorBlack
                //                                           .withOpacity(0.8),
                //                                 ),
                //                                 Spacer(),
                //                               ],
                //                             ),
                //                           ),
                //                         )),
                //                   );
                //                 });
                //               },
                //             );
                //           },
                //           onDismissed: (direction) {
                //             setState(() {
                //               // connectedSites.removeAt(index);
                //             });
                //           },
                //           background: Container(
                //             height: 10.6.h,
                //             margin: EdgeInsets.only(bottom: 10.sp),
                //             width: double.infinity,
                //             decoration: BoxDecoration(
                //               color: themeNotifier.isDark
                //                   ? AppColors.tagFillClrDark
                //                   // ? AppColors.textColorWhite.withOpacity(0.05)
                //                   : AppColors.textColorGreyShade2
                //                       .withOpacity(0.2),
                //               borderRadius: BorderRadius.circular(10),
                //               // border: Border.all(color: AppColors.textColorGrey, width: 1)
                //             ),
                //             alignment: Alignment.centerRight,
                //             child: Padding(
                //               padding: const EdgeInsets.only(right: 20),
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   Image.asset(
                //                     "assets/images/disconnect.png",
                //                     height: 2.h,
                //                     width: 2.h,
                //                   ),
                //                   SizedBox(
                //                     height: 1.h,
                //                   ),
                //                   Text(
                //                     'Disconnect'.tr(),
                //                     style: TextStyle(
                //                         fontWeight: FontWeight.w500,
                //                         fontSize: 9.sp,
                //                         color: AppColors.errorColor),
                //                   )
                //                 ],
                //               ),
                //             ),
                //           ),
                //           child: Stack(
                //             children: [
                //               Container(
                //                   height: 10.6.h,
                //                   margin: EdgeInsets.only(bottom: 10.sp),
                //                   width: double.infinity,
                //
                //                 decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.circular(10),
                //                   color: AppColors.tagFillClrDark,
                //                 ),
                //               ),
                //               Container(
                //                 // margin: EdgeInsets.only(bottom: 15.sp),
                //                 height: 10.6.h,
                //                 margin: EdgeInsets.only(bottom: 10.sp),
                //                 width: double.infinity,
                //                 decoration: BoxDecoration(
                //                   color: AppColors.connectedSitesPopupsClr,
                //                   borderRadius: BorderRadius.circular(10),
                //                   // border:
                //                   //     Border.all(color: AppColors.textColorGrey, width: 1)
                //                 ),
                //                 child: Padding(
                //                   padding: const EdgeInsets.symmetric(
                //                       horizontal: 12),
                //                   child: Row(
                //                     mainAxisAlignment: isEnglish
                //                         ? MainAxisAlignment.start
                //                         : MainAxisAlignment.end,
                //                     children: [
                //                       if (currentLocale.languageCode == 'en')
                //                         Image.asset(
                //                           "assets/images/neo.png",
                //                           height: 5.5.h,
                //                           // width: 104,
                //                         ),
                //                       SizedBox(
                //                         width: 15,
                //                       ),
                //                       Text(
                //                         connectedSites[index].urls,
                //                         // 'NEO NFT Market',
                //                         style: TextStyle(
                //                             color: themeNotifier.isDark
                //                                 ? AppColors.textColorWhite
                //                                 : AppColors.textColorBlack,
                //                             fontSize: 10.5.sp,
                //                             fontWeight: FontWeight.w600),
                //                       ),
                //                       if (currentLocale.languageCode == 'ar')
                //                         SizedBox(
                //                           width: 15,
                //                         ),
                //                       if (currentLocale.languageCode == 'ar')
                //                         Image.asset(
                //                           "assets/images/neo.png",
                //                           height: 5.5.h,
                //                           // width: 104,
                //                         ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       );
                //     },
                //   ),

                //icko dynamic krna h
                // SizedBox(
                //   height: 2.h,
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25),
                //   child: Dismissible(
                //     dismissThresholds: {DismissDirection.endToStart: 0.1},
                //
                //     key: Key('0'),
                //     // direction: isEnglish ?  DismissDirection.endToStart : DismissDirection.startToEnd,
                //     direction: DismissDirection.endToStart,
                //     confirmDismiss: (direction) {
                //       return showDialog(
                //         context: context,
                //         builder: (BuildContext context) {
                //           final screenWidth = MediaQuery.of(context).size.width;
                //           final dialogWidth = screenWidth * 0.85;
                //           return Dialog(
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(8.0),
                //             ),
                //             backgroundColor: Colors.transparent,
                //             child: BackdropFilter(
                //                 filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                //                 child: Container(
                //                   height: 48.h,
                //                   width: dialogWidth,
                //                   decoration: BoxDecoration(
                //                     color: themeNotifier.isDark
                //                         ? AppColors.showDialogClr
                //                         : AppColors.textColorWhite,
                //                     // border: Border.all(
                //                     //     width: 0.1.h,
                //                     //     color: AppColors.textColorGrey),
                //                     borderRadius: BorderRadius.circular(15),
                //                   ),
                //                   child: Padding(
                //                     padding:
                //                     EdgeInsets.symmetric(horizontal: 20.sp),
                //                     child: Column(
                //                       crossAxisAlignment: CrossAxisAlignment.center,
                //                       children: [
                //                         SizedBox(
                //                           height: 5.h,
                //                         ),
                //                         Align(
                //                           alignment: Alignment.bottomCenter,
                //                           child: Image.asset(
                //                             "assets/images/disconnect.png",
                //                             height: 5.h,
                //                             color: AppColors.textColorWhite,
                //                             // width: 104,
                //                           ),
                //                         ),
                //                         SizedBox(height: 2.5.h),
                //                         Text(
                //                           'Are you sure you want to disconnect from this site?'
                //                               .tr(),
                //                           textAlign: TextAlign.center,
                //                           style: TextStyle(
                //                               fontWeight: FontWeight.w600,
                //                               fontSize: 17.5.sp,
                //                               color: themeNotifier.isDark
                //                                   ? AppColors.textColorWhite
                //                                   : AppColors.textColorBlack),
                //                         ),
                //                         SizedBox(
                //                           height: 2.h,
                //                         ),
                //                         Text(
                //                           'https://opensea.io',
                //                           style: TextStyle(
                //                               color: AppColors.textColorWhite
                //                                   .withOpacity(0.4),
                //                               fontSize: 10.2.sp,
                //                               fontWeight: FontWeight.w400),
                //                         ),
                //                         Spacer(),
                //                         DialogButton(
                //                             title: 'Disconnect'.tr(),
                //                             handler: () async {
                //                               // setState(() {
                //                               //   isDisconnected = true;
                //                               //   isLoading = true;
                //                               // });
                //                               var result =
                //                               await Provider.of<UserProvider>(
                //                                   context,
                //                                   listen: false)
                //                                   .disconnectDapps(
                //                                   revokeAll: true,
                //                                   token: accessToken,
                //                                   context: context);
                //                               setState(() {
                //                                 isLoading = false;
                //                               });
                //                               if (result == AuthResult.success) {
                //                                 Navigator.of(context).pop(true);
                //                                 Navigator.of(context).pushReplacement(
                //                                   MaterialPageRoute(builder: (context) => WalletTokensNfts()),
                //                                 );
                //                               }
                //                             },
                //                             isLoading: isLoading,
                //                             // isGradient: true,
                //                             color: AppColors.errorColor),
                //                         SizedBox(
                //                           height: 2.h,
                //                         ),
                //                         AppButton(
                //                           title: 'Cancel'.tr(),
                //                           handler: () {
                //                             Navigator.of(context).pop(false);
                //                             setState(() {
                //                               isDisconnected = false;
                //                             });
                //                           },
                //                           isGradient: false,
                //                           color: AppColors.appSecondButton.withOpacity(0.10),
                //                           textColor: themeNotifier.isDark
                //                               ? AppColors.textColorWhite
                //                               : AppColors.textColorBlack
                //                               .withOpacity(0.8),
                //                         ),
                //                         Spacer(),
                //                       ],
                //                     ),
                //                   ),
                //                 )),
                //           );
                //         },
                //       );
                //     },
                //     onDismissed: (d) {
                //       // setState(() {
                //       //   isDisconnected=true;
                //       // });
                //     },
                //     background: Container(
                //       width: 70,
                //       decoration: BoxDecoration(
                //         color: themeNotifier.isDark ? AppColors.tagFillClrDark
                //         // ? AppColors.textColorWhite.withOpacity(0.05)
                //             : AppColors.textColorGreyShade2.withOpacity(0.2),
                //         borderRadius: BorderRadius.circular(10),
                //         // border: Border.all(color: AppColors.textColorGrey, width: 1)
                //       ),
                //       alignment: Alignment.centerRight,
                //       child: Padding(
                //         padding: const EdgeInsets.only(right: 20),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Image.asset(
                //               "assets/images/disconnect.png",
                //               height: 2.h,
                //               width: 2.h,
                //             ),
                //             SizedBox(
                //               height: 1.h,
                //             ),
                //             Text(
                //               'Disconnect'.tr(),
                //               style: TextStyle(
                //                   fontWeight: FontWeight.w500,
                //                   fontSize: 9.sp,
                //                   color: AppColors.errorColor),
                //             )
                //           ],
                //         ),
                //       ),
                //     ),
                //     child: Container(
                //       height: 10.6.h,
                //       width: double.infinity,
                //       decoration: BoxDecoration(
                //         color: AppColors.connectedSitesPopupsClr,
                //         borderRadius: BorderRadius.circular(10),
                //         // border:
                //         //     Border.all(color: AppColors.textColorGrey, width: 1)
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 12),
                //         child: Row(
                //           mainAxisAlignment: isEnglish
                //               ? MainAxisAlignment.start
                //               : MainAxisAlignment.end,
                //           children: [
                //             if (currentLocale.languageCode == 'en')
                //               Image.asset(
                //                 "assets/images/SOUQ.png",
                //                 height: 5.5.h,
                //                 // width: 104,
                //               ),
                //             SizedBox(
                //               width: 15,
                //             ),
                //             Text(
                //               'SOUQ NFT Market',
                //               style: TextStyle(
                //                   color: themeNotifier.isDark
                //                       ? AppColors.textColorWhite
                //                       : AppColors.textColorBlack,
                //                   fontSize: 10.5.sp,
                //                   fontWeight: FontWeight.w600),
                //             ),
                //             if (currentLocale.languageCode == 'ar')
                //               SizedBox(
                //                 width: 15,
                //               ),
                //             if (currentLocale.languageCode == 'ar')
                //               Image.asset(
                //                 "assets/images/neo.png",
                //                 height: 5.5.h,
                //                 // width: 104,
                //               ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(child: SizedBox()),
                if (showConnectionPopup)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      // color: Colors.red,
                      height: 13.5.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.connectedSitesPopupsClr,
                        borderRadius: BorderRadius.circular(10),
                        // border:
                        //     Border.all(color: AppColors.textColorGrey, width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: isEnglish ? 12 : 0,
                            top: 10,
                            bottom: 10,
                            right: isEnglish ? 0 : 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lastConnectedSite!,
                              // 'https//opensea.io',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColorGrey,
                              ),
                            ),
                            // SizedBox(
                            //   height: 0.6.h,
                            // ),
                            Text(
                              'Connected to NEO NFT Market'.tr(),
                              style: TextStyle(
                                  color: themeNotifier.isDark
                                      ? AppColors.textColorWhite
                                      : AppColors.textColorBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            // SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Container(
                                  width: 2.h,
                                  height: 2.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.connectDiscSites),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 8.sp,
                                    color: AppColors.connectDiscSites,
                                  ),
                                ),
                                SizedBox(
                                  width: 2.w,
                                ),
                                Text(
                                  'Connected'.tr(),
                                  style: TextStyle(
                                    color: AppColors.connectDiscSites,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11.5.sp,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                if (showDisconnectionPopup)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      // color: Colors.red,
                      height: 13.5.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.connectedSitesPopupsClr,
                        borderRadius: BorderRadius.circular(10),
                        // border:
                        //     Border.all(color: AppColors.textColorGrey, width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: isEnglish ? 12 : 0,
                            top: 10,
                            bottom: 10,
                            right: isEnglish ? 0 : 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Disconnected from NEO NFT Market'.tr(),
                              style: TextStyle(
                                  color: themeNotifier.isDark
                                      ? AppColors.textColorWhite
                                      : AppColors.textColorBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Your wallet is no longer connected.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColorGrey,
                              ),
                            ),
                            // SizedBox(
                            //   height: 0.6.h,
                            // ),

                            // SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Container(
                                  width: 2.h,
                                  height: 2.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: AppColors.errorColor),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 8.sp,
                                    color: AppColors.errorColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 2.w,
                                ),
                                Text(
                                  'Disconnected'.tr(),
                                  style: TextStyle(
                                    color: AppColors.errorColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11.5.sp,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: OS.Platform.isIOS ? 5.h : 3.h),
              ],
            ),
          ),
          if (isLoading) LoaderBluredScreen()
        ],
      );
    });
  }
}
