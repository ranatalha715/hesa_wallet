import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/main_header.dart';

class Language extends StatefulWidget {
  const Language({Key? key}) : super(key: key);

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {

  var _isLoading = false;
  var _isinit= true;
  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if(_isinit){
    }
    _isinit=false;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(title: 'Languages'.tr()),
                Container(
                  height: 85.h,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 4.h,
                        ),
                        Align(
                          alignment: isEnglish
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Text(
                            'Select language'.tr() + ":",
                            style: TextStyle(
                                fontSize: 13.5.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack),
                          ),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        selectLanguage(
                            "assets/images/USlanguage.png", 'English', 0, 'ENG',
                            () {
                          context.locale = Locale('en', 'US');
                        },
                            selected: isEnglish ? true : false,
                            isChecked: isEnglish ? true : false,
                            isDark: themeNotifier.isDark ? true : false),
                        SizedBox(
                          height: 1.h,
                        ),
                        selectLanguage(
                            "assets/images/AElanguage.png", 'Arabic', 1, 'العربية',
                            () {
                          context.locale = Locale('ar', 'AE');
                          // exit(0);
                        },
                            selected: isEnglish ? false : true,
                            isChecked: isEnglish ? false : true,
                            isDark: themeNotifier.isDark ? true : false),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(_isLoading)
            LoaderBluredScreen()
        ],
      );
    });
  }

  Widget selectLanguage(
      String image, String title, int index, String subTitle, Function? handler,
      {bool selected = false, bool isChecked = false, bool isDark = true}) {
    return GestureDetector(
      onTap: () {
        handler!();
      },
      child: Container(
        height: 6.5.h,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                selected ? AppColors.selectedLanguageBorder : AppColors.textColorGrey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                child: Text(
                  subTitle,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.7.sp,
                      color: isDark
                          ? AppColors.textColorWhite
                          : AppColors.textColorBlack),
                ),
              ),
              SizedBox(
                width: 1.w,
              ),
              Container(
                width: 1.sp,
                color: AppColors.languageDivider,
                margin: EdgeInsets.symmetric(vertical: 8.sp),
              ),
              SizedBox(
                width: 3.w,
              ),
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11.7.sp,
                    color: isDark
                        ? AppColors.textColorWhite
                        : AppColors.textColorBlack),
              ),
              Spacer(),
              if (isChecked)
                Image.asset(
                  "assets/images/check_circle.png",
                  height: 4.h,
                  width: 3.h,
                  color: AppColors.selectedLanguageBorder,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
