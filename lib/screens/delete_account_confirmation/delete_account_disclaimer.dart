import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/configs.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/dialog_button.dart';
import '../../widgets/main_header.dart';
import '../signup_signin/wallet.dart';

class DeleteAccountDisclaimer extends StatefulWidget {
  const DeleteAccountDisclaimer({Key? key}) : super(key: key);

  @override
  State<DeleteAccountDisclaimer> createState() =>
      _DeleteAccountDisclaimerState();
}

class _DeleteAccountDisclaimerState extends State<DeleteAccountDisclaimer> {
  final ScrollController scrollController = ScrollController();

  List<String> accountDefinitions = [
    'Account means a unique account created for You to access our Service or parts of our Service.'
        .tr(),
    'Affiliate means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.'.tr(),
    'Affiliate means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.'.tr()
        .tr(),
    'Affiliate means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of'.tr(),
  ];

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  bool _isSelected = false;
  var isLoading = false;
  var accessToken = '';
  var _isLoading = false;
  var _isinit= true;

  getWsToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  @override
  void initState() {
    // TODO: implement initState
    getWsToken();
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if(_isinit){
      setState(() {
        _isLoading=true;
      });
      await Future.delayed(Duration(milliseconds: 900), () {
        print('This code will be executed after 2 seconds');
      });
      setState(() {
        _isLoading=false;
      });
    }
    _isinit=false;
    super.didChangeDependencies();
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
                MainHeader(title: 'Delete Account'.tr()),
                Stack(
                  children: [
                    Container(
                      height: 85.h,
                      width: double.infinity,
                      child: Padding(
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
                              //   "Last updated: October 05, 2022.".tr(),
                              //   style: TextStyle(
                              //       color: AppColors.textColorGrey,
                              //       fontWeight: FontWeight.w400,
                              //       fontSize: 11.7.sp,
                              //       fontFamily: 'Inter'),
                              // ),
                              // SizedBox(
                              //   height: 2.h,
                              // ),
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
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount: accountDefinitions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: 6.sp, right: 6.sp),
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
                    ),
                    Positioned(
                        bottom: 0,
                        left: 20,
                        right: 20,
                        child: Container(
                          color: themeNotifier.isDark
                              ? AppColors.backgroundColor
                              : AppColors.textColorWhite,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _isSelected = !_isSelected;
                                      }),
                                      child: Container(
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
                                                color: AppColors.tabColorlightMode,
                                                width: 1),
                                            borderRadius: BorderRadius.circular(2)),
                                        child: _isSelected
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  size: 8.2.sp,
                                                  color: AppColors.textColorGrey,
                                                ),
                                              )
                                            : SizedBox(),
                                      ),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(left: 5),
                                  //   child: GestureDetector(
                                  //     onTap: () => setState(() {
                                  //       _isSelected = !_isSelected;
                                  //     }),
                                  //     child: Container(
                                  //       height: 2.3.h,
                                  //       width: 2.3.h,
                                  //       decoration: BoxDecoration(
                                  //           gradient: LinearGradient(
                                  //             colors: [
                                  //               _isSelected
                                  //                   ? Color(0xff92B928)
                                  //                   : Colors.transparent,
                                  //               _isSelected
                                  //                   ? Color(0xffC9C317)
                                  //                   : Colors.transparent
                                  //             ],
                                  //             begin: Alignment.topLeft,
                                  //             end: Alignment.bottomRight,
                                  //           ),
                                  //           // color: _isSelected
                                  //           //     ? AppColors.gradientColor1
                                  //           //     : Colors.transparent,
                                  //           border: Border.all(
                                  //               color: AppColors.gradientColor1,
                                  //               width: 2),
                                  //           borderRadius: BorderRadius.circular(2)),
                                  //       child: _isSelected
                                  //           ? Align(
                                  //               alignment: Alignment.center,
                                  //               child: Icon(
                                  //                 Icons.check_rounded,
                                  //                 size: 8.2.sp,
                                  //                 color: themeNotifier.isDark
                                  //                     ? AppColors.backgroundColor
                                  //                     : AppColors.textColorBlack,
                                  //               ),
                                  //             )
                                  //           : SizedBox(),
                                  //     ),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    width: 3.w,
                                  ),
                                  Text(
                                      'I agree to permanently deleting my account.'
                                          .tr(),
                                      style: TextStyle(
                                          color: AppColors.deleteAccWarningClr,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          fontFamily: 'Inter'))
                                ],
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              AppButton(
                                title: 'Delete Account'.tr(),
                                isactive: _isSelected,
                                handler: () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await Future.delayed(Duration(milliseconds: 1500),
                                          (){});
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if(_isSelected){
                                  // Navigator.pop(context);
                                  showDialog(
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
                                                height: 33.h,
                                                width: dialogWidth,
                                                decoration: BoxDecoration(
                                                  // border: Border.all(
                                                  //     width: 0.1.h,
                                                  //     color: AppColors.textColorGrey),
                                                  color: themeNotifier.isDark
                                                      ? AppColors.showDialogClr
                                                      : AppColors.textColorWhite,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 4.h,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: 20.sp),
                                                      child: Text(
                                                        'Are you sure, you want to delete account?'
                                                            .tr(),
                                                        textAlign: TextAlign.center,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 15.sp,
                                                            color: themeNotifier
                                                                    .isDark
                                                                ? AppColors
                                                                    .textColorWhite
                                                                : AppColors
                                                                    .textColorBlack),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 2.h,
                                                    ),
                                                    Expanded(child: SizedBox()),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 22),
                                                      child: DialogButton(
                                                        title: 'Confirm'.tr(),
                                                        handler: () async {
                                                          if (isLoading) return;

                                                          try {
                                                            setState(() {
                                                              isLoading = true;
                                                            });
                                                            final result = await Provider
                                                                    .of<AuthProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                .deleteAccount(
                                                                    token: accessToken,
                                                                    context:
                                                                        context);

                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                            if (result ==
                                                                AuthResult
                                                                    .success) {
                                                              Navigator.pop(context);
                                                              showDialog(
                                                                context: context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  final screenWidth =
                                                                      MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width;
                                                                  final dialogWidth =
                                                                      screenWidth *
                                                                          0.85;
                                                                  void
                                                                      closeDialogAndNavigate() {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // Close the dialog
                                                                    Navigator
                                                                        .pushAndRemoveUntil(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  Wallet(),
                                                                            ),
                                                                            (route) =>
                                                                                false); // This predicate ensures that all previous routes are removed.
                                                                    // Close the dialog
                                                                  }

                                                                  Future.delayed(
                                                                      Duration(
                                                                          seconds:
                                                                              3),
                                                                      closeDialogAndNavigate);
                                                                  return Dialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                                  8.0),
                                                                    ),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child:
                                                                        BackdropFilter(
                                                                            filter: ImageFilter.blur(
                                                                                sigmaX:
                                                                                    7,
                                                                                sigmaY:
                                                                                    7),
                                                                            child:
                                                                                Container(
                                                                              height:
                                                                                  22.h,
                                                                              width:
                                                                                  dialogWidth,
                                                                              decoration:
                                                                                  BoxDecoration(
                                                                                color: themeNotifier.isDark
                                                                                    ? AppColors.showDialogClr
                                                                                    : AppColors.textColorWhite,
                                                                                borderRadius:
                                                                                    BorderRadius.circular(15),
                                                                              ),
                                                                              child:
                                                                                  Column(
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment.center,
                                                                                children: [
                                                                                  // SizedBox(
                                                                                  //   height: 6.h,
                                                                                  // ),
                                                                                  // Align(
                                                                                  //   alignment: Alignment.bottomCenter,
                                                                                  //   child: Image.asset(
                                                                                  //     "assets/images/check_circle.png",
                                                                                  //     height: 6.h,
                                                                                  //     width: 5.8.h,
                                                                                  //   ),
                                                                                  // ),
                                                                                  // SizedBox(height: 2.h),
                                                                                  Text(
                                                                                    'Account Marked for Deletion'.tr(),
                                                                                    textAlign: TextAlign.center,
                                                                                    maxLines: 2,
                                                                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17.sp, color: themeNotifier.isDark ? AppColors.textColorWhite : AppColors.textColorBlack),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 2.h,
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                                                                    child: Text(
                                                                                      'You will receive an email verification confirming this action.'.tr(),
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(height: 1.4, fontWeight: FontWeight.w400, fontSize: 10.2.sp, color: AppColors.textColorGrey),
                                                                                    ),
                                                                                  ),
                                                                                  // SizedBox(
                                                                                  //   height: 4.h,
                                                                                  // ),
                                                                                ],
                                                                              ),
                                                                            )),
                                                                  );
                                                                },
                                                              );
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
                                                        // isGradient: true,
                                                        color: AppColors.appSecondButton.withOpacity(0.10),
                                                        textColor: AppColors
                                                            .errorColor,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.h),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: 18.sp),
                                                      child: AppButton(
                                                          title: 'Cancel'.tr(),
                                                          handler: () {
                                                            Navigator.pop(context);
                                                          },
                                                          isGradient: false,
                                                          textColor: themeNotifier
                                                                  .isDark
                                                              ? AppColors
                                                                  .textColorWhite
                                                              : AppColors
                                                                  .textColorBlack
                                                                  .withOpacity(0.8),
                                                        color: AppColors.appSecondButton.withOpacity(0.10),),
                                                    ),
                                                    Expanded(child: SizedBox()),
                                                  ],
                                                ),
                                              )),
                                        );
                                      });
                                    },
                                  );
                                };
    },
                                // handler: () {
                                //   showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       final screenWidth =
                                //           MediaQuery.of(context).size.width;
                                //       final dialogWidth = screenWidth * 0.85;
                                //       return Dialog(
                                //         shape: RoundedRectangleBorder(
                                //           borderRadius: BorderRadius.circular(8.0),
                                //         ),
                                //         backgroundColor: Colors.transparent,
                                //         child: BackdropFilter(
                                //             filter: ImageFilter.blur(
                                //                 sigmaX: 7, sigmaY: 7),
                                //             child: Container(
                                //               height: 55.h,
                                //               width: dialogWidth,
                                //               decoration: BoxDecoration(
                                //                 color: themeNotifier.isDark
                                //                     ? AppColors.showDialogClr
                                //                     : AppColors.textColorWhite,
                                //                 borderRadius:
                                //                     BorderRadius.circular(15),
                                //               ),
                                //               child: Column(
                                //                 children: [
                                //                   SizedBox(
                                //                     height: 3.h,
                                //                   ),
                                //                   Align(
                                //                     alignment:
                                //                         Alignment.bottomCenter,
                                //                     child: Image.asset(
                                //                       "assets/images/svg_icon.png",
                                //                       height: 5.9.h,
                                //                       width: 5.6.h,
                                //                     ),
                                //                   ),
                                //                   SizedBox(height: 2.h),
                                //                   Text(
                                //                     'OTP verification'.tr(),
                                //                     style: TextStyle(
                                //                         fontWeight: FontWeight.w600,
                                //                         fontSize: 17.5.sp,
                                //                         color: themeNotifier.isDark
                                //                             ? AppColors
                                //                                 .textColorWhite
                                //                             : AppColors
                                //                                 .textColorBlack),
                                //                   ),
                                //                   SizedBox(
                                //                     height: 2.h,
                                //                   ),
                                //                   Row(
                                //                     mainAxisAlignment:
                                //                         MainAxisAlignment.center,
                                //                     children: [
                                //                       otpContainer(
                                //                         focusNode:
                                //                             firstFieldFocusNode,
                                //                         handler: () => FocusScope
                                //                                 .of(context)
                                //                             .requestFocus(
                                //                                 secondFieldFocusNode),
                                //                       ),
                                //                       SizedBox(
                                //                         width: 0.8.h,
                                //                       ),
                                //                       otpContainer(
                                //                         focusNode:
                                //                             secondFieldFocusNode,
                                //                         handler: () => FocusScope
                                //                                 .of(context)
                                //                             .requestFocus(
                                //                                 thirdFieldFocusNode),
                                //                       ),
                                //                       SizedBox(
                                //                         width: 0.8.h,
                                //                       ),
                                //                       otpContainer(
                                //                         focusNode:
                                //                             thirdFieldFocusNode,
                                //                         handler: () => FocusScope
                                //                                 .of(context)
                                //                             .requestFocus(
                                //                                 forthFieldFocusNode),
                                //                       ),
                                //                       SizedBox(
                                //                         width: 0.8.h,
                                //                       ),
                                //                       otpContainer(
                                //                         focusNode:
                                //                             forthFieldFocusNode,
                                //                         handler: () => FocusScope
                                //                                 .of(context)
                                //                             .requestFocus(
                                //                                 fifthFieldFocusNode),
                                //                       ),
                                //                       SizedBox(
                                //                         width: 0.8.h,
                                //                       ),
                                //                       otpContainer(
                                //                         focusNode:
                                //                             fifthFieldFocusNode,
                                //                         handler: () => FocusScope
                                //                                 .of(context)
                                //                             .requestFocus(
                                //                                 sixthFieldFocusNode),
                                //                       ),
                                //                       SizedBox(
                                //                         width: 0.8.h,
                                //                       ),
                                //                       otpContainer(
                                //                         focusNode:
                                //                             sixthFieldFocusNode,
                                //                         handler: () => null,
                                //                       ),
                                //                     ],
                                //                   ),
                                //                   SizedBox(
                                //                     height: 1.h,
                                //                   ),
                                //                   Text(
                                //                     'Enter sms verification code'.tr(),
                                //                     textAlign: TextAlign.center,
                                //                     style: TextStyle(
                                //                         height: 1.4,
                                //                         color:
                                //                             AppColors.textColorGrey,
                                //                         fontSize: 10.2.sp,
                                //                         fontWeight:
                                //                             FontWeight.w400),
                                //                   ),
                                //                   Expanded(child: SizedBox()),
                                //                   Padding(
                                //                     padding:
                                //                         const EdgeInsets.symmetric(
                                //                             horizontal: 22),
                                //                     child: AppButton(
                                //                       title: 'Verify'.tr(),
                                //                       handler: () {
                                //                         Navigator.pop(context);
                                //
                                //                       },
                                //                       isGradient: true,
                                //                       color: Colors.transparent,
                                //                       textColor:
                                //                           AppColors.textColorBlack,
                                //                     ),
                                //                   ),
                                //                   SizedBox(height: 2.h),
                                //                   Padding(
                                //                     padding:
                                //                         const EdgeInsets.symmetric(
                                //                             horizontal: 22),
                                //                     child: AppButton(
                                //                         title: 'Resend code 06:00'
                                //                             .tr(),
                                //                         handler: () {
                                //                           // Navigator.push(
                                //                           //   context,
                                //                           //   MaterialPageRoute(
                                //                           //     builder: (context) => TermsAndConditions(),
                                //                           //   ),
                                //                           // );
                                //                         },
                                //                         isGradient: false,
                                //                         textColor: themeNotifier
                                //                                 .isDark
                                //                             ? AppColors
                                //                                 .textColorWhite
                                //                             : AppColors
                                //                                 .textColorBlack
                                //                                 .withOpacity(0.8),
                                //                         color: Colors.transparent),
                                //                   ),
                                //                   Expanded(child: SizedBox()),
                                //                 ],
                                //               ),
                                //             )),
                                //       );
                                //     },
                                //   );
                                // },
                                isGradient: true,
                                color: Colors.transparent,
                                textColor: AppColors.textColorBlack,
                              ),
                              // SizedBox(
                              //   height: 3.h,
                              // ),
                            ],
                          ),
                        ))
                  ],
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

  Widget otpContainer({
    required FocusNode focusNode,
    required Function handler,
  }) {
    return TextFieldParent(
      width: 9.8.w,
      otpHeight: 8.h,
      child: TextField(
        focusNode: focusNode,
        onChanged: (value) => handler(),
        keyboardType: TextInputType.number,
        cursorColor: AppColors.textColorGrey,
        // obscureText: true,
        maxLength: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
        ],
        // Hide the entered OTP digits
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.bottom,
        style: TextStyle(
          color: AppColors.textColorGrey,
          fontSize: 17.5.sp,
          // fontWeight: FontWeight.bold,
          letterSpacing: 16,
        ),
        decoration: InputDecoration(
          counterText: '', // Hide the default character counter
          contentPadding: EdgeInsets.only(left: 11, top: 16, bottom: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.textColorGrey,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.textColorGrey,
              width: 1,
            ),
          ),
        ),
      ),
      // height: 8.h,
      // width: 10.w,
      // decoration: BoxDecoration(
      //   color: Colors.transparent,
      //   borderRadius: BorderRadius.circular(10),
      // ),
    );
  }
}
