import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../providers/theme_provider.dart';

class FAQWidget extends StatefulWidget {
  const FAQWidget({Key? key}) : super(key: key);

  @override
  State<FAQWidget> createState() => _FAQWidgetState();
}

class _FAQWidgetState extends State<FAQWidget> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _isSelected = !_isSelected;
            }),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Lorem ipsum dolor sit amet, consect.",
                  style: TextStyle(
                      color: themeNotifier.isDark
                          ? AppColors.textColorWhite
                          : AppColors.textColorBlack,
                      fontWeight: FontWeight.w400,
                      fontSize: 11.7.sp,
                      fontFamily: 'Inter'),
                ),
                Spacer(),
                Icon(
                  _isSelected
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 19.sp,
                  color: AppColors.textColorWhite,
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          if (_isSelected)
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Eget volutpat quis id ullamcorper porttitor magna ultricies. Eu id faucibus eu, id arcu. Facilisis felis, sagittis, fringilla faucibus neque. Elementum, enim, molestie at urna sed consectetur pellentesque molestie dolor. Et est eget faucibus nulla non.",
              style: TextStyle(
                  color: AppColors.textColorGreyShade2,
                  fontWeight: FontWeight.w400,
                  fontSize: 10.2.sp,
                  fontFamily: 'Inter'),
            ),
        ],
      );
    });
  }
}
