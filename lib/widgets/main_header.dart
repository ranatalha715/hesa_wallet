import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../constants/colors.dart';

class MainHeader extends StatefulWidget {
  final String title;
  final String? subTitle;
  final Function? handler;
  double? height;
  bool? IsScrolled ;
  bool showSubTitle;

  MainHeader({Key? key, required this.title, this.handler , this.height, this.IsScrolled = false,  this.subTitle,
    this.showSubTitle=false

  })
      : super(key: key);

  @override
  State<MainHeader> createState() => _MainHeaderState();
}

class _MainHeaderState extends State<MainHeader> {
  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true  : false;
    return Container(
      height: 12.h,
      width: 100.w,
      decoration: BoxDecoration(
       color: AppColors.profileHeaderDark
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.only(left: isEnglish ? 22.sp : 11.sp, bottom: isEnglish ? 12.sp : 8.sp, right: isEnglish ? 0 : 17.sp),
            child: GestureDetector(
              onTap: () => widget.handler != null
                  ? widget.handler!()
                  : Navigator.pop(context),
              child: Image.asset(
                isEnglish ? "assets/images/back_dark_oldUI.png" : "assets/images/back_arrow_left.png",
                height: isEnglish ? 3.1.h : 4.6.h,
                width:  isEnglish ? 3.1.h : 4.6.h,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: isEnglish ? 6.w : 0,),
          Padding(
            padding:  EdgeInsets.only( bottom: isEnglish ?  9.sp : 6.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                      color: AppColors.textColorWhite,
                      fontWeight: FontWeight.w500,
                      fontSize: widget.showSubTitle ? 11.sp: 13.4.sp,
                      fontFamily: widget.showSubTitle ? 'Clash Display' :'Inter')
                ),
                SizedBox(height: !widget.showSubTitle ? 0.8.h: 0.5.h,),
                if(widget.showSubTitle)
                  Text(
                  widget.subTitle!,
                  style: TextStyle(
                      color: AppColors.headerSubTitle,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.3.sp,
                      fontFamily: 'Inter'),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
