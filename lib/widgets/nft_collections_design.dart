import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';
import '../models/assets_model.dart';
import '../models/nfts_model.dart';
import '../screens/user_profile_pages/nfts_collection_details.dart';

class NftsCollectionDesign extends StatefulWidget {
  const NftsCollectionDesign({Key? key , required this.nftsCollection}) : super(key: key);

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
      onTap: ()=>  Navigator.of(context).pushNamed(NftsCollectionDetails.routeName,
          arguments: {
            'collectionName': widget.nftsCollection.collectionName,
            'collectionId': widget.nftsCollection.collectionId ,
            'creatorId': widget.nftsCollection.creatorId ,
            'creatorRoyalty': widget.nftsCollection.creatorRoyalty ,
            'ownerId': widget.nftsCollection.ownerId,
            'nftsIdsLength': widget.nftsCollection.nftIds.length.toString(),
            // 'id': _identificationnumberController.text,
            // 'idType': _selectedIDType,

          }
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/nft.png',
              // Replace with your image assets
              fit: BoxFit.cover,
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
                  child:
                  Padding(
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
                        SizedBox(width: 4.sp,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 1.4.h,),
                            Container(
                              // color: Colors.red,
                              width: 35.w,
                              child: Text(
                                widget.nftsCollection.collectionName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                // 'Cube Collection'.tr(),
                                style: TextStyle(
                                    color: AppColors.textColorWhite,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 8.8.sp),
                              ),
                            ),
                            SizedBox(
                              height: 0.7.h,
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     // Text('6000 SAR',
                            //     //     style: TextStyle(
                            //     //       color:
                            //     //       AppColors.textColorWhite.withOpacity(0.5),
                            //     //       fontWeight: FontWeight.w500,
                            //     //       fontSize: 7.sp,
                            //     //     )),
                            //     // Spacer(),
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
          ],
        ),
      ),
    );
  }
}