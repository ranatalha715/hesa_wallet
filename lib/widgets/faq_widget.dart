import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../models/FAQ_model.dart';
import '../providers/theme_provider.dart';

class FAQWidget extends StatefulWidget {
  final FAQModel faq;
  const FAQWidget({Key? key, required this.faq}) : super(key: key);

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
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  // color:Colors.yellow,
                  width: MediaQuery.of(context).size.width*0.8,
                  child: Text(
                  widget.faq.question,
                    maxLines: 10,
                    style: TextStyle(
                        color: themeNotifier.isDark
                            ? AppColors.textColorWhite
                            : AppColors.textColorBlack,
                        fontWeight: FontWeight.w400,
                        fontSize: 11.7.sp,
                        fontFamily: 'Inter'),
                  ),
                ),
                Spacer(),
                Icon(
                  _isSelected
                      ? Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,
                  size: 19.sp,
                  color: AppColors.textColorWhite,
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          if (_isSelected)
            Text(
             widget.faq.answer, style: TextStyle(
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
