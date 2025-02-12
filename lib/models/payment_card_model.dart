class PaymentCard {
  final String bin;
  final String id;
  final String cardBrand;
  final String last4Digits;
  final String expiryMonth;
  final String expiryYear;
  // final Billing billing;

  PaymentCard({
    required this.bin,
    required this.id,
    required this.cardBrand,
    required this.last4Digits,
    required this.expiryMonth,
    required this.expiryYear,
    // required this.billing,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      bin: json['bin'],
      id: json['id'],
      cardBrand: json['cardBrand'],
      last4Digits: json['last4Digits'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      // billing: Billing.fromJson(json['billing']),
    );
  }
}

class Billing {
  final String street1;
  final String city;
  final String state;
  final String postcode;
  final String country;

  Billing({
    required this.street1,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      street1: json['street1'],
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
    );
  }
}
