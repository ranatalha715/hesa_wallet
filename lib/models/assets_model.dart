class AssetsNftsModel {
  final String tokenName;
  final String tokenId;
  final String tokenURI;
  final String price;

  AssetsNftsModel(
      {required this.tokenName, required this.tokenId, required this.tokenURI, required this.price});
}

class AssetsCollectionModel {
  final String collectionName;
  final String collectionId;

  AssetsCollectionModel({
    required this.collectionName , required this.collectionId
});
}

