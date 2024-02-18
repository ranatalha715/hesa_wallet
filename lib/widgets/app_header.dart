import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';

class AppHeader extends StatefulWidget {
  final String title;
  final Function? handler;
  double? height;
  bool? IsScrolled ;

 AppHeader({Key? key, required this.title, this.handler , this.height, this.IsScrolled = false})
      : super(key: key);

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true  : false;
    return Container(
      height: widget.height == null  || widget.height == 0.0 ?   21.h : widget.height,
      width: 100.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff92B928), Color(0xffC9C317)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: isEnglish ? widget.IsScrolled! ?  20 : 20 : 12 , left: 20 ,  right: 20 ,
            bottom: isEnglish ? widget.IsScrolled! ?  0 : 20 : 12
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => widget.handler != null
                      ? widget.handler!()
                      : Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsets.only(top:  isEnglish ? 29.sp : 32.sp),
                    child: Image.asset(
                     isEnglish ? "assets/images/back_icon.png" : "assets/images/back_arrow_left.png",
                      height: isEnglish ? 2.6.h : 3.8.h,
                      width:  isEnglish ? 2.6.h : 3.8.h,
                    ),
                  ),
                ),
                if(widget.IsScrolled!)
                Padding(
                  padding:  EdgeInsets.only(left:10.sp , top: 27.sp),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                        color: AppColors.textColorBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 17.5.sp,
                        fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
            Spacer(),

            // SizedBox(
            //   height: 6.h,
            // ),
            if(!widget.IsScrolled!)
            Text(
              widget.title,
              style: TextStyle(
                  color: AppColors.textColorBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 17.5.sp,
                  fontFamily: 'Inter'),
            ),
          ],
        ),
      ),
    );
  }
}
