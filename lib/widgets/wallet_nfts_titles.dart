import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../constants/string_utils.dart';

class WalletNftsTitles extends StatefulWidget {
  bool isOpened;
  final String title;
  bool isDark;
  Function handler;
  final int length;

  WalletNftsTitles(
      {this.isOpened = false,
      required this.title,
      this.isDark = true,
      required this.handler,
      required this.length,

      });

  @override
  State<WalletNftsTitles> createState() => _WalletNftsTitlesState();
}

class _WalletNftsTitlesState extends State<WalletNftsTitles> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.handler(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15.sp),
        decoration: BoxDecoration(
            color: AppColors.profileHeaderDark,
            // border: Border.all(
            //     ),
            borderRadius: BorderRadius.circular(8)),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 13.sp),
          child: Row(
            children: [
              Container(
                  height: 3.5.h,
                  width: 3.8.h,
                  decoration: BoxDecoration(
                    color: AppColors.textColorWhite.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      formatNumber(widget.length),
                      style: TextStyle(
                          color: widget.isDark
                              ? AppColors.textColorGreyShade2
                              : AppColors.textColorBlack,
                          fontWeight: FontWeight.w600,
                          fontSize: 7.sp,
                          fontFamily: 'Inter'),
                    ),
                  )),
              SizedBox(
                width: 3.w,
              ),
              Text(
                widget.title,
                style: TextStyle(
                    color: widget.isDark
                        ? AppColors.textColorWhite
                        : AppColors.textColorBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 11.7.sp,
                    fontFamily: 'Blogger Sans'),
              ),
              Spacer(),
              Image.asset(
                widget.isOpened
                    ? "assets/images/drop_up.png"
                    : "assets/images/drop_down.png",
                height: 20.sp,
              )
            ],
          ),
        ),
      ),
    );
  }
}
