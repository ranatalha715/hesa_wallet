import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../constants/colors.dart';
import '../providers/theme_provider.dart';

class MainHeader extends StatefulWidget {
  final String title;
  final String? subTitle;
  final String? logoPath;
  final Function? handler;
  double? height;
  bool? IsScrolled;
  bool isLoadingImage;

  bool showSubTitle;
  bool showLogo;
  bool showBackBtn;

  MainHeader(
      {Key? key,
      required this.title,
      this.handler,
      this.height,
      this.IsScrolled = false,
      this.subTitle,
      this.showSubTitle = false,
      this.showLogo = false,
      this.logoPath,
      this.showBackBtn = true,
      this.isLoadingImage=false,
      })
      : super(key: key);

  @override
  State<MainHeader> createState() => _MainHeaderState();
}

class _MainHeaderState extends State<MainHeader> {
  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: themeNotifier.isDark
              ? AppColors.profileHeaderDark
              : AppColors.textColorWhite,
        ),
      );
    return Container(
        height: 12.h,
        width: 100.w,
        decoration: BoxDecoration(color: AppColors.profileHeaderDark),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.showBackBtn)
              Padding(
                padding: EdgeInsets.only(
                    left: isEnglish ? 22.sp : 11.sp,
                    bottom: isEnglish ? 12.sp : 8.sp,
                    right: isEnglish ? 0 : 17.sp),
                child: GestureDetector(
                  onTap: () => widget.handler != null
                      ? widget.handler!()
                      : Navigator.pop(context),
                  child: Image.asset(
                    isEnglish
                        ? "assets/images/back_dark_oldUI.png"
                        : "assets/images/back_arrow_left.png",
                    height: isEnglish ? 3.1.h : 4.6.h,
                    width: isEnglish ? 3.1.h : 4.6.h,
                    color: Colors.white,
                  ),
                ),
              ),
            SizedBox(
              width: isEnglish ? 6.w : 0,
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: isEnglish ? 9.sp : 6.sp,
                  left: widget.showLogo ? 0.0 : 10.sp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.showLogo)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 36.sp, right: 8.sp),
                        height: 5.h,
                        width: 5.h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.sp),
                          child: widget.isLoadingImage ?
                          Image.asset(
                            'assets/images/picture_placeholder.png',
                            // widget.nftsCollection.banner!,
                            // /'https://images.pexels.com/photos/11881429/pexels-photo-11881429.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load',
                            // Path to your placeholder image
                            fit: BoxFit.cover,
                          ):
                          Image.network(
                            widget.logoPath!,
                            // widget.nftsCollection.banner!,
                            // /'https://images.pexels.com/photos/11881429/pexels-photo-11881429.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load',
                            // Path to your placeholder image
                            fit: BoxFit.cover,
                          ),
                        ),
                        decoration: BoxDecoration(
                          // color: Colors.red,
                          borderRadius: BorderRadius.circular(
                              5.sp), // Adjust the radius as needed
                        ),
                      ),
                    ),
                  if(!isEnglish)
                  SizedBox(width: 2.w,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // color: Colors.red,
                        width: 50.w,
                        child: Text(widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.textColorWhite,
                                fontWeight: FontWeight.w700,
                                fontSize:
                                    widget.showSubTitle ? 10.5.sp : 13.4.sp,
                                fontFamily: widget.showSubTitle
                                    ? 'Clash Display'
                                    : 'Inter')),
                      ),
                      SizedBox(
                        height: !widget.showSubTitle
                            ? 0.8.h
                            : widget.showLogo
                                ? 0.3.h
                                : 0.2.h,
                      ),
                      if (widget.showSubTitle)
                        Container(
                          width: 50.w,
                          // color: Colors.yellow,
                          child: Text(
                            widget.subTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.headerSubTitle,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                                fontFamily: 'Inter'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
    });
  }
}
