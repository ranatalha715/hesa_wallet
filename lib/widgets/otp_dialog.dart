import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
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
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final dialogWidth = screenWidth * 0.85;
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        // print("testing" + isFirstButtonActive.toString());
        print('test loading' + isLoading.toString());
        return StreamBuilder<int>(
            stream: events.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              print(snapshot.data.toString());
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.transparent,
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Stack(
                      children: [
                        Container(
                          height: 54.h,
                          width: dialogWidth,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.showDialogClr
                                : AppColors.textColorWhite,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 4.h,
                              ),
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
                                'OTP verification'.tr(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17.5.sp,
                                    color: isDark
                                        ? AppColors.textColorWhite
                                        : AppColors.textColorBlack),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OtpInputBox(
                                    controller: otp1Controller,
                                    focusNode: firstFieldFocusNode,
                                    previousFocusNode: firstFieldFocusNode,
                                    handler: () => FocusScope.of(context)
                                        .requestFocus(secondFieldFocusNode),
                                  ),
                                  SizedBox(
                                    width: 0.8.h,
                                  ),
                                  OtpInputBox(
                                    controller: otp2Controller,
                                    focusNode: secondFieldFocusNode,
                                    previousFocusNode: firstFieldFocusNode,
                                    handler: () => FocusScope.of(context)
                                        .requestFocus(thirdFieldFocusNode),
                                  ),
                                  SizedBox(
                                    width: 0.8.h,
                                  ),
                                  OtpInputBox(
                                    controller: otp3Controller,
                                    focusNode: thirdFieldFocusNode,
                                    previousFocusNode: secondFieldFocusNode,
                                    handler: () => FocusScope.of(context)
                                        .requestFocus(forthFieldFocusNode),
                                  ),
                                  SizedBox(
                                    width: 0.8.h,
                                  ),
                                  OtpInputBox(
                                    controller: otp4Controller,
                                    focusNode: forthFieldFocusNode,
                                    previousFocusNode: thirdFieldFocusNode,
                                    handler: () => FocusScope.of(context)
                                        .requestFocus(fifthFieldFocusNode),
                                  ),
                                  SizedBox(
                                    width: 0.8.h,
                                  ),
                                  OtpInputBox(
                                    controller: otp5Controller,
                                    focusNode: fifthFieldFocusNode,
                                    previousFocusNode: forthFieldFocusNode,
                                    handler: () => FocusScope.of(context)
                                        .requestFocus(sixthFieldFocusNode),
                                  ),
                                  SizedBox(
                                    width: 0.8.h,
                                  ),
                                  OtpInputBox(
                                    controller: otp6Controller,
                                    focusNode: sixthFieldFocusNode,
                                    previousFocusNode: fifthFieldFocusNode,
                                    handler: () => null,
                                  ),
                                ],
                              ),
                              // SizedBox(
                              //   height: 2.h,
                              // ),
                              // Text(
                              //   '*Incorrect verification code'
                              //       .tr(),
                              //   style: TextStyle(
                              //       color: AppColors
                              //           .errorColor,
                              //       fontSize: 10.2.sp,
                              //       fontWeight:
                              //       FontWeight
                              //           .w400),
                              // ),
                              //
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
                                    isactive: otp1Controller.text.isNotEmpty &&
                                        otp2Controller.text.isNotEmpty &&
                                        otp3Controller.text.isNotEmpty &&
                                        otp4Controller.text.isNotEmpty &&
                                        otp5Controller.text.isNotEmpty &&
                                        otp6Controller.text.isNotEmpty,
                                    handler: () => firstBtnHandler(),
                                    isLoading: isLoading,
                                    color: firstBtnBgColor,
                                    textColor: firstBtnTextColor,
                                  )),
                              SizedBox(height: 2.h),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 22.sp),
                                child: AppButton(
                                    title: secondTitle +
                                        // "${snapshot.data.toString()}"
                                        "${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')}",

                                    // secondTitle,
                                    isactive: isSecondButtonActive,
                                    handler: () => secondBtnHandler(),
                                    isGradient: false,
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
    },
  );
}
