class ActivityModel {
  final String transactionType;
  final String transactionAmount;
  final String tokenName;
  final String image;
  final String time;
  final String siteURL;
  final String amountType;

  ActivityModel(
      {required this.transactionType,
      required this.tokenName,
      required this.image,
      required this.transactionAmount,
      required this.time,
      required this.siteURL,
      required this.amountType});
}
