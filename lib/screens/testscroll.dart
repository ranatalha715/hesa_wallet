import 'package:flutter/material.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';

class TestScroll extends StatefulWidget {
  @override
  _TestScrollState createState() => _TestScrollState();
}

class _TestScrollState extends State<TestScroll> {
  double _appBarHeight = 0;
  ScrollController _scrollController = ScrollController();
  double _headerSize = 21.h; // Set your initial header size
  bool isScrolled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController.addListener(() => setState(() {}));
    _appBarHeight = MediaQuery.of(context).size.height * 0.16;
  }

  double get _horizontalTitlePadding {
    const kBasePadding = 20.0;
    const kMultiplier = 0.6;

    if (_scrollController.hasClients) {
      if (_scrollController.offset < (_appBarHeight / 2)) {
        return kBasePadding;
      }

      if (_scrollController.offset > (_appBarHeight - kToolbarHeight)) {
        return (_appBarHeight / 2 - kToolbarHeight) * kMultiplier +
            kBasePadding;
      }



      return (_scrollController.offset - (_appBarHeight / 2)) * kMultiplier +
          kBasePadding;
    }

    return kBasePadding;
  }

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  //
  // void _onScroll() {
  //   setState(() {
  //     // Adjust the header size based on the scroll offset
  //     _headerSize = 21.h - _scrollController.offset;
  //     if (_headerSize < kToolbarHeight) {
  //       _headerSize = kToolbarHeight;
  //     }
  //     if (_scrollController.position.pixels ==
  //         _scrollController.position.maxScrollExtent) {
  //       isScrolled = true;
  //     } else {
  //       isScrolled = false;
  //     }
  //
  //     // Check if we have reached the end of the list
  //     double twentyPercent = 0.1 * _scrollController.position.maxScrollExtent;
  //     isScrolled = _scrollController.position.pixels >= twentyPercent;
  //   });
  //   print("Now printing");
  //   print(isScrolled.toString());
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        body: Container(
          height: 5.h,
          color: Colors.green,
        ),
        // Padding(
        //     padding: const EdgeInsets.only(bottom: 20),
        //     child: Container(
        //       height: 5.h,
        //       color: Colors.red,
        //       width: double.infinity,
        //     )),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverSafeArea(
                top: false,
                bottom: false,
                sliver: SliverAppBar(
                  // expandedHeight: 21.h, // Set your desired expanded height
                  // floating: false,
                  // pinned: true,
                  backgroundColor: AppColors.gradientColor1,
                  surfaceTintColor: AppColors.activityPricegreenClr,
                  // centerTitle: false,
                  leading: GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 16,
                      ),
                      child: Image.asset(
                        "assets/images/back_icon.png",
                        height: 4,
                        width: 4,
                      ),
                    ),
                  ),
                  onStretchTrigger: () async {},
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    expandedTitleScale: 1,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff92B928), Color(0xffC9C317)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // AppHeader(
                    //   title: '',
                    // ),
                    // Stack(
                    //   children: [
                    //     // Text('xyz',
                    //     // style: TextStyle(
                    //     //   color: Colors.white,
                    //     //   fontSize: _appBarHeight
                    //     // ),
                    //     // )
                    //   ],
                    // ),
                    titlePadding: EdgeInsetsDirectional.only(
                        start: _horizontalTitlePadding, top: 10, bottom: 10),
                    title: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final double titleHeight = constraints.biggest.height;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 4.sp, left: 8.sp),
                          child: Text(
                            'Transaction Request',
                            style: TextStyle(
                                color: AppColors.textColorBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 17.5.sp,
                                fontFamily: 'Inter'),

                            // ClipRRect(
                            // borderRadius: BorderRadius.circular(titleHeight > 70 ? 10 : 5),
                            // child: Container(
                            //   color: Colors.black45,
                            //   height: titleHeight >= 80 ? 80 : titleHeight,
                            //   width: titleHeight >= 80 ? 80 : titleHeight,
                            // ),
                          ),
                        );
                      },
                    ),
                  ),
                  pinned: true,
                  expandedHeight: _appBarHeight,
                )

                // AppHeader(title: 'Talha',)
                // ProfileAppBar(
                //   isOwn: true,
                //   controller: _scrollController,
                //   isProfile: true,
                //   titleUrl: state.user.profileUrl,
                //   bannerUrl: state.user.bannerUrl,
                // ),
                ),
          ),
          // CustomScrollView(
          //   controller: _scrollController,
          //   slivers: [
          //     SliverAppBar(
          //         expandedHeight: 21.h, // Set your desired expanded height
          //         floating: false,
          //         pinned: true,
          //         flexibleSpace: FlexibleSpaceBar(
          //           expandedTitleScale: 1,
          //           titlePadding: EdgeInsets.only(
          //             left: isScrolled ? 56.0 : 16.0,
          //             bottom: isScrolled ? 70.0 : 20.0,
          //           ),
          //           title: Text(
          //             'Transaction Request',
          //             textDirection: TextDirection.ltr,
          //             style: TextStyle(
          //                 color: AppColors.textColorBlack,
          //                 fontWeight: FontWeight.w600,
          //                 fontSize: 17.5.sp,
          //                 fontFamily: 'Inter'),
          //           ),
          //           background: AppHeader(
          //             title: '',
          //             // IsScrolled: isScrolled,
          //           ),
          //         )
          //         // AppHeader(title: '',
          //         //   // IsScrolled: isScrolled,
          //         // ),
          //         ),
          // SliverToBoxAdapter(
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // child: Column(
                //   children: [
                Container(
                  height: 10.h,
                  color: Colors.red,
                  margin: EdgeInsets.all(20.sp),
                ),
                Container(
                  height: 10.h,
                  color: Colors.red,
                  margin: EdgeInsets.all(20.sp),
                ),
                Container(
                  height: 10.h,
                  color: Colors.red,
                  margin: EdgeInsets.all(20.sp),
                ),
                Container(
                  height: 10.h,
                  color: Colors.red,
                  margin: EdgeInsets.all(20.sp),
                ),
                Container(
                  height: 10.h,
                  color: Colors.red,
                  margin: EdgeInsets.all(20.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
