import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../models/assets_model.dart';
import '../models/nfts_model.dart';
import '../screens/user_profile_pages/nfts_collection_details.dart';

class NftsCollectionDesign extends StatefulWidget {
  const NftsCollectionDesign({Key? key, required this.nftsCollection})
      : super(key: key);

  final NftsCollectionModel nftsCollection;

  @override
  State<NftsCollectionDesign> createState() => _NftsCollectionDesignState();
}

class _NftsCollectionDesignState extends State<NftsCollectionDesign> {
  // bool _isFavourite = false;

  @override
  Widget build(BuildContext context) {
    print('collectionId' + widget.nftsCollection.collectionId);
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed(NftsCollectionDetails.routeName, arguments: {
        'collectionName': widget.nftsCollection.collectionName,
        'collectionId': widget.nftsCollection.collectionId,
        'creatorId': widget.nftsCollection.creatorId,
        'creatorRoyalty': widget.nftsCollection.creatorRoyalty,
        'ownerId': widget.nftsCollection.ownerId,
        'nftIds': widget.nftsCollection.nftIds.length.toString(),
        'standard': widget.nftsCollection.collectionStandard.toString(),
        'chain': widget.nftsCollection.chain.toString(),
        'createdAt': widget.nftsCollection.createdAt.toString(),
        'collectionStatus': widget.nftsCollection.status.toString(),
        'listingType': widget.nftsCollection.listingType.toString(),
        'image': widget.nftsCollection.image.toString(),
        'logoLink': widget.nftsCollection.logo.toString(),
        'bannerLink': widget.nftsCollection.banner.toString(),
      }),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Container(
              // color: Colors.red,
              // decoration: BoxDecoration(color: AppColors.textColorGreyShade2.withOpacity(0.25)),
              height: 27.2.h,
              child: Image.network(
                widget.nftsCollection.image!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    'assets/images/nft.png', // Path to your placeholder image
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                      child: Container(
                        height: 7.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          color: AppColors.textColorBlack.withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.sp, right: 5.sp),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container(
                              //   height: 29.sp,
                              //   width: 29.sp,
                              //   decoration: BoxDecoration(
                              //     color: Colors.red,
                              //     borderRadius: BorderRadius.circular(7),
                              //   ),
                              //   child:  ClipRRect(
                              //     borderRadius: BorderRadius.circular(7),
                              //     child: Image.asset(
                              //       'assets/images/nft.png',
                              //       // Replace with your image assets
                              //       fit: BoxFit.cover,
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(width: 3.sp,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // SizedBox(height: 2.4.h,),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 4.5.h,
                                        width: 4.5.h,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              5.sp),
                                          child: Image.network(
                                            // widget.nftsCollection.banner!,
                                            'https://images.pexels.com/photos/11881429/pexels-photo-11881429.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load',
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
                                      SizedBox(
                                        width: 5.sp,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 2.sp),
                                        // color: Colors.yellow,
                                        width: 25.w,
                                        child: Text(
                                          widget.nftsCollection.collectionName,
                                          overflow: TextOverflow.ellipsis,
                                          // 'Cube Collection'.tr(),
                                          style: TextStyle(
                                              color: AppColors.textColorWhite,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10.sp,
                                              fontFamily: 'Clash Display'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 0.7.h,
                                  ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  // Text('6000 SAR',
                                  //     style: TextStyle(
                                  //       color:
                                  //       AppColors.textColorWhite.withOpacity(0.5),
                                  //       fontWeight: FontWeight.w500,
                                  //       fontSize: 7.sp,
                                  //     )),
                                  // Spacer(),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  // Positioned(
                  //     bottom: 10,
                  //     right: 10,
                  //     child:
                  // GestureDetector(
                  //     onTap: () => setState(() {
                  //       _isFavourite = !_isFavourite;
                  //     }),
                  //     child: _isFavourite
                  //         ? Icon(
                  //       Icons.favorite,
                  //       color: AppColors.errorColor,
                  //       size: 13.sp,
                  //     )
                  //         : Icon(
                  //       Icons.favorite_border,
                  //       color: AppColors.textColorGreyShade2,
                  //       size: 13.sp,
                  //     ))
                  // ),
                ))
          ],
        ),
      ),
    );
  }
}
