import 'package:flutter/cupertino.dart';
import 'package:hesa_wallet/providers/payment_fees.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';

class PaymentFeesWidget extends StatefulWidget {
  final String params;

  PaymentFeesWidget({required this.params});

  @override
  State<PaymentFeesWidget> createState() => _PaymentFeesWidgetState();
}

class _PaymentFeesWidgetState extends State<PaymentFeesWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<PaymentFees>(context, listen: false)
        .paymentFeesForMintNFT(params: widget.params);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.h,
      width: double.infinity,
      color: AppColors.errorColor,
    );
  }
}
