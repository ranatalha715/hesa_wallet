import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';


class ShimmerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child:  Shimmer.fromColors(
        baseColor: AppColors.profileHeaderDark,
        highlightColor: AppColors.textColorGrey.withOpacity(0.10),
        child: Container(
          height: 27.2.h,
          // width: ,
          decoration: BoxDecoration(
            color: AppColors.profileHeaderDark,
            shape: BoxShape.rectangle,
          ),
        ),
      ),

    );
  }
}
