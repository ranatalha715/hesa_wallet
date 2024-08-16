import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/screens/signup_signin/signin_with_email.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';

class TermsAndConditions extends StatefulWidget {

  static const routeName = '/TermsAndConditions';

  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  List<String> accountDefinitions = [
    'Account means a unique account created for You to access our Service or parts of our Service.'
        .tr(),
    'Affiliate means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.'
        .tr()
  ];

  bool _isChecked = false;
  bool isButtonActive = false;
  var _isLoading = false;
  var _isinit= true;

  final ScrollController scrollController = ScrollController();

  void _updateButtonState() {
    setState(() {
      isButtonActive;
    });
  }

  String fcmToken = 'Waiting for FCM token...';

  generateFcmToken() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.getToken().then((newToken) {
      print("fcm===" + newToken!);
      setState(() {
        fcmToken = newToken;
      });
    });
  }

  @override
  void initState() {
    generateFcmToken();
    // TODO: implement initState
    // _updateButtonState();
    Timer.periodic(Duration(seconds: 1), (timer) async {
    //   await Provider.of<AuthProvider>(context, listen: false)
    //       .updateFCM(FCM: fcmToken, token: accessToken, context: context);

    });
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    // if(_isinit){
    //   setState(() {
    //     _isLoading=true;
    //   });
    //   await Future.delayed(Duration(milliseconds: 900), () {
    //     print('This code will be executed after 2 seconds');
    //   });
    //   setState(() {
    //     _isLoading=false;
    //   });
    // }
    // _isinit=false;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          WillPopScope(
              onWillPop: () async {
                exit(0);
                return false;
              },
            child: Scaffold(
              backgroundColor: themeNotifier.isDark
                  ? AppColors.backgroundColor
                  : AppColors.textColorWhite,
              body: Column(
                children: [
                  MainHeader(title: 'Terms & Conditions'.tr(),
                  handler: (){
                    exit(0);
                  },
                  ),
                  Expanded(
                    child: Container(
                      height: 85.h,
                      // color: Colors.yellow,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 4.h,
                                  ),
                                  // Text(
                                  //   "Wallet user T&C".tr(),
                                  //   style: TextStyle(
                                  //       color: themeNotifier.isDark
                                  //           ? AppColors.textColorWhite
                                  //           : AppColors.textColorBlack,
                                  //       fontWeight: FontWeight.w600,
                                  //       fontSize: 17.5.sp,
                                  //       fontFamily: 'Inter'),
                                  // ),
                                  // SizedBox(
                                  //   height: 1.h,
                                  // ),
                                  Text(
                                    "Last updated: October 05, 2022.".tr(),
                                    style: TextStyle(
                                        color: AppColors.textColorGrey,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11.7.sp,
                                        fontFamily: 'Inter'),
                                  ),
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                  Text(
                                    "This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You."
                                        .tr(),
                                    style: TextStyle(
                                        height: 1.4,
                                        color: AppColors.textColorGrey,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11.7.sp,
                                        fontFamily: 'Inter'),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    // itemCount: 20,
                                    controller: scrollController,
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
                                              color: AppColors.textColorGrey,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(bottom: 12),
                                              child: Text(
                                                accountDefinitions[index],
                                                style: TextStyle(
                                                    height: 1.4,
                                                    color: AppColors.textColorGrey,
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
                                    height: 20.h,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            bottom: 30,
                            right: 0,
                            child: Container(
                              color: themeNotifier.isDark
                                  ? AppColors.backgroundColor
                                  : AppColors.textColorWhite,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    // Expanded(child: SizedBox()),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:  EdgeInsets.only(left: 4.sp),
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              _isChecked = !_isChecked;
                                            }),
                                            child:
                                            Container(
                                              height: 2.4.h,
                                              width: 2.4.h,
                                              decoration: BoxDecoration(
                                                // gradient: LinearGradient(
                                                //   colors: [
                                                //     _isChecked
                                                //         ? Color(0xff92B928)
                                                //         : Colors.transparent,
                                                //     _isChecked
                                                //         ? Color(0xffC9C317)
                                                //         : Colors.transparent
                                                //   ],
                                                // ),
                                                  border: Border.all(
                                                      color: AppColors.textColorWhite,
                                                      width: 1),
                                                  borderRadius:
                                                  BorderRadius.circular(2)),
                                              child: _isChecked
                                                  ? Align(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  size: 8.2.sp,
                                                  color:
                                                  AppColors.textColorWhite,
                                                ),
                                              )
                                                  : SizedBox(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3.w,
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            // color: Colors.red,
                                            child: Text(
                                              'I understand the general terms and statements mentioned in this disclaimer and agree to continue'
                                                  .tr(),
                                              style: TextStyle(
                                                  color: AppColors.textColorGrey,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 9.sp,
                                                  fontFamily: 'Inter'),
                                              maxLines: 2,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    AppButton(
                                      title: 'Accept'.tr(),
                                      isactive:
                                      _isChecked,
                                      handler: () async {
                                        // if(_isChecked){
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          // await Future.delayed(Duration(milliseconds: 1500),
                                          //         (){});
                                          final  finalResult = await Provider.of<AuthProvider>(context, listen: false).registerUserStep5(
                                              termsAndConditions: _isChecked.toString(), deviceToken: fcmToken, context: context);
                                          setState(() {
                                            _isLoading = false;
                                          });
                                         if(finalResult == AuthResult.success)
                                           {
                                             showDialog(
                                               context: context,
                                               builder: (BuildContext context) {
                                                 void closeDialogAndNavigate() {
                                                   Navigator.of(context)
                                                       .pop(); // Close the dialog
                                                   // Navigator.of(context).pop(); // Close the dialog
                                                   Navigator.of(context)
                                                       .pushNamedAndRemoveUntil('/SigninWithEmail', (Route d) => false,
                                                       arguments: {
                                                         'comingFromWallet':false
                                                       }
                                                   );

                                                   // Navigator.pushReplacement(
                                                   //   context,
                                                   //   MaterialPageRoute(
                                                   //       builder: (context) =>
                                                   //           SigninWithEmail()),
                                                   // );
                                                 }

                                                 Future.delayed(Duration(seconds: 2),
                                                     closeDialogAndNavigate);
                                                 return Dialog(
                                                   shape: RoundedRectangleBorder(
                                                     borderRadius: BorderRadius.circular(8.0),
                                                   ),
                                                   backgroundColor: Colors.transparent,
                                                   child: BackdropFilter(
                                                     filter: ImageFilter.blur(
                                                         sigmaX: 7, sigmaY: 7),
                                                     child: Container(
                                                       height: 70.h,
                                                       decoration: BoxDecoration(
                                                         color: themeNotifier.isDark
                                                             ? AppColors.showDialogClr
                                                             : AppColors.textColorWhite,
                                                         borderRadius:
                                                         BorderRadius.circular(15),
                                                       ),
                                                       padding: EdgeInsets.all(16.0),
                                                       child: Column(
                                                         mainAxisAlignment:
                                                         MainAxisAlignment.start,
                                                         mainAxisSize: MainAxisSize.min,
                                                         children: [
                                                           Container(
                                                             height: 40.h,
                                                             // color: themeNotifier.isDark
                                                             //     ? AppColors.backgroundColor
                                                             //     : AppColors.textColorBlack.withOpacity(0.5),
                                                             child: Padding(
                                                               padding: EdgeInsets.only(
                                                                   left: 2.sp,
                                                                   right: 2.sp,
                                                                   bottom: 15.sp,
                                                                   top: 5.sp),
                                                               child: Container(
                                                                 decoration: BoxDecoration(
                                                                     color: themeNotifier
                                                                         .isDark
                                                                         ? AppColors
                                                                         .whiteColorWithOpacity
                                                                         .withOpacity(0.05)
                                                                         : AppColors
                                                                         .backgroundColor
                                                                         .withOpacity(0.1),
                                                                     borderRadius:
                                                                     BorderRadius.circular(
                                                                         15)),
                                                                 // child: Align(
                                                                 //   alignment: Alignment.center,
                                                                 //   child: Image.asset(
                                                                 //     "assets/images/hesa_wallet_logo.png",
                                                                 //     height: 11.h,
                                                                 //     width: 11.h,
                                                                 //   ),
                                                                 // ),
                                                               ),
                                                             ),
                                                           ),
                                                           Text(
                                                             "Welcome to KSA’s Web3 Gateway "
                                                                 .tr(),
                                                             textAlign: TextAlign.center,
                                                             style: TextStyle(
                                                                 height: 1.3,
                                                                 color: themeNotifier.isDark
                                                                     ? AppColors.textColorWhite
                                                                     : AppColors
                                                                     .textColorBlack,
                                                                 fontWeight: FontWeight.w600,
                                                                 fontSize: 17.5.sp,
                                                                 fontFamily: 'Blogger Sans'),
                                                           ),
                                                           SizedBox(
                                                             height: 15,
                                                           ),
                                                           Text(
                                                             "This is the beginning for so much more to come!"
                                                                 .tr(),
                                                             textAlign: TextAlign.center,
                                                             style: TextStyle(
                                                                 height: 1.4,
                                                                 color:
                                                                 AppColors.textColorGrey,
                                                                 fontWeight: FontWeight.w400,
                                                                 fontSize: 11.7.sp,
                                                                 fontFamily: 'Inter'),
                                                           ),
                                                           SizedBox(
                                                             height: 2.h,
                                                           ),
                                                           // Text(
                                                           //   "Show your support by following us & interact with a growing Community."
                                                           //       .tr(),
                                                           //   textAlign: TextAlign.center,
                                                           //   style: TextStyle(
                                                           //       height: 1.4,
                                                           //       color:
                                                           //       AppColors.textColorGrey,
                                                           //       fontWeight: FontWeight.w400,
                                                           //       fontSize: 11.7.sp,
                                                           //       fontFamily: 'Inter'),
                                                           // ),
                                                           // Expanded(child: SizedBox()),
                                                           Row(
                                                             mainAxisAlignment:
                                                             MainAxisAlignment.center,
                                                             crossAxisAlignment:
                                                             CrossAxisAlignment.end,
                                                             children: [
                                                               Image.asset(
                                                                 "assets/images/twitter.png",
                                                                 height: 2.h,
                                                                 width: 2.h,
                                                                 color: themeNotifier.isDark
                                                                     ? AppColors.textColorWhite
                                                                     : AppColors
                                                                     .textColorBlack,
                                                               ),
                                                               SizedBox(
                                                                 width: 3.w,
                                                               ),
                                                               Image.asset(
                                                                 "assets/images/instagram.png",
                                                                 height: 2.h,
                                                                 width: 2.h,
                                                                 color: themeNotifier.isDark
                                                                     ? AppColors.textColorWhite
                                                                     : AppColors
                                                                     .textColorBlack,
                                                               ),
                                                               SizedBox(
                                                                 width: 3.w,
                                                               ),
                                                               Image.asset(
                                                                 "assets/images/discord.png",
                                                                 height: 2.h,
                                                                 width: 2.h,
                                                                 color: themeNotifier.isDark
                                                                     ? AppColors.textColorWhite
                                                                     : AppColors
                                                                     .textColorBlack,
                                                               ),
                                                               SizedBox(
                                                                 width: 3.w,
                                                               ),
                                                               Image.asset(
                                                                 "assets/images/telegram.png",
                                                                 height: 2.h,
                                                                 width: 2.h,
                                                                 color: themeNotifier.isDark
                                                                     ? AppColors.textColorWhite
                                                                     : AppColors
                                                                     .textColorBlack,
                                                               ),
                                                             ],
                                                           ),
                                                           SizedBox(height: 2.h,),
                                                           Text(
                                                             "Support by following & interacting with a growing Community."
                                                                 .tr(),
                                                             textAlign: TextAlign.center,
                                                             style: TextStyle(
                                                                 height: 1.4,
                                                                 color:
                                                                 AppColors.textColorGrey,
                                                                 fontWeight: FontWeight.w400,
                                                                 fontSize: 10.sp,
                                                                 fontFamily: 'Inter'),
                                                           ),
                                                         ],
                                                       ),
                                                     ),
                                                   ),
                                                 );
                                               },
                                             );
                                           // }

                                        }
                                         },
                                      isGradient: true,
                                      color: Colors.transparent,
                                      textColor: AppColors.textColorBlack,
                                        isLoading:_isLoading
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if(_isLoading)
            LoaderBluredScreen()
        ],
      );
    });
  }
}
