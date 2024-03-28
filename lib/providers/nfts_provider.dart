import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

import '../constants/configs.dart';
import '../models/nfts_model.dart';

class NftsProvider with ChangeNotifier {
  List<NftsModel> _walletNfts = [];
  List<NftsCollectionModel> _walletCollection = [];


  List<NftsModel> get walletNfts {
    return [..._walletNfts];
  }

  List<NftsCollectionModel> get walletCollection {
    return [..._walletCollection];
  }
  List<NftsCollectionModel> _nftsCollectionAll = [];
  List<NftsCollectionModel> get nftsCollectionAll {
    return [..._nftsCollectionAll];
  }
  List<NftsModel> _nftsOwned = [];

  List<NftsModel> get nftsOwned {
    return [..._nftsOwned];
  }

  List<NftsModel> _nftsCreated = [];

  List<NftsModel> get nftsCreated {
    return [..._nftsCreated];
  }
  List<NftsCollectionModel> _nftsCollectionCreated = [];
  List<NftsCollectionModel> get nftsCollectionCreated {
    return [..._nftsCollectionCreated];
  }

  List<NftsCollectionModel> _nftsCollectionOwnedByUser = [];
  List<NftsCollectionModel> get nftsCollectionOwnedByUser {
    return [..._nftsCollectionOwnedByUser];
  }


  Future<AuthResult> getWalletNftsAndCollection({
    required String token,
    required String walletAddress,
    required BuildContext context,
  }) async {
    final url = Uri.parse(
        BASE_URL + '/user/getWalletInformation?walletID=$walletAddress');

    final response = await http.get(
      url,
      headers: {
        // "Content-type": "application/json",
        "Accept": "application/json",
        // 'Authorization': 'Bearer $token',
        // 'Authorization': '6f382aafe37d128ceaabd2d3238aefb46460176189f5af448209eef88a812d66aa232001',
      },
    );
    final dynamic responseBody = json.decode(response.body);

    if (responseBody.containsKey('message')) {
      var test = responseBody['message'] as String?;
      print("test" + test!);
    } else {
      print('The key "message" does not exist in the response body.');
    }

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body)['data'];

      if (jsonData != null && jsonData.containsKey('NFT')) {
        final List<dynamic> extractedData = jsonData['NFT'] as List<dynamic>;
        print("extracted data" + extractedData.toString());
        final List<NftsModel> loadedNfts = extractedData.map((prodData) {
          return NftsModel(
            tokenName: prodData['TokenName'].toString(),
            tokenId: prodData['tokenId'].toString(),
            tokenURI: prodData['tokenURI'].toString(),
            price: prodData['tokenPrice'].toString(),
            id: prodData['id'].toString(),
          );
        }).toList();

        _walletNfts = loadedNfts;
        notifyListeners();
        return AuthResult.success;
      } else {
        print("Key 'NFT' not found in response data");
        return AuthResult.failure;
      }
    } else {
      print("Failed to fetch wallet information: ${response.statusCode}");
      return AuthResult.failure;
    }
  }

  Future<AuthResult> getAllNftsCollection({
    required String token,
    required String walletAddress,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/collection/');
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

    final result = json.decode(response.body);
    print('get all nft data');
    print(result);
    final extractedData = json.decode(response.body) as List<dynamic>?;


    if (response.statusCode == 200) {

      final List<NftsCollectionModel> loadedNftsCollection = [];
      extractedData?.forEach((prodData) {
        List<dynamic> nftIdsDynamic = prodData['nftIds'] as List<dynamic>;
        List<String> nftIds = nftIdsDynamic.map((id) => id.toString()).toList();
        // final metaData = prodData['metaData'] as Map<String, dynamic>;
        loadedNftsCollection.add(NftsCollectionModel(
          id: prodData['id'].toString(),
          collectionName: prodData['collectionName'].toString(),
          collectionId: prodData['collectionId'].toString(),
          creatorId: prodData['creatorId'].toString(),
          ownerId: prodData['ownerId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
          nftIds: nftIds,
            collectionStandard: prodData['standard'].toString(),
            chain: prodData['chain'].toString(),
            // logo: metaData['logoLink'].toString(),
            // banner: metaData['bannerLink'].toString(),
          createdAt: prodData['createdAt'].toString(),
          status: prodData['collectionStatus'].toString(),

        ));
      });
      _nftsCollectionAll = loadedNftsCollection;
      print(response.body);
      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Nfts Collection not found: ${response.body}");
      // _showToast('Assets not found');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> getAllNfts({
    required String token,
    required String walletAddress,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/nft/ownedByUser?address=$walletAddress');
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
    // fToast = FToast();
    // fToast.init(context);
    final extractedData = json.decode(response.body) as List<dynamic>?;

    if (response.statusCode == 200) {
      print("nftowned");
      print(extractedData);

      final List<NftsModel> loadedNfts = [];
      extractedData?.forEach((prodData) {
        loadedNfts.add(NftsModel(
          tokenName: prodData['TokenName'].toString(),
          tokenId: prodData['tokenId'].toString(),
          tokenURI: prodData['tokenURI'].toString(),
          price: prodData['tokenPrice'].toString(),
          id: prodData['id'].toString(),
        ));
      });
      _nftsOwned = loadedNfts;
      print(response.body);
      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Nfts not found: ${response.body}");
      // _showToast('Assets not found');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> nftsOwnedByUser({
    required String token,
    required String walletAddress,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/nft/ownedByUser?address=$walletAddress');
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
    // fToast = FToast();
    // fToast.init(context);
    final extractedData = json.decode(response.body) as List<dynamic>?;

    if (response.statusCode == 200) {
      print("nftowned");
      print(extractedData);

      final List<NftsModel> loadedNfts = [];
      extractedData?.forEach((prodData) {
        loadedNfts.add(NftsModel(
          tokenName: prodData['TokenName'].toString(),
          tokenId: prodData['tokenId'].toString(),
          tokenURI: prodData['tokenURI'].toString(),
          price: prodData['tokenPrice'].toString(),
          id: prodData['id'].toString(),
        ));
      });
      _nftsOwned = loadedNfts;
      print(response.body);
      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Nfts not found: ${response.body}");
      // _showToast('Assets not found');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> getNftsCollectionOwnedByUser({
    required String token,
    required String walletAddress,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/collection/ownedByUser?address=$walletAddress');
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
    final extractedData = json.decode(response.body) as List<dynamic>;

    if (response.statusCode == 200) {
      print(extractedData);

      final List<NftsCollectionModel> loadedNftsCollection = [];
      extractedData?.forEach((prodData) {
        List<dynamic> nftIdsDynamic = prodData['nftIds'] as List<dynamic>;
        List<String> nftIds = nftIdsDynamic.map((id) => id.toString()).toList();

        loadedNftsCollection.add(NftsCollectionModel(
          id: prodData['id'].toString(),
          collectionName: prodData['collectionName'].toString(),
          collectionId: prodData['collectionId'].toString(),
          creatorId: prodData['creatorId'].toString(),
          ownerId: prodData['ownerId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
          nftIds: nftIds,
          collectionStandard: prodData['standard'].toString(),
          chain: prodData['chain'].toString(),
          // logo: metaData['logoLink'].toString(),
          // banner: metaData['bannerLink'].toString(),
          createdAt: prodData['createdAt'].toString(),
          status: prodData['collectionStatus'].toString(),
        ));
      });
      _nftsCollectionOwnedByUser = loadedNftsCollection;
      print(response.body);
      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Nfts Collection not found: ${response.body}");
      // _showToast('Assets not found');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> nftsCreatedByUser({
    required String token,
    required String walletAddress,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/nft/ownedByUser?address=$walletAddress');
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
    // fToast = FToast();
    // fToast.init(context);
    final extractedData = json.decode(response.body) as List<dynamic>?;

    if (response.statusCode == 200) {
      print(extractedData);

      final List<NftsModel> loadedNfts = [];
      extractedData?.forEach((prodData) {
        loadedNfts.add(NftsModel(
          tokenName: prodData['TokenName'].toString(),
          tokenId: prodData['tokenId'].toString(),
          tokenURI: prodData['tokenURI'].toString(),
          price: prodData['tokenPrice'].toString(),
          id: prodData['id'].toString(),
        ));
      });
      _nftsCreated = loadedNfts;
      print(response.body);
      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Nfts not found: ${response.body}");
      // _showToast('Assets not found');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> getNftsCollectionCreatedByUser({
    required String token,
    required String walletAddress,
    required BuildContext context,
  }) async {
    final url = Uri.parse(BASE_URL + '/collection/createdByUser?address=$walletAddress');
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
    final extractedData = json.decode(response.body) as List<dynamic>;

    if (response.statusCode == 200) {
      print(extractedData);

      final List<NftsCollectionModel> loadedNftsCollection = [];
      extractedData?.forEach((prodData) {
        List<dynamic> nftIdsDynamic = prodData['nftIds'] as List<dynamic>;
        List<String> nftIds = nftIdsDynamic.map((id) => id.toString()).toList();

        loadedNftsCollection.add(NftsCollectionModel(
          id: prodData['id'].toString(),
          collectionName: prodData['collectionName'].toString(),
          collectionId: prodData['collectionId'].toString(),
          creatorId: prodData['creatorId'].toString(),
          ownerId: prodData['ownerId'].toString(),
          creatorRoyalty: prodData['creatorRoyalty'].toString(),
          nftIds: nftIds,
          collectionStandard: prodData['standard'].toString(),
          chain: prodData['chain'].toString(),
          // logo: metaData['logoLink'].toString(),
          // banner: metaData['bannerLink'].toString(),
          createdAt: prodData['createdAt'].toString(),
          status: prodData['collectionStatus'].toString(),
        ));
      });
      _nftsCollectionCreated = loadedNftsCollection;
      print(response.body);
      notifyListeners();
      return AuthResult.success;
    } else {
      // Show an error message or handle the response as needed
      print("Nfts Collection not found: ${response.body}");
      // _showToast('Assets not found');
      return AuthResult.failure;
    }
  }

}
