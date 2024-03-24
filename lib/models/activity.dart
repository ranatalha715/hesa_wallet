class ActivityModel {
  final String transactionType;
  final String transactionAmount;
  final String tokenName;
  final String image;
  final String time;

  ActivityModel(
      {required this.transactionType , required this.tokenName, required this.image, required this.transactionAmount, required this.time});
}


