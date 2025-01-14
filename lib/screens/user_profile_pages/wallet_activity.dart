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
  refresh() async {
   setState(() {
     _isLoading=false;
     hasMore=true;
     currentPage=0;
     // Provider.of<TransactionProvider>(context,listen: false).activities.clear();
     sortedActivities.clear();
   });
   await fetch();
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
      // await Provider.of<TransactionProvider>(context, listen: false)
      //     .getWalletActivities(accessToken: accessToken, context: context, isEnglish:isEnglish,  limit: 10,
      //   page: 1,);
     // await refresh();

      // scrollController.addListener(() {
      //
      //   if(scrollController.position.maxScrollExtent==scrollController.offset){
      //     fetch();
      //   }
      //
      // });
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
    // if(_isLoading) return;
    // _isLoading=true;
    const limit=10;

    // setState(() {
    //     Provider.of<TransactionProvider>(context, listen: false).activities.clear();
    // });
    await Provider.of<TransactionProvider>(context, listen: false)
        .getWalletActivities(accessToken: accessToken, context: context, isEnglish:true,
      limit: limit,
      page: currentPage,
    );
    //  await refresh(
    //     currentPage,limit
    //   );
      setState(() {
        currentPage++;
      });
      if(Provider.of<TransactionProvider>(context, listen: false).activities.length < limit){
        hasMore=false;
      }
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    // Clear the activities list when the user navigates to this page
    Provider.of<TransactionProvider>(context, listen: false).clearActivities();

    fetch();
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent==scrollController.offset){
        fetch();
      }

    });
    // redDotLogic();
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
        'time': connectionTime, // The timestamp for the connection
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

    // Sort activities by time in descending order (most recent first)
    sortedActivities.sort((a, b) =>
        DateTime.parse(b['time']).compareTo(DateTime.parse(a['time'])));
    print('Activities length: ${sortedActivities.length}');
    print('Connection time: $connectionTime');
    print('disconnection time: $disconnectionTime');
    print('Site URL: $siteUrl');
    // Print sorted activities to debug
    print('Sorted Activities: $sortedActivities');

    return sortedActivities;
  }

  callRedDotLogic() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showRedDot', false);

  }

  int currentPage = 1;
  // int activitesLimit = 10;


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
                          // return CircularProgressIndicator(); // Loading indicator
                          return SizedBox();
                        }

                        List<dynamic> sortedActivities =
                        snapshot.data as List<dynamic>;

                        return  RefreshIndicator(
                          color: AppColors.hexaGreen,
                          onRefresh: () async {
                            sortedActivities.clear();
                           await refresh();
                            // setState(() {
                            //   _isLoading=true;
                            // });
                            // currentPage++;
                            // activitesLimit += 10;
                            // // Trigger the refresh with page 1 and refresh: true
                            // await Provider.of<TransactionProvider>(context, listen: false)
                            //     .getWalletActivities(
                            //   accessToken: accessToken,
                            //   context: context,
                            //   refresh: true, // Replace activities
                            //   limit: activitesLimit,     // Fetch 20 activities per page
                            //   page: currentPage,       // Start from the first page for refresh
                            //   isEnglish: isEnglish,
                            // );
                            // setState(() {
                            //   _isLoading=false;
                            // });
                          },
                          child:  ListView.builder(
                            padding: EdgeInsets.zero,
                            controller: scrollController,
                            itemCount: sortedActivities.length + 1,
                            // itemCount: sortedActivities.length + (hasMore ? 1 : 0),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              // Check if index is within bounds of the list
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
                                      // Handle tap if necessary
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
                                // Handle the extra item
                                return hasMore
                                    ? Center(child: CircularProgressIndicator(color: AppColors.hexaGreen,))
                                    : Center(child: Text('No Data Found'));
                              }
                            },
                          )

                          // ListView.builder(
                          //   padding: EdgeInsets.zero,
                          //   controller: scrollController,
                          //   itemCount: sortedActivities.length + 1,
                          //   shrinkWrap: true,
                          //   itemBuilder:
                          //       (BuildContext context, int index) {
                          //     var activity = sortedActivities[index];
                          //
                          //     if (activity['type'] == 'site_connection') {
                          //       // Custom container for the site connection
                          //       return WalletActivityWidget(
                          //         title: "Site Connected".tr(),
                          //         subTitle: "Connect Success".tr(),
                          //         image:
                          //         'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                          //         bytes: bytes,
                          //         time: calculateTimeDifference(
                          //             activity['time']),
                          //         priceUp: null,
                          //         priceDown: null,
                          //         handler: () {
                          //           // Optional: Handle tap if necessary
                          //         },
                          //         siteURL: activity['siteURL'],
                          //       );
                          //     } else if (activity['type'] ==
                          //         'site_disconnection') {
                          //       // Custom widget for site disconnection
                          //       return WalletActivityWidget(
                          //         title: "Site Disconnected".tr(),
                          //         subTitle: "Disconnect Success".tr(),
                          //         image:
                          //         'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                          //         bytes: bytes,
                          //         time: calculateTimeDifference(
                          //             activity['time']),
                          //         priceUp: null,
                          //         priceDown: null,
                          //         handler: () {
                          //           // Handle tap if necessary
                          //         },
                          //         siteURL: activity['siteURL'],
                          //       );
                          //     } else if(index < sortedActivities.length){
                          //       return WalletActivityWidget(
                          //         isPending: activity['tokenName'] ==
                          //             'Site Connected' ||
                          //             activity['tokenName'] ==
                          //                 'Site Disconnected'
                          //             ? true
                          //             : false,
                          //         title: activity['tokenName'],
                          //         subTitle: activity['transactionType'],
                          //         image: activity['image'],
                          //         time: calculateTimeDifference(
                          //             activity['time']),
                          //         priceDown:
                          //         activity['amountType'] == 'debit'
                          //             ? activity['transactionAmount']
                          //             : null,
                          //         priceUp:
                          //         activity['amountType'] == 'credit'
                          //             ? activity['transactionAmount']
                          //             : null,
                          //         siteURL: activity['siteURL'],
                          //         handler: () {
                          //           if (activity['tokenName'] !=
                          //               'Site Connected' &&
                          //               activity['tokenName'] !=
                          //                   'Site Disconnected') {
                          //             Navigator.of(context).pushNamed(
                          //                 TransactionSummary.routeName,
                          //                 arguments: {
                          //                   'id': activity['id'],
                          //                   'type': activity['type'],
                          //                   'site': activity['siteURL'],
                          //                 });
                          //           }
                          //         },
                          //       );
                          //     } else{
                          //       return hasMore ? Center(child: CircularProgressIndicator(),): Text('No Data Found');
                          //     }
                          //   },
                          // ),
                        );
                      },
                    ),
                  ),
                ),

                // Expanded(
                //     child: Container(
                //   child: activities.isEmpty
                //       ? Padding(
                //           padding: EdgeInsets.only(top: 20.h),
                //           child: Text(
                //             "No activities found under this wallet ID.",
                //             style: TextStyle(
                //                 color: themeNotifier.isDark
                //                     ? AppColors.textColorGreyShade2
                //                     : AppColors.textColorBlack,
                //                 fontWeight: FontWeight.w500,
                //                 fontSize: 12.sp,
                //                 fontFamily: 'Blogger Sans'),
                //           ),
                //         )
                //       : RefreshIndicator(
                //           color: AppColors.hexaGreen,
                //           onRefresh: () async {
                //             await Provider.of<TransactionProvider>(context,
                //                     listen: false)
                //                 .getWalletActivities(
                //                     accessToken: accessToken,
                //                     context: context,
                //                     refresh: true);
                //           },
                //           child: ListView.builder(
                //             padding: EdgeInsets.zero,
                //             itemCount: activities.length,
                //             shrinkWrap: true,
                //             itemBuilder: (BuildContext context, int index) {
                //               // DateTime connectionDateTime = DateTime.parse(connectionTime);
                //               // DateTime activityTime = DateTime.parse(activities[index].time);
                //
                //               if (index == 0) {
                //                 // Custom container with siteUrl, connectionTime, and empty price
                //                 return connectionTime != null && siteUrl != null ? WalletActivityWidget(
                //                   title:"Site Connection",
                //                   // Use siteUrl as the title
                //                   subTitle: "Connect Success",
                //                   // Empty subtitle
                //                   image: 'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                //                   // No image
                //                   time: calculateTimeDifference(connectionTime),
                //                   // Use connectionTime
                //                   priceUp: null,
                //                   // No price
                //                   priceDown: null,
                //                   // No price
                //                   handler: () {
                //                     // Optional: Handle tap if necessary
                //                   },
                //                   siteURL: siteUrl,
                //                 ): SizedBox();
                //               } else {
                //                 return WalletActivityWidget(
                //                   isPending: activities[index].tokenName ==
                //                               'Site Connected' ||
                //                           activities[index].tokenName ==
                //                               'Site Disconnected'
                //                       ? true
                //                       : false,
                //                   title: activities[index].tokenName,
                //                   subTitle: activities[index].transactionType,
                //                   // image: 'assets/images/nft.png',
                //                   image: activities[index].image,
                //                   time: activities[index].time,
                //                   priceDown:
                //                       activities[index].amountType == 'debit'
                //                           ? activities[index].transactionAmount
                //                           : null,
                //                   priceUp:
                //                       activities[index].amountType == 'credit'
                //                           ? activities[index].transactionAmount
                //                           : null,
                //                   siteURL: activities[index].siteURL,
                //                   handler: () {
                //                     if (activities[index].tokenName !=
                //                             'Site Connected' &&
                //                         activities[index].tokenName !=
                //                             'Site Disconnected')
                //                       Navigator.of(context).pushNamed(
                //                           TransactionSummary.routeName,
                //                           arguments: {
                //                             'id': activities[index].id,
                //                             'type': activities[index].type,
                //                             'site': activities[index].siteURL,
                //                           });
                //                   },
                //                 );
                //               }
                //             },
                //           ),
                //         ),
                // )
                //     // SingleChildScrollView(
                //     //   child: Column(
                //     //     children: [
                //     //       WalletActivityWidget(
                //     //         title: 'Neo Cube#123',
                //     //         subTitle: 'Item sale'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '3h',
                //     //         priceUp: 12000,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(
                //     //               builder: (context) => TransactionSummary()),
                //     //         ),
                //     //       ),
                //     //       WalletActivityWidget(
                //     //         title: 'Neo Cube#123'.tr(),
                //     //         subTitle: 'Collection purchase'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '1d',
                //     //         // priceUp: 12000,
                //     //         priceDown: 8000,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(
                //     //               builder: (context) => TransactionSummary()),
                //     //         ),
                //     //       ),
                //     //       WalletActivityWidget(
                //     //         title: 'Neo Cube#123'.tr(),
                //     //         subTitle: 'Creation royalty'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '1d',
                //     //         priceNormal: 10000,
                //     //         priceUp: 400,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(
                //     //               builder: (context) => TransactionSummary()),
                //     //         ),
                //     //       ),
                //     //       WalletActivityWidget(
                //     //         title: 'Site Connection'.tr(),
                //     //         subTitle: 'Connect Success'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '1d',
                //     //         isPending: true,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(builder: (context) => ConnectDapp()),
                //     //         ),
                //     //       ),
                //     //       WalletActivityWidget(
                //     //         title: 'Listing'.tr(),
                //     //         subTitle: 'Transaction request'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '1d',
                //     //         isPending: true,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(builder: (context) => ConnectDapp()),
                //     //         ),
                //     //       ),
                //     //       WalletActivityWidget(
                //     //         title: 'Collection purchase'.tr(),
                //     //         subTitle: 'Item sale'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '8h',
                //     //         priceUp: 12000,
                //     //         // priceDown: 4000,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(
                //     //               builder: (context) => TransactionSummary()),
                //     //         ),
                //     //       ),
                //     //       WalletActivityWidget(
                //     //         title: 'Creation royalty'.tr(),
                //     //         subTitle: 'Item sale'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '1d',
                //     //         priceNormal: 8000,
                //     //         priceUp: 4000,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(
                //     //               builder: (context) => TransactionSummary()),
                //     //         ),
                //     //       ),
                //     //       WalletActivityWidget(
                //     //         title: 'Listing'.tr(),
                //     //         subTitle: 'Transaction request'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '1d',
                //     //         isPending: true,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(builder: (context) => ConnectDapp()),
                //     //         ),
                //     //       ),
                //     //       WalletActivityWidget(
                //     //         title: 'Collection purchase'.tr(),
                //     //         subTitle: 'Item sale'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '2d',
                //     //         priceNormal: 10000,
                //     //         priceDown: 4000,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(
                //     //               builder: (context) => TransactionSummary()),
                //     //         ),
                //     //       ),
                //     //       WalletActivityWidget(
                //     //         title: 'Creation royalty'.tr(),
                //     //         subTitle: 'Item sale'.tr(),
                //     //         image: 'assets/images/nft.png',
                //     //         time: '1d',
                //     //         priceNormal: 8000,
                //     //         priceUp: 4000,
                //     //         handler: () => Navigator.push(
                //     //           context,
                //     //           MaterialPageRoute(
                //     //               builder: (context) => TransactionSummary()),
                //     //         ),
                //     //       ),
                //     //     ],
                //     //   ),
                //     // ),
                //     ),
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