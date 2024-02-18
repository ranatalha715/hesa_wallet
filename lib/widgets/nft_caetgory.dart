
import 'package:flutter/cupertino.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';

class NFTCategory extends StatelessWidget {
 final String title;
 final bool isFirst;
final Function? handler;

  const NFTCategory({Key? key, required this.title, this.isFirst=false, this.handler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        onTap: ()=> handler!(),
        child: Container(
        margin: EdgeInsets.only(right: 10.sp),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textColorGrey,
            width: 1

          ),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 12.sp, vertical: isFirst? 8.sp: 6.sp),
          child: Row(
            children: [
              // if(!isFirst)
              //   Image.asset(image,
              //   // height: 34,
              //   ),
              // SizedBox(width: 4.sp,),
              Text(title,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textColorGrey
              ),
              ),

            ],
          ),
        ),
    ),
      );
  }
}
