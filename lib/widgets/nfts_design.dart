import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/models/nfts_model.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../models/nfts_model.dart';
import '../screens/user_profile_pages/nfts_collection_details.dart';
import '../screens/user_profile_pages/nfts_details.dart';

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
      onTap: () =>
          Navigator.of(context).pushNamed(NftsDetails.routeName,
              arguments: {
                'tokenName': widget.nfts.tokenName,
                'tokenId': widget.nfts.id,
                'creatorId': widget.nfts.creatorId,
                'image' : widget.nfts.tokenURI,
                'creatorRoyalty': widget.nfts.creatorRoyalty,
                'ownerId': widget.nfts.ownerId,
                // 'nftIds': widget.nftsCollection.nftIds.length.toString(),
                'standard': widget.nfts.standard.toString(),
                'chain': widget.nfts.chain.toString(),
                'createdAt': widget.nfts.createdAt.toString(),
                'status': widget.nfts.status.toString(),
                'listingType': widget.nfts.listingType.toString(),
                'isListable': widget.nfts.isListable.toString(),
              }
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
         Container(
              // decoration: BoxDecoration(color: AppColors.textColorGreyShade2.withOpacity(0.25)),
              height: 27.2.h,
              width: double.infinity,
              child:   Image.network(
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

                  // child: BackdropFilter(
                  //   filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child:
               Container(
                  height: 7.2.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    color: AppColors.textColorBlack.withOpacity(0.7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.nfts.tokenName,
                          overflow: TextOverflow.ellipsis,
                          // widget.nfts.tokenName,
                          // 'Neo Cube#812'.tr(),
                          style: TextStyle(
                              color: AppColors.textColorWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.sp,
                          fontFamily: 'Clash Display',
                          ),
                        ),
                        SizedBox(
                          height: 0.2.h,
                        ),
                        Text(
                          widget.nfts.status!,
                          // widget.nfts.tokenName,
                          // 'Neo Cube#812'.tr(),
                          style: TextStyle(
                              color: AppColors.nftsSubtitle,
                              fontWeight: FontWeight.w600,
                              fontSize: 9.sp),
                        ),
                        SizedBox(
                          height: 0.1.h,
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
                )
            //       )
            )
          ],
        ),
      ),
    );
  }
}
