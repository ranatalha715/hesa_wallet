import 'dart:async';
import 'dart:ffi';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/screens/signup_signin/signin_with_email.dart';
import 'package:hesa_wallet/screens/signup_signin/signup_with_mobile.dart';
import 'package:hesa_wallet/screens/signup_signin/terms_conditions.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:hesa_wallet/widgets/otp_dialog.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/dialog_button.dart';
import '../../widgets/main_header.dart';
import '../user_profile_pages/wallet_tokens_nfts.dart';

class SigninWithMobile extends StatefulWidget {
  const SigninWithMobile({Key? key}) : super(key: key);

  @override
  State<SigninWithMobile> createState() => _SigninWithMobileState();
}

class _SigninWithMobileState extends State<SigninWithMobile> {
  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  final TextEditingController _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateMobileNumber(String value) {
    if (value.isEmpty) {
      return 'Please enter a mobile number';
    }
    if (!_isValidMobileNumber(value)) {
      return 'Invalid mobile number';
    }
    return null;
  }

  bool _isValidMobileNumber(String value) {
    // Custom logic to validate the mobile number
    // You can replace this with your own validation rules
    return value.startsWith('+966') && value.length == 13;
  }

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();

  bool isValidating = false;
  bool isButtonActive = false;
  bool isOtpButtonActive = false;
  var _isLoading = false;
  Timer? _timer;
  bool _isTimerActive = false;
  var _isLoadingResend = false;

  var tokenizedUserPL;

  getTokenizedUserPayLoad() async {
    final prefs = await SharedPreferences.getInstance();
    tokenizedUserPL = await prefs.getString('tokenizedUserPayload');
  }

  @override
  void initState() {
    super.initState();
    getTokenizedUserPayLoad();
    // Listen for changes in the text fields and update the button state
    _numberController.addListener(_updateButtonState);
    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _numberController.text.isNotEmpty;
    });
  }

  void _updateOtpButtonState() {
    setState(() {
      isOtpButtonActive = otp1Controller.text.isNotEmpty &&
          otp2Controller.text.isNotEmpty &&
          otp3Controller.text.isNotEmpty &&
          otp4Controller.text.isNotEmpty &&
          otp5Controller.text.isNotEmpty &&
          otp6Controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    otp5Controller.dispose();
    otp6Controller.dispose();

    super.dispose();
  }

  void startTimer() {
    _isTimerActive = true;
    _timer = Timer(Duration(seconds: 5), () {
      setState(() {
        _isTimerActive = false;
      });
      // The timer has finished, allowing the function to be called again
    });
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Builder(builder: (BuildContext context) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: themeNotifier.isDark
                  ? AppColors.backgroundColor
                  : AppColors.textColorWhite,
              body: Column(
                children: [
                  MainHeader(title: 'Login'.tr()),
                  Expanded(
                    child: Container(
                      // color: Colors.red,
                      height: 85.h,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 4.h,
                              ),
                              Text(
                                "Login using Mobile Number.".tr(),
                                style: TextStyle(
                                    color: AppColors.textColorGrey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11.7.sp,
                                    fontFamily: 'Inter'),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Align(
                                alignment: isEnglish
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Text(
                                  'Mobile number'.tr(),
                                  style: TextStyle(
                                      fontSize: 11.7.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: themeNotifier.isDark
                                          ? AppColors.textColorWhite
                                          : AppColors.textColorBlack),
                                ),
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              TextFieldParent(
                                child: TextFormField(
                                    controller: _numberController,
                                    // validator: (v)=>_validateMobileNumber(_numberController.text),
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            150),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        fontSize: 10.2.sp,
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorBlack,
                                        fontWeight: FontWeight.w400,
                                        // Off-white color,
                                        fontFamily: 'Inter'),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 16.0),
                                      hintText: 'Enter your mobile number'.tr(),
                                      hintStyle: TextStyle(
                                          fontSize: 10.2.sp,
                                          color: AppColors.textColorGrey,
                                          fontWeight: FontWeight.w400,
                                          // Off-white color,
                                          fontFamily: 'Inter'),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            // Off-white color
                                            // width: 2.0,
                                          )),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            // Off-white color
                                            // width: 2.0,
                                          )),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 14, right: 12),
                                        child: Text(
                                          '+966',
                                          style: TextStyle(
                                            color: themeNotifier.isDark
                                                ? AppColors.textColorWhite
                                                : AppColors.textColorBlack,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    cursorColor: AppColors.textColorGrey),
                              ),
                              if (_numberController.text.isEmpty &&
                                  isValidating)
                                Padding(
                                  padding: EdgeInsets.only(top: 7.sp),
                                  child: Text(
                                    // "*Mobile number not recognized",
                                    "*Mobile number should not be empty",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.sp,
                                        color: AppColors.errorColor),
                                  ),
                                ),
                              Expanded(child: SizedBox()),
                              // AppButton(
                              //     title: 'Sign in with password'.tr(),
                              //     handler: () {
                              //       Navigator.push(
                              //         context,
                              //         SlideRightPageRoute(page: SigninWithEmail()),
                              //       );
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => SigninWithEmail(),
                                    //   ),
                                    // );
                              //     },
                              //     isGradient: false,
                              //     textColor: themeNotifier.isDark
                              //         ? AppColors.textColorWhite
                              //         : AppColors.textColorBlack,
                              //     color: Colors.transparent),
                              // SizedBox(height: 2.h),
                              AppButton(
                                title: 'Log in'.tr(),
                                isactive: isButtonActive ? true : false,
                                handler: () async {
                                  setState(() {
                                    isValidating = true;
                                  });
                                  if (_numberController.text.isNotEmpty) {
                                    setState(() {
                                      _isLoading = true;
                                      if (_isLoading) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      }
                                    });
                                    final result =
                                        await Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .sendLoginOTP(
                                      mobile: _numberController.text,
                                      context: context,
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (result == AuthResult.success) {
                                    otpDialog(
                                      firstBtnHandler: () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        print('loading popup' +
                                            _isLoading.toString());
                                        Navigator.pop(context);
                                        // Future.delayed(Duration(seconds: 2));
                                        // final loginResult =
                                            await Provider.of<AuthProvider>(context,
                                            listen: false)
                                            .logInWithMobile(
                                              mobile: _numberController.text,
                                              context: context, code:
                                            otp1Controller.text +
                                                otp2Controller.text +
                                                otp3Controller.text +
                                                otp4Controller.text +
                                                otp5Controller.text+
                                                otp6Controller.text,
                                            );
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        print('loading popup 2' +
                                            _isLoading.toString());
                                      },
                                        secondBtnHandler: () async {
                                          print('second handler calling');
                                          try {
                                            final result = await Provider.of<
                                                AuthProvider>(
                                                context,
                                                listen:
                                                false)
                                                .sendLoginOTP(mobile: _numberController.text, context: context);
                                            // setState(() {
                                            //   _isLoadingResend = false;
                                            // });
                                            startTimer();
                                            if (result ==
                                                AuthResult
                                                    .success) {}
                                          } catch (error) {
                                            print(
                                                "Error: $error");
                                            // _showToast('An error occurred'); // Show an error message
                                          } finally {
                                            setState(() {
                                              _isLoadingResend =
                                              false;
                                            });
                                          }

                                        },
                                      // firstBtnHandler: () async {
                                      //   print('first handler calling');
                                      //   if (_isLoading) return;
                                      //   //
                                      //   setState(() {
                                      //     _isLoading = true;
                                      //   });
                                      //   print('loading first handler calling');
                                      //   print(_isLoading.toString());
                                      //
                                      //   try {
                                      //     print(_numberController.text);
                                      //     print(otp6Controller.text);
                                      //
                                      //     final result =
                                      //         await Provider.of<AuthProvider>(
                                      //                 context,
                                      //                 listen: false)
                                      //             .verifyUser(
                                      //       context: context,
                                      //       mobile: _numberController.text,
                                      //       code: otp1Controller.text +
                                      //           otp2Controller.text +
                                      //           otp3Controller.text +
                                      //           otp4Controller.text +
                                      //           otp5Controller.text +
                                      //           otp6Controller.text,
                                      //       // token: tokenizedUserPL,
                                      //       token: tokenizedUserPL,
                                      //       // Provider.of<AuthProvider>(
                                      //       //         context,
                                      //       //         listen: false)
                                      //       //     .tokenizedUserPayload,
                                      //     );
                                      //     setState(() {
                                      //       _isLoading = false;
                                      //     });
                                      //     if (result == AuthResult.success) {
                                      //bad mai dekhyngy
                                      // await Navigator
                                      //     .push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder:
                                      //         (context) =>
                                      //         TermsAndConditions(),
                                      //   ),
                                      // );
                                      //       Navigator.of(context)
                                      //           .pushNamedAndRemoveUntil(
                                      //               'nfts-page',
                                      //               (Route d) => false,
                                      //               arguments: {});
                                      //     }
                                      //   } catch (error) {
                                      //     print("Error: $error");
                                      //     // _showToast('An error occurred'); // Show an error message
                                      //   } finally {
                                      //     setState(() {
                                      //       _isLoading = false;
                                      //     });
                                      //   }
                                      // },

                                      firstTitle: 'Confirm',
                                      // secondTitle: 'Resend code',
                                      secondTitle: _timer.toString(),
                                      context: context,
                                      isDark: themeNotifier.isDark,
                                      isFirstButtonActive: isOtpButtonActive,
                                      isSecondButtonActive: false,
                                      otp1Controller: otp1Controller,
                                      otp2Controller: otp2Controller,
                                      otp3Controller: otp3Controller,
                                      otp4Controller: otp4Controller,
                                      otp5Controller: otp5Controller,
                                      otp6Controller: otp6Controller,
                                      firstFieldFocusNode: firstFieldFocusNode,
                                      secondFieldFocusNode:
                                          secondFieldFocusNode,
                                      thirdFieldFocusNode: thirdFieldFocusNode,
                                      forthFieldFocusNode: forthFieldFocusNode,
                                      fifthFieldFocusNode: fifthFieldFocusNode,
                                      sixthFieldFocusNode: sixthFieldFocusNode,
                                      firstBtnBgColor:
                                          AppColors.activeButtonColor,
                                      firstBtnTextColor:
                                          AppColors.textColorBlack,
                                      secondBtnBgColor: Colors.transparent,
                                      secondBtnTextColor: themeNotifier.isDark
                                          ? AppColors.textColorWhite
                                          : AppColors.textColorBlack
                                              .withOpacity(0.8),
                                      isLoading: _isLoading,
                                    );}
                                    // showDialog(
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     final screenWidth =
                                    //         MediaQuery.of(context).size.width;
                                    //     final dialogWidth = screenWidth * 0.85;
                                    //     return StatefulBuilder(builder:
                                    //         (BuildContext context,
                                    //             StateSetter setState) {
                                    //       return Dialog(
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(8.0),
                                    //         ),
                                    //         backgroundColor: Colors.transparent,
                                    //         child: BackdropFilter(
                                    //             filter: ImageFilter.blur(
                                    //                 sigmaX: 7, sigmaY: 7),
                                    //             child: Container(
                                    //               height: 54.h,
                                    //               width: dialogWidth,
                                    //               decoration: BoxDecoration(
                                    //                 color: themeNotifier.isDark
                                    //                     ? AppColors
                                    //                         .showDialogClr
                                    //                     : AppColors
                                    //                         .textColorWhite,
                                    //                 borderRadius:
                                    //                     BorderRadius.circular(
                                    //                         15),
                                    //               ),
                                    //               child: Column(
                                    //                 children: [
                                    //                   SizedBox(
                                    //                     height: 4.h,
                                    //                   ),
                                    //                   Align(
                                    //                     alignment: Alignment
                                    //                         .bottomCenter,
                                    //                     child: Image.asset(
                                    //                       "assets/images/svg_icon.png",
                                    //                       color: AppColors
                                    //                           .textColorWhite,
                                    //                       height: 5.9.h,
                                    //                       width: 5.6.h,
                                    //                     ),
                                    //                   ),
                                    //                   SizedBox(height: 2.h),
                                    //                   Text(
                                    //                     'OTP verification'.tr(),
                                    //                     style: TextStyle(
                                    //                         fontWeight:
                                    //                             FontWeight.w600,
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
                                    //                         MainAxisAlignment
                                    //                             .center,
                                    //                     children: [
                                    //                       otpContainer(
                                    //                         controller:
                                    //                             otp1Controller,
                                    //                         focusNode:
                                    //                             firstFieldFocusNode,
                                    //                         previousFocusNode:
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
                                    //                         controller:
                                    //                             otp2Controller,
                                    //                         focusNode:
                                    //                             secondFieldFocusNode,
                                    //                         previousFocusNode:
                                    //                             firstFieldFocusNode,
                                    //                         handler: () => FocusScope
                                    //                                 .of(context)
                                    //                             .requestFocus(
                                    //                                 thirdFieldFocusNode),
                                    //                       ),
                                    //                       SizedBox(
                                    //                         width: 0.8.h,
                                    //                       ),
                                    //                       otpContainer(
                                    //                         controller:
                                    //                             otp3Controller,
                                    //                         focusNode:
                                    //                             thirdFieldFocusNode,
                                    //                         previousFocusNode:
                                    //                             secondFieldFocusNode,
                                    //                         handler: () => FocusScope
                                    //                                 .of(context)
                                    //                             .requestFocus(
                                    //                                 forthFieldFocusNode),
                                    //                       ),
                                    //                       SizedBox(
                                    //                         width: 0.8.h,
                                    //                       ),
                                    //                       otpContainer(
                                    //                         controller:
                                    //                             otp4Controller,
                                    //                         focusNode:
                                    //                             forthFieldFocusNode,
                                    //                         previousFocusNode:
                                    //                             thirdFieldFocusNode,
                                    //                         handler: () => FocusScope
                                    //                                 .of(context)
                                    //                             .requestFocus(
                                    //                                 fifthFieldFocusNode),
                                    //                       ),
                                    //                       SizedBox(
                                    //                         width: 0.8.h,
                                    //                       ),
                                    //                       otpContainer(
                                    //                         controller:
                                    //                             otp5Controller,
                                    //                         focusNode:
                                    //                             fifthFieldFocusNode,
                                    //                         previousFocusNode:
                                    //                             forthFieldFocusNode,
                                    //                         handler: () => FocusScope
                                    //                                 .of(context)
                                    //                             .requestFocus(
                                    //                                 sixthFieldFocusNode),
                                    //                       ),
                                    //                       SizedBox(
                                    //                         width: 0.8.h,
                                    //                       ),
                                    //                       otpContainer(
                                    //                         controller:
                                    //                             otp6Controller,
                                    //                         focusNode:
                                    //                             sixthFieldFocusNode,
                                    //                         previousFocusNode:
                                    //                             fifthFieldFocusNode,
                                    //                         handler: () => null,
                                    //                       ),
                                    //                     ],
                                    //                   ),
                                    //                   // SizedBox(
                                    //                   //   height: 2.h,
                                    //                   // ),
                                    //                   // Text(
                                    //                   //   '*Incorrect verification code'
                                    //                   //       .tr(),
                                    //                   //   style: TextStyle(
                                    //                   //       color: AppColors
                                    //                   //           .errorColor,
                                    //                   //       fontSize: 10.2.sp,
                                    //                   //       fontWeight:
                                    //                   //       FontWeight
                                    //                   //           .w400),
                                    //                   // ),
                                    //                   //
                                    //                   SizedBox(
                                    //                     height: 5.h,
                                    //                   ),
                                    //                   // Expanded(
                                    //                   //     child: SizedBox())
                                    //                   Padding(
                                    //                       padding: EdgeInsets
                                    //                           .symmetric(
                                    //                               horizontal:
                                    //                                   22.sp),
                                    //                       child: DialogButton(
                                    //                         title:
                                    //                             'Confirm'.tr(),
                                    //                         isactive:
                                    //                             isOtpButtonActive,
                                    //                         handler: () async {
                                    //                           if (_isLoading)
                                    //                             return;
                                    //
                                    //                           setState(() {
                                    //                             _isLoading =
                                    //                                 true;
                                    //                           });
                                    //
                                    //                           try {
                                    //                             final result = await Provider.of<
                                    //                                         AuthProvider>(
                                    //                                     context,
                                    //                                     listen:
                                    //                                         false)
                                    //                                 .verifyUser(
                                    //                               context:
                                    //                                   context,
                                    //                               mobile:
                                    //                                   _numberController
                                    //                                       .text,
                                    //                               code: otp1Controller.text +
                                    //                                   otp2Controller
                                    //                                       .text +
                                    //                                   otp3Controller
                                    //                                       .text +
                                    //                                   otp4Controller
                                    //                                       .text +
                                    //                                   otp5Controller
                                    //                                       .text +
                                    //                                   otp6Controller
                                    //                                       .text,
                                    //                               token: Provider.of<
                                    //                                           AuthProvider>(
                                    //                                       context,
                                    //                                       listen:
                                    //                                           false)
                                    //                                   .tokenizedUserPayload,
                                    //                             );
                                    //                             setState(() {
                                    //                               _isLoading =
                                    //                                   false;
                                    //                             });
                                    //                             if (result ==
                                    //                                 AuthResult
                                    //                                     .success) {
                                    //                               //bad mai dekhyngy
                                    //                               // await Navigator
                                    //                               //     .push(
                                    //                               //   context,
                                    //                               //   MaterialPageRoute(
                                    //                               //     builder:
                                    //                               //         (context) =>
                                    //                               //         TermsAndConditions(),
                                    //                               //   ),
                                    //                               // );
                                    //                               Navigator.of(context).pushNamedAndRemoveUntil(
                                    //                                   'nfts-page',
                                    //                                   (Route d) =>
                                    //                                       false,
                                    //                                   arguments: {});
                                    //                             }
                                    //                           } catch (error) {
                                    //                             print(
                                    //                                 "Error: $error");
                                    //                             // _showToast('An error occurred'); // Show an error message
                                    //                           } finally {
                                    //                             setState(() {
                                    //                               _isLoading =
                                    //                                   false;
                                    //                             });
                                    //                           }
                                    //                         },
                                    //                         // isGradient: true,
                                    //                         isLoading:
                                    //                             _isLoading,
                                    //                         color: AppColors
                                    //                             .activeButtonColor,
                                    //                         textColor: AppColors
                                    //                             .textColorBlack,
                                    //                       )
                                    //                   ),
                                    //                   SizedBox(height: 2.h),
                                    //                   Padding(
                                    //                     padding: EdgeInsets
                                    //                         .symmetric(
                                    //                             horizontal:
                                    //                                 22.sp),
                                    //                     child: AppButton(
                                    //                         title:
                                    //                             'Resend code 06:00'
                                    //                                 .tr(),
                                    //                         handler: () async {
                                    //                           // if (_isLoading || _isTimerActive) return;
                                    //                           //
                                    //                           // setState(() {
                                    //                           //   _isLoadingResend = true;
                                    //                           // });
                                    //
                                    //                           try {
                                    //                             final result = await Provider.of<
                                    //                                         AuthProvider>(
                                    //                                     context,
                                    //                                     listen:
                                    //                                         false)
                                    //                                 .resendRegisterOTP(
                                    //                               context:
                                    //                                   context,
                                    //                             );
                                    //                             // setState(() {
                                    //                             //   _isLoadingResend = false;
                                    //                             // });
                                    //                             startTimer();
                                    //                             if (result ==
                                    //                                 AuthResult
                                    //                                     .success) {}
                                    //                           } catch (error) {
                                    //                             print(
                                    //                                 "Error: $error");
                                    //                             // _showToast('An error occurred'); // Show an error message
                                    //                           } finally {
                                    //                             setState(() {
                                    //                               _isLoadingResend =
                                    //                                   false;
                                    //                             });
                                    //                           }
                                    //                         },
                                    //                         isLoading:
                                    //                             _isLoadingResend,
                                    //                         isGradient: false,
                                    //                         textColor: themeNotifier.isDark
                                    //                             ? AppColors
                                    //                                 .textColorWhite
                                    //                             : AppColors
                                    //                                 .textColorBlack
                                    //                                 .withOpacity(
                                    //                                     0.8),
                                    //                         color: Colors
                                    //                             .transparent),
                                    //                   ),
                                    //                   Expanded(
                                    //                       child: SizedBox()),
                                    //                 ],
                                    //               ),
                                    //             )),
                                    //       );
                                    //     });
                                    //   },
                                    // );
                                    //   ;
                                    // }
                                  }
                                },
                                // _isLoading: _isLoading,
                                isGradient: true,
                                color: Colors.transparent,
                                textColor: AppColors.textColorBlack,
                              ),
                              SizedBox(height: 2.h),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/SigninWithEmail',
                                    arguments: {'comingFromWallet': true}),
                                //     Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>  SigninWithEmail(), // Replace YourNewPage with your desired widget/page
                                //   ),
                                // ),
                                child: Container(
                                  // color: Colors.red,
                                  width: double.infinity,
                                  height: 4.h,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      "Login with password instead".tr(),
                                      style: TextStyle(
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorBlack,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.sp,
                                        fontFamily: 'Inter',
                                      ),
                                      // textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 2.h,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading) LoaderBluredScreen(),
          ],
        );
      });
    });
  }

  Widget otpContainer({
    required FocusNode focusNode,
    required FocusNode previousFocusNode,
    required TextEditingController controller,
    required Function handler,
  }) {
    return TextFieldParent(
      width: 9.8.w,
      otpHeight: 8.h,
      color: AppColors.transparentBtnBorderColorDark.withOpacity(0.15),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: (value) {
          if (value.isEmpty) {
            focusNode.requestFocus();
            if (controller.text.isNotEmpty) {
              controller.clear();
              handler();
            } else {
              // Move focus to the previous SMSVerificationTextField
              // and clear its value recursively
              // FocusScope.of(context).previousFocus();
              previousFocusNode.requestFocus();
            }
          } else {
            handler();
          }
        },
        // onChanged: (value) => handler(),
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
          // letterSpacing: 16,
        ),
        decoration: InputDecoration(
          counterText: '', // Hide the default character counter
          contentPadding: EdgeInsets.only(top: 16, bottom: 16),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.transparent,
                // Off-white color
                // width: 2.0,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.transparent,
                // Off-white color
                // width: 2.0,
              )),
        ),
      ),
      // height: 8.h,
      // width: 10.w,
      // decoration: BoxDecoration(
      //   color: Colors.transparent,
      //   borderRadius: BorderRadius.circular(10),
      // )
    );
  }
}
