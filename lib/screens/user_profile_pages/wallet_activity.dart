import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/screens/connection_requests_pages/connect_dapp.dart';
import 'package:hesa_wallet/screens/user_profile_pages/transaction_summary.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:hesa_wallet/widgets/wallet_activity_widget.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/main_header.dart';

class WalletActivity extends StatefulWidget {
  const WalletActivity({Key? key}) : super(key: key);

  @override
  State<WalletActivity> createState() => _WalletActivityState();
}

class _WalletActivityState extends State<WalletActivity> {
  var _isLoading = false;
  var _isinit= true;
  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if(_isinit){
      setState(() {
        _isLoading=true;
      });
     await Future.delayed(Duration(milliseconds: 900), () {
        print('This code will be executed after 2 seconds');
      });
      setState(() {
        _isLoading=false;
      });
    }
    _isinit=false;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(title: 'Activity'.tr()),
                Expanded(
                    child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        WalletActivityWidget(
                          title: 'Neo Cube#123',
                          subTitle: 'Item sale'.tr(),
                          image: 'assets/images/nft.png',
                          time: '3h',
                          priceUp: 12000,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionSummary()),
                          ),
                        ),
                        WalletActivityWidget(
                          title: 'Neo Cube#123'.tr(),
                          subTitle: 'Collection purchase'.tr(),
                          image: 'assets/images/nft.png',
                          time: '1d',
                          // priceUp: 12000,
                          priceDown: 8000,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionSummary()),
                          ),
                        ),
                        WalletActivityWidget(
                          title: 'Neo Cube#123'.tr(),
                          subTitle: 'Creation royalty'.tr(),
                          image: 'assets/images/nft.png',
                          time: '1d',
                          priceNormal: 10000,
                          priceUp: 400,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionSummary()),
                          ),
                        ),
                        WalletActivityWidget(
                          title: 'Site Connection'.tr(),
                          subTitle: 'Connect Success'.tr(),
                          image: 'assets/images/nft.png',
                          time: '1d',
                          isPending: true,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ConnectDapp()),
                          ),
                        ),
                        WalletActivityWidget(
                          title: 'Listing'.tr(),
                          subTitle: 'Transaction request'.tr(),
                          image: 'assets/images/nft.png',
                          time: '1d',
                          isPending: true,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ConnectDapp()),
                          ),
                        ),
                        WalletActivityWidget(
                          title: 'Collection purchase'.tr(),
                          subTitle: 'Item sale'.tr(),
                          image: 'assets/images/nft.png',
                          time: '8h',
                          priceUp: 12000,
                          // priceDown: 4000,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionSummary()),
                          ),
                        ),
                        WalletActivityWidget(
                          title: 'Creation royalty'.tr(),
                          subTitle: 'Item sale'.tr(),
                          image: 'assets/images/nft.png',
                          time: '1d',
                          priceNormal: 8000,
                          priceUp: 4000,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionSummary()),
                          ),
                        ),
                        WalletActivityWidget(
                          title: 'Listing'.tr(),
                          subTitle: 'Transaction request'.tr(),
                          image: 'assets/images/nft.png',
                          time: '1d',
                          isPending: true,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ConnectDapp()),
                          ),
                        ),
                        WalletActivityWidget(
                          title: 'Collection purchase'.tr(),
                          subTitle: 'Item sale'.tr(),
                          image: 'assets/images/nft.png',
                          time: '2d',
                          priceNormal: 10000,
                          priceDown: 4000,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionSummary()),
                          ),
                        ),
                        WalletActivityWidget(
                          title: 'Creation royalty'.tr(),
                          subTitle: 'Item sale'.tr(),
                          image: 'assets/images/nft.png',
                          time: '1d',
                          priceNormal: 8000,
                          priceUp: 4000,
                          handler: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionSummary()),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
          if(_isLoading)
            LoaderBluredScreen()
        ],
      );
    });
  }
}
