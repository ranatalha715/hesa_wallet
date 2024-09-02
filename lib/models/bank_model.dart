class Bank {
  final String? bankName;
  final String? accountTitle;
  final String ibanNumber;
  final String bic;
  final String isPrimary;

  // final String beneficiaryName;

  Bank({
    this.bankName,
    required this.ibanNumber,
     this.accountTitle,
    required this.bic,
    required this.isPrimary,
    // required this.beneficiaryName,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bankName: json['bankName'],
      ibanNumber: json['accountNumber'],
      bic: json['bic'],
      isPrimary: json['isPrimary'].toString(),
      accountTitle: json['accountTitle'].toString(),
    );
  }
}

class BankName {
  // final String bankName;
  final String id;
  final String bic;
  final String bankName;

  // final String beneficiaryName;

  BankName({
    // required this.bankName,
    required this.id,
    required this.bic,
    required this.bankName,
    // required this.beneficiaryName,
  });

  factory BankName.fromJson(Map<String, dynamic> json) {
    return BankName(
      // bankName: json['beneficiaryBank'],
      id: json['_id'],
      bic: json['bic'],
      bankName: json['bankName'].toString(),
      // beneficiaryName: json['beneficiaryName'],
    );
  }
}
