import 'package:easy_localization/easy_localization.dart';

String replaceMiddleWithDots(String input) {
  if (input.length <= 30) {
    return input;
  }

  final int middleIndex = input.length ~/ 2;
  final int startIndex = middleIndex - 15;
  final int endIndex = middleIndex + 15;
  return input.substring(0, startIndex) + '...' + input.substring(endIndex);
}

String replaceMiddleWithDots2(String input) {
  if (input.length <= 32) {
    return input;
  }
  final int numCharsToShow = 7;
  final String start = input.substring(0, numCharsToShow);
  final String end = input.substring(input.length - numCharsToShow);
  return "$start...$end";
}

String addSpacesToText(String input) {
  final chunkSize = 4;
  final chunks = <String>[];

  for (int i = 0; i < input.length; i += chunkSize) {
    final end =
    (i + chunkSize <= input.length) ? i + chunkSize : input.length;
    chunks.add(input.substring(i, end));
  }

  return chunks.join(' ');
}

String replaceMiddleWithDotsTokenId(String input) {
  if (input.length <= 30) {
    return input;
  }

  final int middleIndex = input.length ~/ 2; // Find the middle index
  final int startIndex = middleIndex - 12; // Calculate the start index
  final int endIndex = middleIndex + 9; // Calculate the end index

  // Split the input string into three parts and join them with '...'
  final String result =
      input.substring(0, startIndex) + '...' + input.substring(endIndex);

  return result;
}

String formatCurrency(String? numberString) {
  if (numberString == null || numberString.isEmpty) {
    return "0";
  }
  try {
    num number = num.parse(numberString);
    final formatter = NumberFormat("#,##0.##", "en_US");
    return formatter.format(number);
  } catch (e) {
    return "Invalid Number";
  }
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}

String tnxLabelingWithPayload(String operation) {
  switch (operation) {
    case 'MintNFT':
    case 'MintNFT':
      return 'NFT Minting';

    case 'MintCollection':
      return 'NFT Collection Minting';

    case 'listNFT':
      return 'NFT Listing';

    case 'listAuctionNFT':
    case 'listAuctionCollection':
      return 'Auction Listing';

    case 'listCollection':
      return 'Listing for sale';

    case 'makeOfferNFT':
    case 'makeOfferCollection':
      return 'Offer Placement';

    case 'purchaseNFT':
    case 'purchaseCollection':
      return 'Purchase';

    case 'burnNFT':
    case 'burnCollection':
      return 'Burning';

    case 'CancelNFTOfferMade':
    case 'CancelCollectionOfferMade':
      return 'Offer Cancellation';

    case 'makeNFTCounterOffer':
      return 'Counter Offer Placement';

    case 'makeCollectionCounterOffer':
      return 'Counter Offer Placement';

    case 'AcceptCollectionOffer':
    case 'AcceptNFTOffer':
    case 'AcceptNFTOfferReceived':
      return 'Offer Acceptance';

    case 'rejectCollectionOfferReceived':
    case 'rejectNFTOfferReceived':
      return 'Offer Rejection';

    case 'CancelListing':
    case 'CancelCollectionAuctionListing':
    case 'CancelAuctionListing':
    case 'CancelCollectionAuctionListing':
    case 'CancelCollectionListing':
      return 'Listing Cancellation';

    case 'acceptCollectionCounterOffer':
    case 'acceptNFTCounterOffer':
      return 'Counter Offer Acceptance';

    case 'rejectCollectionCounterOffer':
    case 'rejectNFTCounterOffer':
      return 'Counter Offer Rejection';

    default:
      return 'Unknown Operation';
  }
}

String tnxLabelingWithApi(String transactionType) {
  switch (transactionType) {
    case 'Mint NFT':
    case 'Mint NFT':
      return 'NFT Minting';

    case 'Mint Collection':
      return 'NFT Collection Minting';

    case 'List NFT':
      return 'NFT Listing';

    case 'List NFT For Auction':
    case 'List Collection For Auction':
      return 'Auction Listing';

    case 'List Collection':
      return 'Listing for sale';

    case 'Make Offer':
    case 'Make Collection Offer':
      return 'Offer Placement';

    case 'Purchase NFT':
    case 'Purchase Collection':
      return 'Purchase';

    case 'Burn NFT':
    case 'Burn Collection':
      return 'Burning';

    case 'Cancel Offer':
    case 'Cancel Collection Offer':
      return 'Offer Cancellation';

    case 'Make Counter Offer':
    case 'Make Collection Counter Offer':
      return 'Counter Offer Placement';

    case 'Accept Collection Offer':
    case 'Accept Offer':
      return 'Offer Acceptance';

    case 'Reject Collection Offer':
    case 'Reject Offer':
      return 'Offer Rejection';

    case 'Cancel Listing':
    case 'Cancel Collection Listing':
    case 'Cancel Auction Listing':
    case 'Cancel Collection Auction Listing':
      return 'Listing Cancellation';

    case 'Accept Collection Counter Offer':
    case 'Accept Counter Offer':
      return 'Counter Offer Acceptance';

    case 'Reject Collection Counter Offer':
    case 'Reject Counter Offer':
      return 'Counter Offer Rejection';

    case 'Item Sold':
      return 'Item Sold';

    case 'NFT Sold':
      return 'NFT Sold';

    default:
      return 'Unknown Operation';
  }
}

String calculateTimeDifference(String createdAtStr) {
  DateTime createdAt = DateTime.parse(createdAtStr).toUtc();
  DateTime now = DateTime.now().toUtc();
  Duration difference = now.difference(createdAt);
  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}s';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h';
  } else if (difference.inDays < 30) {
    return '${difference.inDays}d';
  } else if (difference.inDays < 365) {
    int months = (difference.inDays / 30).floor();
    return '$months m';
  } else {
    int years = (difference.inDays / 365).floor();
    return '$years y';
  }
}

String replaceMiddleWithDotsWA(String input) {
  if (input.length <= 30) {
    return input;
  }
  final int middleIndex = input.length ~/ 2;
  final int startIndex = middleIndex - 16;
  final int endIndex = middleIndex + 16;
  final String result =
      input.substring(0, startIndex) + '...' + input.substring(endIndex);
  return result;
}

String replaceMiddleWithDotstxId(String input) {
  if (input.length <= 30) {
    return input;
  }

  final int middleIndex = input.length ~/ 2; // Find the middle index
  final int startIndex = middleIndex - 23; // Calculate the start index
  final int endIndex = middleIndex + 23; // Calculate the end index

  // Split the input string into three parts and join them with '...'
  final String result =
      input.substring(0, startIndex) + '....' + input.substring(endIndex);

  return result;
}

String replaceMiddleWithDotstxIdCounter(String input) {
  if (input.length <= 30) {
    return input;
  }

  final int middleIndex = input.length ~/ 2; // Find the middle index
  final int startIndex = middleIndex - 15; // Calculate the start index
  final int endIndex = middleIndex + 15; // Calculate the end index

  // Split the input string into three parts and join them with '...'
  final String result =
      input.substring(0, startIndex) + '....' + input.substring(endIndex);

  return result;
}

