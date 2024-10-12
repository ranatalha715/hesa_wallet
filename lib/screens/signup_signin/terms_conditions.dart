import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:animated_checkmark/animated_checkmark.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:io' as OS;
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';

class TermsAndConditions extends StatefulWidget {

  static const routeName = '/TermsAndConditions';
  bool? fromSignup;
    TermsAndConditions({Key? key,  this.fromSignup=true}) : super(key: key);

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
    Timer.periodic(Duration(seconds: 1), (timer) async {

    });
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          WillPopScope(
              onWillPop: () async {
                widget.fromSignup==true ? Navigator.pop(context) : Navigator.pop(context);
                // widget.fromSignup==true ? exit(0) : Navigator.pop(context);
                return true;
              },
            child: Scaffold(
              backgroundColor: themeNotifier.isDark
                  ? AppColors.backgroundColor
                  : AppColors.textColorWhite,
              body: Column(
                children: [
                  MainHeader(title: 'Terms & Conditions'.tr(),
                  handler: (){
                    widget.fromSignup==true ? Navigator.pop(context) : Navigator.pop(context);
                    // widget.fromSignup==true ? exit(0) : Navigator.pop(context);

                  },
                  ),
                  Expanded(
                    child: Container(
                      height: 85.h,
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
                                  Text(
                                    "Last updated: October 05, 2022.".tr(),
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
                                    "This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You."
                                        .tr(),
                                    style: TextStyle(
                                        height: 1.4,
                                        color: AppColors.textColorWhite,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11.7.sp,
                                        fontFamily: 'Inter'),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
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
                                              color: AppColors.textColorWhite,
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
                                    height: 20.h,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if(widget.fromSignup == true)
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
                                                  borderRadius:
                                                  BorderRadius.circular(2)),
                                              child:
                                              AnimatedContainer(
                                                  duration: Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  height: 2.4.h,
                                                  width: 2.4.h,
                                                  decoration: BoxDecoration(
                                                    color: _isChecked ? AppColors.hexaGreen : Colors.transparent, // Animate the color
                                                    border: Border.all(
                                                        color: _isChecked ?AppColors.hexaGreen : AppColors.textColorWhite,
                                                        width: 1),
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                  child:  Checkmark(
                                                    checked: _isChecked,
                                                    indeterminate: false,
                                                    size: 11.sp,
                                                    color: Colors.black,
                                                    drawCross: false,
                                                    drawDash: false,
                                                  )
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3.w,
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            child: Text(
                                              'I understand the general terms and statements mentioned in this disclaimer and agree to continue'
                                                  .tr(),
                                              style: TextStyle(
                                                  color: AppColors.textColorWhite,
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
                                          setState(() {
                                            _isLoading = true;
                                          });
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
                                                // void closeDialogAndNavigate() {
                                                //   Navigator.of(context)
                                                //       .pop();
                                                //   // Navigator.of(context)
                                                //   //     .pushNamedAndRemoveUntil('/SigninWithEmail', (Route d) => false,
                                                //   //     arguments: {
                                                //   //       'comingFromWallet':false
                                                //   //     }
                                                //   // );
                                                // }
                                                //
                                                // Future.delayed(Duration(seconds: 2),
                                                //     closeDialogAndNavigate);
                                                return
                                                  Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  backgroundColor: Colors.transparent,
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 7, sigmaY: 7),
                                                    child: Container(
                                                      height: 73.h,
                                                      decoration: BoxDecoration(
                                                        color: themeNotifier.isDark
                                                            ? AppColors.showDialogClr
                                                            : AppColors.textColorWhite,
                                                        borderRadius:
                                                        BorderRadius.circular(15),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: AppColors.textColorBlack.withOpacity(0.95), // Dark shadow color
                                                            offset: Offset(0, 0), // No offset, shadow will appear equally on all sides
                                                            blurRadius: 10, // Adjust blur for softer shadow
                                                            spreadRadius: 0.4, // Spread the shadow slightly
                                                          ),
                                                        ],
                                                      ),

                                                      padding: EdgeInsets.all(16.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            height: 40.h,
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
                                                                child:     Align(
                                                                  alignment: Alignment.center,
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(15),
                                                                    child: Image.asset(
                                                                      "assets/images/terms_logo.png",
                                                                      fit: BoxFit.cover,
                                                                      width: double.infinity,
                                                                      // height: 13.8.h,
                                                                      // width: 13.8.h,
                                                                    ),
                                                                  ),
                                                                ),
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
                                        // isLoading:_isLoading
                                    ),
                                    SizedBox(
                                      height:  OS.Platform.isIOS ? 2.h : 0,
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
