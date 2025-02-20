import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/constants/string_utils.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/screens/connection_requests_pages/connect_dapp.dart';
import 'package:hesa_wallet/screens/user_profile_pages/transaction_summary.dart';
import 'package:hesa_wallet/widgets/wallet_activity_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/main_header.dart';

class WalletActivity extends StatefulWidget {
  const WalletActivity({Key? key}) : super(key: key);

  @override
  State<WalletActivity> createState() => _WalletActivityState();
}

class _WalletActivityState extends State<WalletActivity> {
  var _isLoading = false;
  var _isinit = true;
  var accessToken;
  var siteUrl;
  var logoFromNeo;
  var bytes;
  var connectionTime;
  var disconnectionTime;
  final scrollController=ScrollController();
  bool hasMore=true;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }
  List<Map<String, dynamic>> sortedActivities=[];

  Future<void> refresh() async {
    setState(() {
      _isLoading = true; // Show loader
      hasMore = true;
      currentPage = 0;
      sortedActivities.clear();
    });

    await fetch(); // Ensure fetch is awaited properly

    setState(() {
      _isLoading = false; // Hide loader after fetching
    });
  }



  @override
  Future<void> didChangeDependencies() async {
    if (_isinit) {
      setState(() {
        _isLoading = true;
      });
      await getAccessToken();
      await Provider.of<UserProvider>(context, listen: false)
          .getUserDetails(token: accessToken, context: context);
      Locale currentLocale = context.locale;
      bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
      await fetch();
      final prefs = await SharedPreferences.getInstance();
      siteUrl = prefs.getString("siteUrl") ??
          "";
      logoFromNeo = prefs.getString("logoFromNeo") ?? "";
      if (logoFromNeo != null && logoFromNeo.isNotEmpty) {
        bytes = base64Decode(logoFromNeo);
      }
      connectionTime = prefs.getString("connectionTime") ?? "";
      disconnectionTime = prefs.getString("disconnectionTime") ?? "";
      setState(() {
        _isLoading = false;
      });
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future fetch() async{
    const limit=10;
    await Provider.of<TransactionProvider>(context, listen: false)
        .getWalletActivities(accessToken: accessToken, context: context, isEnglish:true,
      limit: limit,
      page: currentPage,
    );
      setState(() {
        currentPage++;
      });
      if(Provider.of<TransactionProvider>(context, listen: false).activities.length < limit){
        hasMore=false;
      }
  }

  @override
  void initState() {
    Provider.of<TransactionProvider>(context, listen: false).clearActivities();
    fetch();
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent==scrollController.offset){
        fetch();
      }
    });
    super.initState();

    Provider.of<TransactionProvider>(context, listen: false).resetRedDotState();
    Provider.of<TransactionProvider>(context, listen: false).confirmedRedDot =
    false;
    callRedDotLogic();
  }

  Future<List<Map<String, dynamic>>>
  _getSortedActivitiesWithSiteConnection() async {
     sortedActivities = [];
    if (connectionTime != "" && siteUrl != "") {
      sortedActivities.add({
        'type': 'site_connection',
        'siteURL': siteUrl,
        'time': connectionTime,
        'bytes': bytes,
      });
    }
    if (disconnectionTime != "") {
      sortedActivities.add({
        'type': 'site_disconnection',
        'siteURL': siteUrl,
        'time': disconnectionTime,
        'bytes': bytes,
      });
    }

    Provider.of<TransactionProvider>(context, listen: false)
        .activities
        .forEach((activity) {
      sortedActivities.add({
        'type': activity.type,
        'tokenName': activity.tokenName,
        'transactionType': activity.transactionType,
        'image': activity.image,
        'time': activity.time,
        'amountType': activity.amountType,
        'transactionAmount': activity.transactionAmount,
        'siteURL': activity.siteURL,
        'id': activity.id,
      });
    });
    sortedActivities.sort((a, b) =>
        DateTime.parse(b['time']).compareTo(DateTime.parse(a['time'])));
    return sortedActivities;
  }

  callRedDotLogic() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showRedDot', false);

  }

  int currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final activities =
        Provider.of<TransactionProvider>(context, listen: false).activities;
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
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
                    child: activities.isEmpty
                        ? Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Text(
                        "No activities found under this wallet ID.".tr(),
                        style: TextStyle(
                            color: themeNotifier.isDark
                                ? AppColors.textColorGreyShade2
                                : AppColors.textColorBlack,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            fontFamily: 'Blogger Sans'),
                      ),
                    )
                        : FutureBuilder(
                      future: _getSortedActivitiesWithSiteConnection(),
                      // Get sorted activities
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox();
                        }
                        List<dynamic> sortedActivities =
                        snapshot.data as List<dynamic>;
                        return  RefreshIndicator(
                          color: AppColors.hexaGreen,
                          onRefresh: () async {
                            sortedActivities.clear();
                           await refresh();
                          },
                          child:  ListView.builder(
                            padding: EdgeInsets.zero,
                            controller: scrollController,
                            itemCount: sortedActivities.length + 1,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < sortedActivities.length) {
                                var activity = sortedActivities[index];
                                if (activity['type'] == 'site_connection') {
                                  return WalletActivityWidget(
                                    title: "Site Connected".tr(),
                                    subTitle: "Connect Success".tr(),
                                    image: 'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                                    bytes: bytes,
                                    time: calculateTimeDifference(activity['time']),
                                    priceUp: null,
                                    priceDown: null,
                                    handler: () {
                                    },
                                    siteURL: activity['siteURL'],
                                  );
                                } else if (activity['type'] == 'site_disconnection') {
                                  return WalletActivityWidget(
                                    title: "Site Disconnected".tr(),
                                    subTitle: "Disconnect Success".tr(),
                                    image: 'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                                    bytes: bytes,
                                    time: calculateTimeDifference(activity['time']),
                                    priceUp: null,
                                    priceDown: null,
                                    handler: () {
                                    },
                                    siteURL: activity['siteURL'],
                                  );
                                } else {
                                  return WalletActivityWidget(
                                    isPending: activity['tokenName'] == 'Site Connected' || activity['tokenName'] == 'Site Disconnected',
                                    title: activity['tokenName'],
                                    subTitle: tnxLabelingWithApi(activity['transactionType']),
                                    image: activity['image'],
                                    time: calculateTimeDifference(activity['time']),
                                    priceDown: activity['amountType'] == 'debit' ? activity['transactionAmount'] : null,
                                    priceUp: activity['amountType'] == 'credit' ? activity['transactionAmount'] : null,
                                    siteURL: activity['siteURL'],
                                    handler: () {
                                      if (activity['tokenName'] != 'Site Connected' && activity['tokenName'] != 'Site Disconnected') {
                                        Navigator.of(context).pushNamed(
                                          TransactionSummary.routeName,
                                          arguments: {
                                            'id': activity['id'],
                                            'type': activity['type'],
                                            'site': activity['siteURL'],
                                          },
                                        );
                                      }
                                    },
                                  );
                                }
                              } else {
                                return hasMore
                                    ? Center(child: CircularProgressIndicator(color: AppColors.hexaGreen,))
                                    : Center(child: Text('No Data Found'));
                              }
                            },
                          )
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned(
              top: 12.h,
              bottom: 0,
              left: 0,
              right: 0,
              child: LoaderBluredScreen(),)
        ],
      );
    });
  }
}