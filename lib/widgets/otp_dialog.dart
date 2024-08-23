import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/providers/user_provider.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../providers/theme_provider.dart';
import 'button.dart';
import 'dialog_button.dart';
import 'otp_input_box.dart';

void otpDialog({
  required BuildContext context,
  required StreamController<int> events,
  required Function firstBtnHandler,
  required Function secondBtnHandler,
  required String firstTitle,
  required String secondTitle,
  required bool isDark,
  bool fromAuth = true,
  required bool isFirstButtonActive,
  required bool isLoading,
  required bool isSecondButtonActive,
  required TextEditingController otp1Controller,
  required TextEditingController otp2Controller,
  required TextEditingController otp3Controller,
  required TextEditingController otp4Controller,
  required TextEditingController otp5Controller,
  required TextEditingController otp6Controller,
  required FocusNode firstFieldFocusNode,
  required FocusNode secondFieldFocusNode,
  required FocusNode thirdFieldFocusNode,
  required FocusNode forthFieldFocusNode,
  required FocusNode fifthFieldFocusNode,
  required FocusNode sixthFieldFocusNode,
  required Color firstBtnBgColor,
  required Color secondBtnBgColor,
  required Color firstBtnTextColor,
  required Color secondBtnTextColor,
  Function? onClose,
  Widget? otpBoxesWidget,
  bool incorrect = false,
  bool isBlurred = true,
  bool isEmailOtpDialog = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final dialogWidth = screenWidth * 0.85;
      return Consumer<AuthProvider>(builder: (context, auth, child) {
      return Consumer<UserProvider>(builder: (context, user, child) {

        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          // print("testing" + isFirstButtonActive.toString());

          print('test loading' + isLoading.toString());
          return StreamBuilder<int>(
              stream: events.stream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                print("otp dialoge timeleft");
                print(snapshot.data.toString());
                var otpPin;
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Colors.transparent,
                  child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: isBlurred ? 7 : 0, sigmaY: isBlurred ? 7 : 0),

                      child:
                      Stack(
                        children: [
                          Container(
                            height: isEmailOtpDialog ? 70.h : 54.h,
                            width: dialogWidth,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.showDialogClr
                                  : AppColors.textColorWhite,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child:

                Column(
                              children: [
                                SizedBox(
                                  height: 4.h,
                                ),
                                if (isEmailOtpDialog)
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 18.0),
                                      child: Image.asset(
                                        "assets/images/email.png",
                                        height: 6.2.h,
                                        width: 6.2.h,
                                      ),
                                    ),
                                  ),
                                if (isEmailOtpDialog) SizedBox(height: 2.h),
                                if (isEmailOtpDialog)
                                  Text(
                                    'Email Instruction Sent'.tr(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17.sp,
                                        color: AppColors.textColorWhite),
                                  ),
                                if (isEmailOtpDialog)
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                if (isEmailOtpDialog)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      'To complete the registration please enter the code sent to your email.'
                                          .tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          height: 1.4,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.2.sp,
                                          color: AppColors.textColorGrey),
                                    ),
                                  ),
                                if (!isEmailOtpDialog)
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Image.asset(
                                      "assets/images/svg_icon.png",
                                      color: AppColors.textColorWhite,
                                      height: 5.9.h,
                                      width: 5.6.h,
                                    ),
                                  ),
                                SizedBox(height: 2.h),

                                Text(
                                  isEmailOtpDialog
                                      ? 'Enter verification Code'
                                      : 'OTP verification'.tr(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          isEmailOtpDialog ? 13.sp : 17.5.sp,
                                      color: isDark
                                          ? AppColors.textColorWhite
                                          : AppColors.textColorBlack),
                                ),

                                SizedBox(
                                  height: 2.h,
                                ),
                                Padding(
                                  padding:
                                  EdgeInsets.symmetric(
                                      horizontal: 10.sp),
                                  child: Pinput(
                                    controller: otp6Controller,
                                      length: 6,
                                      defaultPinTheme:
                                      PinTheme(
                                        width: 9.8.w,
                                        height: 8.h,
                                        textStyle: TextStyle(
                                            color: AppColors
                                                .textColorWhite,
                                            fontSize: 18.sp,
                                            fontWeight:
                                            FontWeight
                                                .w700,
                                            fontFamily:
                                            'Blogger Sans'
                                          // letterSpacing: 16,
                                        ),
                                        decoration:
                                        BoxDecoration(
                                          border: fromAuth ? Border.all(
                                              color:
                                              auth.otpErrorResponse ?
                                             AppColors.errorColor: auth.otpSuccessResponse ? AppColors.hexaGreen: Colors
                                                  .transparent,
                                            width: 0.3.sp
                                          ):
                                          Border.all(
                                              color:
                                              user.otpErrorResponse ?
                                              AppColors.errorColor: user.otpSuccessResponse ? AppColors.hexaGreen: Colors
                                                  .transparent,
                                              width: 0.3.sp
                                          )
                                          ,
                                          borderRadius: BorderRadius.circular(8),
                                          color: AppColors
                                              .transparentBtnBorderColorDark
                                              .withOpacity(
                                              0.15),
                                        ),
                                      ),
                                      pinputAutovalidateMode:
                                      PinputAutovalidateMode
                                          .onSubmit,
                                      showCursor: true,
                                      onChanged: (v)=> Provider.of<AuthProvider>(context, listen: false).otpSuccessResponse,
                                      onCompleted: (pin) async {

                                        setState(() {
                                          otpPin = pin;

                                        });
                                        print("OTP code");

                                        print(pin.toString());
                                        Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes = pin;
                                        Provider.of<AuthProvider>(context, listen: false).otpSuccessResponse;

                                        otp6Controller.text.length == 6 ? firstBtnHandler(): (){};

                                      }),
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     OtpInputBox(
                                //       controller: otp1Controller,
                                //       focusNode: firstFieldFocusNode,
                                //       previousFocusNode: firstFieldFocusNode,
                                //       handler: () => FocusScope.of(context)
                                //           .requestFocus(secondFieldFocusNode),
                                //       incorrect: auth.otpErrorResponse,
                                //       autoFocus: true,
                                //     ),
                                //     SizedBox(
                                //       width: 0.8.h,
                                //     ),
                                //     OtpInputBox(
                                //       controller: otp2Controller,
                                //       focusNode: secondFieldFocusNode,
                                //       previousFocusNode: firstFieldFocusNode,
                                //       handler: () => FocusScope.of(context)
                                //           .requestFocus(thirdFieldFocusNode),
                                //       incorrect: auth.otpErrorResponse,
                                //     ),
                                //     SizedBox(
                                //       width: 0.8.h,
                                //     ),
                                //     OtpInputBox(
                                //       controller: otp3Controller,
                                //       focusNode: thirdFieldFocusNode,
                                //       previousFocusNode: secondFieldFocusNode,
                                //       handler: () => FocusScope.of(context)
                                //           .requestFocus(forthFieldFocusNode),
                                //       incorrect: auth.otpErrorResponse,
                                //     ),
                                //     SizedBox(
                                //       width: 0.8.h,
                                //     ),
                                //     OtpInputBox(
                                //       controller: otp4Controller,
                                //       focusNode: forthFieldFocusNode,
                                //       previousFocusNode: thirdFieldFocusNode,
                                //       handler: () => FocusScope.of(context)
                                //           .requestFocus(fifthFieldFocusNode),
                                //       incorrect: auth.otpErrorResponse,
                                //     ),
                                //     SizedBox(
                                //       width: 0.8.h,
                                //     ),
                                //     OtpInputBox(
                                //       controller: otp5Controller,
                                //       focusNode: fifthFieldFocusNode,
                                //       previousFocusNode: forthFieldFocusNode,
                                //       handler: () => FocusScope.of(context)
                                //           .requestFocus(sixthFieldFocusNode),
                                //       incorrect: auth.otpErrorResponse,
                                //     ),
                                //     SizedBox(
                                //       width: 0.8.h,
                                //     ),
                                //     OtpInputBox(
                                //       controller: otp6Controller,
                                //       focusNode: sixthFieldFocusNode,
                                //       previousFocusNode: fifthFieldFocusNode,
                                //       handler: () => null,
                                //       incorrect: auth.otpErrorResponse,
                                //     ),
                                //   ],
                                // ),
                                if (auth.otpErrorResponse)
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Text(
                                      '*Incorrect verification code'.tr(),
                                      style: TextStyle(
                                          color: AppColors.errorColor,
                                          fontSize: 10.2.sp,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),

                                SizedBox(
                                  height: 5.h,
                                ),
                                // Expanded(
                                //     child: SizedBox())
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15.sp),
                                    child: DialogButton(
                                      title: firstTitle,
                                      isactive:

                                      otp6Controller.text.length == 6 ,

                                      handler: () { otp6Controller.text.length == 6 ?
                                      firstBtnHandler():
                                          (){};},
                                      isLoading: isLoading,
                                      color: firstBtnBgColor,
                                      textColor: firstBtnTextColor,
                                    )),
                                SizedBox(height: 2.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 22.sp),
                                  child: AppButton(
                                      title:
                                          // snapshot.data != null && snapshot.data! > 0 ?
                                          secondTitle +
                                              // "${snapshot.data.toString()}"
                                              "${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')}"
                                      // :secondTitle
                                      ,

                                      // secondTitle,
                                      isactive: isSecondButtonActive,
                                      handler: () {
                                        secondBtnHandler();

                                      },
                                      isGradient: false,
                                      isGradientWithBorder: false,
                                      textColor: secondBtnTextColor,
                                      color: secondBtnBgColor),
                                ),
                                Expanded(child: SizedBox()),
                              ],
                            ),

                          ),
                          // if (isLoading)
                          //   Positioned(
                          //     child: Container(
                          //       height: 54.h,
                          //       color: Colors.redAccent,
                          //       // child: LoaderBluredScreen(),
                          //     ),
                          //   )
                        ],
                      )),

                );
              });
        });
      });
      });
    },
  );

}

