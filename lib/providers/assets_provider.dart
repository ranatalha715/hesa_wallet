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

  List<NftsModel> _assetsListed = [];
  List<NftsCollectionModel> _assetsCollectionListed = [];

  List<NftsModel> get assetsListed {
    return [..._assetsListed];
  }

  List<NftsCollectionModel> get assetsCollectionListed {
    return [..._assetsCollectionListed];
  }

  List<NftsModel> _assetsCreated = [];
  List<NftsCollectionModel> _assetsCollectionCreated = [];

  List<NftsModel> get assetsCreated {
    return [..._assetsCreated];
  }

  List<NftsCollectionModel> get assetsCollectionCreated {
    return [..._assetsCollectionCreated];
  }

  List<NftsModel> _assetsOwned = [];
  List<NftsCollectionModel> _assetsCollectionOwned = [];

  List<NftsModel> get assetsOwned {
    return [..._assetsOwned];
  }

  List<NftsCollectionModel> get assetsCollectionOwned {
    return [..._assetsCollectionOwned];
  }

  List<NftsModel> _assetsAll = [];
  List<NftsCollectionModel> _assetsCollectionAll = [];

  List<NftsModel> get assetsAll {
    return [..._assetsAll];
  }

  List<NftsCollectionModel> get assetsCollectionAll {
    return [..._assetsCollectionAll];
  }

  List<NftsModel> _nfts = [];

  List<NftsModel> get nfts {
    return [..._nfts];
  }

  // List<NftsCollectionModel> _nftsCollection = [];
  //
  // List<NftsCollectionModel> get nftsCollection {
  //   return [..._nftsCollection];
  // }

  Future<AuthResult> getListedAssets({
    required String token,
    required String walletAddress,
    required BuildContext context,
    required String ownerType,
    required String type,
    bool isEnglish = true,
  }) async {
    final url = Uri.parse(BASE_URL +
        '/user/assets/?ownerType=$ownerType&limit=10&page=1&type=$type&walletAddress=$walletAddress&filter=FOR_SALE');
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
        'accept-language': isEnglish ? 'eng' :'ar',
      },
    );
    fToast = FToast();
    fToast.init(context);
    final extractedData = json.decode(response.body)['nfts'] as List<dynamic>?;
    final extractedCollection =
        json.decode(response.body)['collections'] as List<dynamic>?;
    if (response.statusCode == 200) {
      final List<NftsModel> loadedAssets = [];
      extractedData?.forEach((prodData) {
        loadedAssets.add(NftsModel(
          tokenName: prodData['name'].toString(),
          id: prodData['id'].toString(),
          tokenURI: prodData['image'].toString(),
          price: "",
          tokenId: prodData['id'].toString(),
          ownerId: prodData['ownerId'].toString(),
          standard: prodData['standard'].toString(),
          status: prodData['status'] ?? 'N/A',
          listingType: prodData['listingType'].toString(),
          chain: prodData['chain'].toString(),
          createdAt: prodData['createdAt'].toString(),
          creatorId: prodData['creatorId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
        ));
      });
      _assetsListed = loadedAssets;
      final List<NftsCollectionModel> loadedAssetsCollection = [];
      extractedCollection?.forEach((prodData) {
        // final List<String>? nftIds = List<String>.from(prodData['nftIds']);
        loadedAssetsCollection.add(NftsCollectionModel(
          collectionName: prodData['name'].toString(),
          collectionId: prodData['id'].toString(),
          id: prodData['id'].toString(),
          ownerId: prodData['ownerId'].toString(),
          // nftIds: nftIds ?? [],
          nftIds: [],
          creatorId: prodData['creatorId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
          collectionStandard: prodData['standard'].toString(),
          status: prodData['status'] ?? 'N/A',
          listingType: prodData['listingType'].toString(),
          chain: prodData['chain'].toString(),
          createdAt: prodData['createdAt'].toString(),
          image: prodData['image'].toString(),
          logo:  prodData['metaData']['logoLink'].toString(),
          banner: prodData['metaData']['bannerLink'].toString(),
        ));
      });
      _assetsCollectionListed = loadedAssetsCollection;
      notifyListeners();
      return AuthResult.success;
    } else {
      return AuthResult.failure;
    }
  }

  Future<AuthResult> getCreatedAssets({
    required String token,
    required String walletAddress,
    required BuildContext context,
    required String ownerType,
    required String type,
    bool isEnglish=true,
  }) async {
    final url = Uri.parse(BASE_URL +
        '/user/assets/?ownerType=$ownerType&limit=10&page=1&type=$type&walletAddress=$walletAddress'
    );
    final response = await http.get(
      url,
      // body: body,
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
        'accept-language': isEnglish ? 'eng' :'ar',
      },
    );
    fToast = FToast();
    fToast.init(context);
    print('created data' + response.body);
    final extractedData = json.decode(response.body)['nfts'] as List<dynamic>?;
    final extractedCollection =
    json.decode(response.body)['collections'] as List<dynamic>?;
    if (response.statusCode == 200) {
      final List<NftsModel> loadedAssets = [];
      extractedData?.forEach((prodData) {
        loadedAssets.add(NftsModel(
          tokenName: prodData['name'].toString(),
          id: prodData['id'].toString(),
          tokenURI: prodData['image'].toString(),
          price: "",
          tokenId: prodData['id'].toString(),
          ownerId: prodData['ownerId'].toString(),
          standard: prodData['standard'].toString(),
          status: prodData['status'] ?? 'N/A',
          listingType: prodData['listingType'].toString(),
          chain: prodData['chain'].toString(),
          createdAt: prodData['createdAt'].toString(),
          creatorId: prodData['creatorId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
        ));
      });
      _assetsCreated = loadedAssets;
      final List<NftsCollectionModel> loadedAssetsCollection = [];
      extractedCollection?.forEach((prodData) {
        loadedAssetsCollection.add(NftsCollectionModel(
          collectionName: prodData['name'].toString(),
          collectionId: prodData['id'].toString(),
          id: prodData['id'].toString(),
          ownerId: prodData['ownerId'].toString(),
          // nftIds: prodData['nftIds'] as List<String>,
          nftIds: [],
          creatorId: prodData['creatorId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
          collectionStandard: prodData['standard'].toString(),
          status: prodData['status'] ?? 'N/A',
          listingType: prodData['listingType'].toString(),
          chain: prodData['chain'].toString(),
          createdAt: prodData['createdAt'].toString(),
          image: prodData['image'].toString(),
          banner: prodData['metaData']['logoLink'].toString(),
        ));
      });
      _assetsCollectionCreated = loadedAssetsCollection;
      notifyListeners();
      return AuthResult.success;
    } else {
      return AuthResult.failure;
    }
  }

  Future<AuthResult> getOwnedAssets({
    required String token,
    required String walletAddress,
    required BuildContext context,
    required String ownerType,
    required String type,
    bool isEnglish=true,
  }) async {
    final url = Uri.parse(BASE_URL +
        '/user/assets/?ownerType=$ownerType&limit=10&page=1&type=$type&walletAddress=$walletAddress');
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
        'accept-language': isEnglish ? 'eng' :'ar',
      },
    );
    fToast = FToast();
    fToast.init(context);
    final extractedData = json.decode(response.body)['nfts'] as List<dynamic>?;
    final extractedCollection =
    json.decode(response.body)['collections'] as List<dynamic>?;
    if (response.statusCode == 200) {
      final List<NftsModel> loadedAssets = [];
      extractedData?.forEach((prodData) {
        loadedAssets.add(NftsModel(
          tokenName: prodData['name'].toString(),
          id: prodData['id'].toString(),
          tokenURI: prodData['image'].toString(),
          price: "",
          tokenId: prodData['id'].toString(),
          ownerId: prodData['ownerId'].toString(),
          standard: prodData['standard'].toString(),
          status: prodData['status'] ?? 'N/A',
          listingType: prodData['listingType'].toString(),
          chain: prodData['chain'].toString(),
          createdAt: prodData['createdAt'].toString(),
          creatorId: prodData['creatorId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
          isListable: prodData['isListable'].toString(),
        ));
      });
      _assetsOwned = loadedAssets;
      final List<NftsCollectionModel> loadedAssetsCollection = [];
      extractedCollection?.forEach((prodData) {
        loadedAssetsCollection.add(NftsCollectionModel(
          collectionName: prodData['name'].toString(),
          collectionId: prodData['id'].toString(),
          id: prodData['id'].toString(),
          ownerId: prodData['ownerId'].toString(),
          // nftIds: prodData['nftIds'] as List<String>,
          nftIds: [],
          creatorId: prodData['creatorId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
          collectionStandard: prodData['standard'].toString(),
          status: prodData['status'] ?? 'N/A',
          listingType: prodData['listingType'].toString(),
          chain: prodData['chain'].toString(),
          createdAt: prodData['createdAt'].toString(),
          image: prodData['image'].toString(),
          banner: prodData['metaData']['logoLink'].toString(),
        ));
      });
      _assetsCollectionOwned = loadedAssetsCollection;
      notifyListeners();
      return AuthResult.success;
    } else {
      return AuthResult.failure;
    }
  }

  Future<AuthResult> getAllAssets({
    required String token,
    required String walletAddress,
    required BuildContext context,
    required String ownerType,
    required String type,
    bool isEnglish=true,
  }) async {
    final url = Uri.parse(BASE_URL +
        '/user/assets/?ownerType=$ownerType&limit=10&page=1&type=$type&walletAddress=$walletAddress');
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
        'accept-language': isEnglish ? 'eng' :'ar',
      },
    );
    fToast = FToast();
    fToast.init(context);
    print('all response');
    print(json.decode(response.body));
    final extractedData = json.decode(response.body)['nfts'] as List<dynamic>?;
    final extractedCollection =
    json.decode(response.body)['collections'] as List<dynamic>?;
    if (response.statusCode == 200) {
      final List<NftsModel> loadedAssets = [];
      print('All Owned Created');
      print(extractedData);
      print('Collection');
      print(extractedCollection);
      extractedData?.forEach((prodData) {
        loadedAssets.add(NftsModel(
          tokenName: prodData['name'].toString(),
          id: prodData['id'].toString(),
          tokenURI: prodData['image'].toString(),
          price: "",
          tokenId: prodData['id'].toString(),
          ownerId: prodData['ownerId'].toString(),
          standard: prodData['standard'].toString(),
          status: prodData['status'] ?? 'N/A',
          listingType: prodData['listingType'].toString(),
          chain: prodData['chain'].toString(),
          createdAt: prodData['createdAt'].toString(),
          creatorId: prodData['creatorId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
          isListable: prodData['isListable'].toString(),
        ));
      });
      _assetsAll = loadedAssets;
      final List<NftsCollectionModel> loadedAssetsCollection = [];
      extractedCollection?.forEach((prodData) {
        loadedAssetsCollection.add(NftsCollectionModel(
          collectionName: prodData['name'].toString(),
          collectionId: prodData['id'].toString(),
          id: prodData['id'].toString(),
          ownerId: prodData['ownerId'].toString(),
          // nftIds: prodData['nftIds'] as List<String>,
          nftIds: [],
          creatorId: prodData['creatorId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
          collectionStandard: prodData['standard'].toString(),
          status: prodData['status'] ?? 'N/A',
          listingType: prodData['listingType'].toString(),
          chain: prodData['chain'].toString(),
          createdAt: prodData['createdAt'].toString(),
          image: prodData['image'].toString(),
          banner: prodData['metaData']['logoLink'].toString(),
        ));
      });
      _assetsCollectionAll = loadedAssetsCollection;
      notifyListeners();
      return AuthResult.success;
    } else {
      return AuthResult.failure;
    }
  }


  var tokenId;
  var tokenName;
  var ownerName;
  var ownerAddress;
  var creatorName;
  var creatorAddress;
  var createdAt;
  var creatorRoyalty;
  var standard;
  var status;
  var chain;
  var isListable;
  var burnable;
  var image;
  var logoImage;
  var listingType;
  var collectionItems;
  var collectionId;
  var collectionName;
  var numberOfEdtions;

  Future<AuthResult> getNftCollectionDetails({
    required String token,
    required String type,
    required String id,
    bool isEnglish = true,
  }) async {
    final url = Uri.parse(BASE_URL +
        '/user/assets/$type/$id');

    final response = await http.get(
      url,
      // body: body,
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
        'accept-language': isEnglish ? 'eng' :'ar',
      },
    );

    print('nft details response');
    print(json.decode(response.body));
    final extractedData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (response.statusCode == 200) {
        tokenId = extractedData['id'] ?? 'Unknown';
        tokenName = extractedData['name'] ?? 'Unknown';
        image = extractedData['image'] ?? 'No Image';
        ownerName = extractedData['owner']?['userName'] ?? 'Unknown';
        ownerAddress = extractedData['owner']?['id'] ?? 'Unknown';
        creatorName = extractedData['creator']?['userName'] ?? 'Unknown';
        creatorAddress = extractedData['creator']?['id'] ?? 'Unknown';
        createdAt = extractedData['createdAt'] ?? 'Unknown Date';
        isListable = extractedData['isListable']?.toString() ?? 'false';
        burnable = extractedData['burnable']?.toString() ?? 'false';
        creatorRoyalty = extractedData['creatorRoyalty']?.toString() ?? '0';
        standard = extractedData['standard'] ?? 'Unknown';
        status = extractedData['status'] ?? 'Unknown';
        chain = extractedData['chain'] ?? 'Unknown';
        collectionId = extractedData['collectionId'] ?? 'Unknown';
        collectionName = extractedData['collectionName'] ?? 'Unknown';
        numberOfEdtions = extractedData['numberOfEdtions'] ?? 'Unknown';
        listingType = extractedData['listingType']?.toString() ?? '0';
        return AuthResult.success;
      } else {
        return AuthResult.failure;
      }

    } else {
      return AuthResult.failure;
    }
  }

  Future<AuthResult> getCollectionDetails({
    required String token,
    required String type,
    required String id,
    bool isEnglish = true,
  }) async {
    final url = Uri.parse(BASE_URL +
        '/user/assets/$type/$id');

    final response = await http.get(
      url,
      // body: body,
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
        'accept-language': isEnglish ? 'eng' :'ar',
      },
    );

    print('collection details response');
    print(json.decode(response.body));
    final extractedData = json.decode(response.body);

    if (response.statusCode == 200) {
      tokenId=extractedData['id'];
      tokenName=extractedData['name'];
      image=extractedData['image'];
      logoImage=extractedData['logoImage'];
      ownerName=extractedData['owner']['userName'];
      ownerAddress=extractedData['owner']['id'];
      creatorName=extractedData['creator']['userName'];
      creatorAddress=extractedData['creator']['id'];
      createdAt=extractedData['createdAt'];
      isListable=extractedData['isListable'].toString();
      burnable=extractedData['isBurn'].toString();
      creatorRoyalty=extractedData['creatorRoyalty'].toString();
      standard=extractedData['collectionStandard'];
      status=extractedData['status'];
      chain=extractedData['chain'];
      collectionItems=extractedData['collectionItems'].toString();
      listingType=extractedData['listingType'].toString();
      return AuthResult.success;
    } else {
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
