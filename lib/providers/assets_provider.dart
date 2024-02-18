import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/models/nfts_model.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import '../constants/colors.dart';
import '../constants/configs.dart';
import '../models/assets_model.dart';

class AssetsProvider with ChangeNotifier {
  late FToast fToast;

  List<AssetsNftsModel> _assets = [];
  List<AssetsCollectionModel> _assetsCollection = [];

  List<AssetsNftsModel> get assets {
    return [..._assets];
  }

  // List<AssetsCollectionModel> get assetsCollection {
  //   return [..._assetsCollection];
  // }
  //
  // List<NftsModel> _nfts = [];
  //
  // List<NftsModel> get nfts {
  //   return [..._nfts];
  // }

  // List<NftsCollectionModel> _nftsCollection = [];
  //
  // List<NftsCollectionModel> get nftsCollection {
  //   return [..._nftsCollection];
  // }

  Future<AuthResult> getAssets({
    required String token,
    required String walletAddress,
    required BuildContext context,
  }) async {
    final url =
        Uri.parse(BASE_URL + '/user/getAssets?walletAddress=$walletAddress');
    // final body = {
    //   "walletAddress": walletAddress,
    // };

    final response = await http.get(
      url,
      // body: body,
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    fToast = FToast();
    fToast.init(context);
    final extractedData =
        json.decode(response.body)['data']['NFT'] as List<dynamic>?;
    final extractedCollection =
        json.decode(response.body)['data']['collection'] as List<dynamic>?;
    if (response.statusCode == 200) {
      print(extractedData);

      final List<AssetsNftsModel> loadedAssets = [];
      extractedData?.forEach((prodData) {
        loadedAssets.add(AssetsNftsModel(
          tokenName: prodData['TokenName'].toString(),
          tokenId: prodData['tokenId'].toString(),
          tokenURI: prodData['tokenURI'].toString(),
          price: prodData['tokenPrice'].toString(),
        ));
      });
      _assets = loadedAssets;
      final List<AssetsCollectionModel> loadedAssetsCollection = [];
      extractedCollection?.forEach((prodData) {
        loadedAssetsCollection.add(AssetsCollectionModel(
          collectionName: prodData['collectionName'].toString(),
          collectionId: prodData['collectionId'].toString(),
        ));
      });
      _assetsCollection = loadedAssetsCollection;
      // _showToast('Getting assets!');
      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Assets not found: ${response.body}");
      // _showToast('Assets not found');
      return AuthResult.failure;
    }
  }




  _showToast(String message, {int duration = 1000}) {
    Widget toast = Container(
      height: 60,
      // width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: AppColors.textColorWhite.withOpacity(0.5),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              color: Colors.transparent,
              child: Text(
                message,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                // .toUpperCase(),
                style: TextStyle(
                        color: AppColors.backgroundColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold)
                    .apply(fontWeightDelta: -2),
              ),
            ),
          ),
          // Spacer(),
        ],
      ),
    );

    // Custom Toast Position
    fToast.showToast(
        child: toast,
        toastDuration: Duration(milliseconds: duration),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: Center(child: child),
            top: 43.0,
            left: 20,
            right: 20,
          );
        });
  }
}
