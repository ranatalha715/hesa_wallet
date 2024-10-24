class Bank {
  final String? bankName;
  final String? bankNameAr;
  final String? accountTitle;
  final String ibanNumber;
  final String bic;
  final String isPrimary;

  // final String beneficiaryName;

  Bank({
    this.bankName,
    this.bankNameAr,
    required this.ibanNumber,
     this.accountTitle,
    required this.bic,
    required this.isPrimary,
    // required this.beneficiaryName,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bankName: json['bankName'],
      bankNameAr: json['bankNameAr'],
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
  final String bankNameAr;

  // final String beneficiaryName;

  BankName({
    // required this.bankName,
    required this.id,
    required this.bic,
    required this.bankName,
    required this.bankNameAr,
    // required this.beneficiaryName,
  });

  factory BankName.fromJson(Map<String, dynamic> json) {
    return BankName(
      // bankName: json['beneficiaryBank'],
      id: json['_id'],
      bic: json['bic'],
      bankName: json['bankName'],
      bankNameAr: json['bankNameAr'],
      // beneficiaryName: json['beneficiaryName'],
    );
  }
}
