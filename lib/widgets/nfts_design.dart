import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/models/nfts_model.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../models/nfts_model.dart';

class NftsDesign extends StatefulWidget {
  const NftsDesign({Key? key, required this.nfts}) : super(key: key);

  final NftsModel nfts;

  @override
  State<NftsDesign> createState() => _NftsDesignState();
}

class _NftsDesignState extends State<NftsDesign> {
  bool _isFavourite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(color: AppColors.textColorGreyShade2.withOpacity(0.25)),
                )),
            GestureDetector(
              onTap: ()=> null,
              child: Image.network(
                widget.nfts.tokenURI,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Image.network(
                    'https://cdn-icons-png.flaticon.com/512/6298/6298900.png', // Path to your placeholder image
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 7.2.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    color: AppColors.textColorBlack.withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.sp, right: 5.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.nfts.tokenName,
                          // 'Neo Cube#812'.tr(),
                          style: TextStyle(
                              color: AppColors.textColorWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 8.8.sp),
                        ),
                        SizedBox(
                          height: 0.7.h,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //         // widget.nfts.tokenId,
                        //         widget.nfts.price + " SAR",
                        //         style: TextStyle(
                        //           color:
                        //               AppColors.textColorWhite.withOpacity(0.5),
                        //           fontWeight: FontWeight.w500,
                        //           fontSize: 7.sp,
                        //         )),
                        //     Spacer(),
                        //     GestureDetector(
                        //         onTap: () => setState(() {
                        //               _isFavourite = !_isFavourite;
                        //             }),
                        //         child: _isFavourite
                        //             ? Icon(
                        //                 Icons.favorite,
                        //                 color: AppColors.errorColor,
                        //                 size: 12.sp,
                        //               )
                        //             : Icon(
                        //                 Icons.favorite_border,
                        //                 color: AppColors.textColorGreyShade2,
                        //                 size: 12.sp,
                        //               ))
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
