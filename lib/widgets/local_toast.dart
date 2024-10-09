import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:sizer/sizer.dart'; // Make sure to include this package

void localToast(BuildContext context, String message, {int duration = 3000,}) {
  final fToast = FToast();
  fToast.init(context); // Initialize the toast with the context

  Widget toast = Container(
    height: 8.h,
    padding:  EdgeInsets.symmetric(horizontal: 20.sp,),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6.sp),
      color: AppColors.backgroundColor,
      border: Border.all(
        width: 1.sp,
        color: AppColors.hexaGreen,
      )
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            color: Colors.transparent,
            child: Text(
              message,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.hexaGreen,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              )
                  // .apply(fontWeightDelta: -2),
            ),
          ),
        ),
      ],
    ),
  );

  // Show the custom toast
  fToast.showToast(
    child: toast,
    toastDuration: Duration(milliseconds: duration),
    positionedToastBuilder: (context, child) {
      return Positioned(
        child: Center(child: child),
        top: 35.sp,
        left: 10.sp,
        right: 10.sp,
      );
    },
  );
}
