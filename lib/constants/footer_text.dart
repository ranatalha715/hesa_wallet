import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';

class FooterText extends StatelessWidget {
  final Color? textcolor;
  FooterText({this.textcolor=AppColors.textColorGrey});

  @override
  Widget build(BuildContext context) {
    return   Text(
      'Powered by AlMajra Blockchain Network'.tr(),
      style: TextStyle(
          color: textcolor,
          fontSize: 8.7.sp,
          fontWeight: FontWeight.w400),
    );
  }
}
