import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../providers/theme_provider.dart';

class DialogButton extends StatelessWidget {
  final String title;
  final Function handler;

  final Color color;
  final Color textColor;
  final double width;
  final bool isactive;
  final bool isLoading;

  const DialogButton({
    Key? key,
    required this.title,
    required this.handler,
    required this.color,
    this.width = double.infinity,
    this.textColor = AppColors.textColorBlack,
    this.isactive = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return GestureDetector(
        onTap: () => handler(),
        child: Container(
          height: 6.5.h,
          width: width,
          decoration: isactive
              ? BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          )
              : BoxDecoration(
            color: themeNotifier.isDark
                ? AppColors.inActiveDialogButton.withOpacity(0.20)
                : AppColors.disabaledBtnColor, // LIGHT
            borderRadius: BorderRadius.circular(10),
          )
             ,
          child: Center(
              child: isLoading
                  ? CircularProgressIndicator(
                color: AppColors.backgroundColor.withOpacity(0.7),
              )
                  : Text(
                title,
                style: TextStyle(
                    color: isactive
                        ? textColor
                        : themeNotifier.isDark
                        ? AppColors.textColorGreyShade2
                        : AppColors.textColorGreyShade3,
                    fontSize: 11.7.sp,
                    fontWeight: FontWeight.w600),
              )),
        ),
      );
    });
  }
}
