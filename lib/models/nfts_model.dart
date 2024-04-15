class NftsModel {
  final String tokenName;
  final String tokenId;
  final String tokenURI;
  final String price;
  final String id;
  final String? ownerId;
  final String? standard;
  final String? status;
  final String? listingType;
  final String? createdAt;
  final String? creatorId;
  final String? creatorRoyalty;
  final String? chain;
  final String? isListable;

  NftsModel(
      {required this.tokenName,
      required this.tokenId,
      required this.tokenURI,
      required this.price,
      required this.id,
      this.ownerId,
        this.standard,
        this.status,
        this.listingType,
        this.createdAt,
        this.creatorId,
        this.creatorRoyalty,
        this.chain,
        this.isListable,
      });
}

class NftsCollectionModel {
  final String id;
  final String collectionName;
  final String collectionId;
  final String ownerId;
  final List<String> nftIds;
  final String creatorId;
  final String creatorRoyalty;
  final String? collectionStandard;
  final String? chain;
  final String? logo;
  final String? banner;
  final String? createdAt;
  final String? status;
  final String? listingType;
  final String? image;

  NftsCollectionModel(
      {required this.id,
      required this.collectionName,
      required this.collectionId,
      required this.ownerId,
      required this.nftIds,
      required this.creatorId,
      required this.creatorRoyalty,
        this.collectionStandard,
        this.chain,
        this.logo,
        this.banner,
        this.createdAt,
        this.status,
        this.listingType,
        this.image,
      });
}
