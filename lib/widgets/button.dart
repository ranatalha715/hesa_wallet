import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../providers/theme_provider.dart';

class AppButton extends StatelessWidget {
  final String title;
  final Function handler;
  final bool isGradient;
  final Color color;
  final Color textColor;
  final Color buttonWithBorderColor;
  final double width;
  final bool isactive;
  final bool isLoading;
  final bool isGradientWithBorder;
  final bool? secondBtnBorderClr;

  const AppButton({
    Key? key,
    required this.title,
    required this.handler,
    required this.isGradient,
    required this.color,
    this.secondBtnBorderClr=false,
    this.width = double.infinity,
    this.textColor = AppColors.textColorBlack,
    this.buttonWithBorderColor = AppColors.hexaGreen,
    this.isactive = true,
    this.isLoading = false,
    this.isGradientWithBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return GestureDetector(
        onTap: () => handler(),
        child: Container(
          height: 6.5.h,
          width: width,
          decoration: isGradient
              ? isactive
                  ? BoxDecoration(
                      // gradient: LinearGradient(
                      //   colors: [Color(0xff92B928), Color(0xffC9C317)],
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      // ),
            color: AppColors.activeButtonColor,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : BoxDecoration(
                      color: themeNotifier.isDark
                          ? AppColors.appButtonUnselectedDark
                          : AppColors.disabaledBtnColor, // LIGHT
                      borderRadius: BorderRadius.circular(10),
                    )
              : BoxDecoration(
            color: themeNotifier.isDark
                ? color == null ? AppColors.transparentBtnBorderColorDark.withOpacity(0.10) : color
                : AppColors.disabaledBtnColor, // LIGHT
            border:  Border.all(
                color: secondBtnBorderClr! && isGradientWithBorder ?  AppColors
                    .focusTextFieldColor: isGradientWithBorder  ? buttonWithBorderColor: Colors.transparent
            ), 
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: isLoading
                  ? CircularProgressIndicator(
                      color: AppColors.backgroundColor.withOpacity(0.7),
                    )
                  : Text(
                      title,
                      style: TextStyle(
                          color: isGradient ? isactive
                              ? textColor
                              :
                          themeNotifier.isDark
                                  ? AppColors.unselectedBtnTextColor
                                  : AppColors.textColorGreyShade3:
                          isGradientWithBorder ?
                          AppColors.textColorWhite:  AppColors.textColorGreyShade3,
                          fontSize: 11.7.sp,
                          fontWeight: FontWeight.w600),
                    )),
        ),
      );
    });
  }
}


class AppButtonForResendOtp extends StatelessWidget {
  final String title;
  final Function handler;
  final bool isGradient;
  final Color color;
  final Color textColor;
  final Color buttonWithBorderColor;
  final double width;
  final bool isactive;
  final bool isLoading;
  final bool isGradientWithBorder;
  final bool? secondBtnBorderClr;

  const AppButtonForResendOtp({
    Key? key,
    required this.title,
    required this.handler,
    required this.isGradient,
    required this.color,
    this.secondBtnBorderClr=false,
    this.width = double.infinity,
    this.textColor = AppColors.textColorBlack,
    this.buttonWithBorderColor = AppColors.hexaGreen,
    this.isactive = true,
    this.isLoading = false,
    this.isGradientWithBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return GestureDetector(
        onTap: () => handler(),
        child: Container(
          height: 6.5.h,
          width: width,
          decoration: isGradient
              ? isactive
              ? BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [Color(0xff92B928), Color(0xffC9C317)],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
            color: AppColors.activeButtonColor,
            borderRadius: BorderRadius.circular(10),
          )
              : BoxDecoration(
            color: themeNotifier.isDark
                ? AppColors.appButtonUnselectedDark
                : AppColors.disabaledBtnColor, // LIGHT
            borderRadius: BorderRadius.circular(10),
          )
              : BoxDecoration(
            color: themeNotifier.isDark
                ? color == null ? AppColors.transparentBtnBorderColorDark.withOpacity(0.10) : color
                : AppColors.disabaledBtnColor, // LIGHT
            border:  Border.all(
                color: secondBtnBorderClr! && isGradientWithBorder ?  AppColors
                    .focusTextFieldColor: isGradientWithBorder  ? buttonWithBorderColor: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: isLoading
                  ? CircularProgressIndicator(
                color: AppColors.backgroundColor.withOpacity(0.7),
              )
                  : Text(
                title,
                style: TextStyle(
                    color:
                         textColor,
                    fontSize: 11.7.sp,
                    fontWeight: FontWeight.w600),
              )),
        ),
      );
    });
  }
}
