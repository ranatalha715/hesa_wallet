class NftsModel {
  final String tokenName;
  final String tokenId;
  final String tokenURI;
  final String price;
  final String id;

  NftsModel(
      {required this.tokenName,
      required this.tokenId,
      required this.tokenURI,
      required this.price,
      required this.id});
}

class NftsCollectionModel {
  final String id;
  final String collectionName;
  final String collectionId;
  final String ownerId;
  final List<String> nftIds;
  final String creatorId;
  final String creatorRoyalty;

  NftsCollectionModel(
      {required this.id,
      required this.collectionName,
      required this.collectionId,
      required this.ownerId,
      required this.nftIds,
      required this.creatorId,
      required this.creatorRoyalty,
      });
}
