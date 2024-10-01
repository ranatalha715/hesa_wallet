import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
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

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
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
      await Provider.of<TransactionProvider>(context, listen: false)
          .getWalletActivities(accessToken: accessToken, context: context);

      final prefs = await SharedPreferences.getInstance();

      // Null checks for siteUrl, logoFromNeo, connectionTime, and disconnectionTime
      siteUrl = prefs.getString("siteUrl") ?? "";  // Fallback to an empty string if null
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


  String calculateTimeDifference(String createdAtStr) {
    // Parse the createdAt timestamp and ensure it's in UTC
    DateTime createdAt = DateTime.parse(createdAtStr).toUtc();
    // Get the current time in UTC
    DateTime now = DateTime.now().toUtc();
    // Calculate the difference
    Duration difference = now.difference(createdAt);

    // Debug prints
    print('Created at: $createdAt');
    print('Now: $now');
    print('Difference: $difference');

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

  Future<List<Map<String, dynamic>>>
      _getSortedActivitiesWithSiteConnection() async {
    List<Map<String, dynamic>> sortedActivities = [];

    // Print to check if activities and connectionTime exist


    // Add the site connection data if it exists
    if (connectionTime != "" && siteUrl != "") {
      sortedActivities.add({
        'type': 'site_connection',
        'siteURL': siteUrl,
        'time': connectionTime, // The timestamp for the connection
        'bytes':bytes,
      });
    }
    if (disconnectionTime != "") {
      sortedActivities.add({
        'type': 'site_disconnection',
        'siteURL': siteUrl,
        'time': disconnectionTime, // Timestamp for the disconnection
        'bytes':bytes,
        // 'event': 'disconnect',  // Indicate this is a disconnection event
      });
    }

    // Add all other activities
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

  @override
  Widget build(BuildContext context) {
    final activities =
        Provider.of<TransactionProvider>(context, listen: false).activities;
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
                              "No activities found under this wallet ID.",
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

                              return RefreshIndicator(
                                color: AppColors.hexaGreen,
                                onRefresh: () async {
                                  await Provider.of<TransactionProvider>(
                                          context,
                                          listen: false)
                                      .getWalletActivities(
                                          accessToken: accessToken,
                                          context: context,
                                          refresh: true);
                                },
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: sortedActivities.length,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var activity = sortedActivities[index];

                                    if (activity['type'] == 'site_connection' ) {
                                      // Custom container for the site connection
                                      return WalletActivityWidget(
                                        title: "Site Connected",
                                        subTitle: "Connect Success",
                                        image:
                                            'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                                        bytes: bytes,
                                        time: calculateTimeDifference(
                                            activity['time']),
                                        priceUp: null,
                                        priceDown: null,
                                        handler: () {
                                          // Optional: Handle tap if necessary
                                        },
                                        siteURL: activity['siteURL'],
                                      );
                                    } else if (activity['type'] ==
                                        'site_disconnection') {
                                      // Custom widget for site disconnection
                                      return WalletActivityWidget(
                                        title: "Site Disconnected",
                                        subTitle: "Disconnect Success",
                                        image:
                                            'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                                        bytes: bytes,
                                        time: calculateTimeDifference(
                                            activity['time']),
                                        priceUp: null,
                                        priceDown: null,
                                        handler: () {
                                          // Handle tap if necessary
                                        },
                                        siteURL: activity['siteURL'],
                                      );
                                    } else {
                                      return WalletActivityWidget(
                                        isPending: activity['tokenName'] ==
                                                    'Site Connected' ||
                                                activity['tokenName'] ==
                                                    'Site Disconnected'
                                            ? true
                                            : false,
                                        title: activity['tokenName'],
                                        subTitle: activity['transactionType'],
                                        image: activity['image'],
                                        time: calculateTimeDifference(
                                            activity['time']),
                                        priceDown:
                                            activity['amountType'] == 'debit'
                                                ? activity['transactionAmount']
                                                : null,
                                        priceUp:
                                            activity['amountType'] == 'credit'
                                                ? activity['transactionAmount']
                                                : null,
                                        siteURL: activity['siteURL'],
                                        handler: () {
                                          if (activity['tokenName'] !=
                                                  'Site Connected' &&
                                              activity['tokenName'] !=
                                                  'Site Disconnected') {
                                            Navigator.of(context).pushNamed(
                                                TransactionSummary.routeName,
                                                arguments: {
                                                  'id': activity['id'],
                                                  'type': activity['type'],
                                                  'site': activity['siteURL'],
                                                });
                                          }
                                        },
                                      );
                                    }
                                  },
                                ),
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
          if (_isLoading) LoaderBluredScreen()
        ],
      );
    });
  }
}
