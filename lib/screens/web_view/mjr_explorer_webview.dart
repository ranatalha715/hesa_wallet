import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants/colors.dart';

class MjrWebviewExplored extends StatefulWidget {
  final String url;
  MjrWebviewExplored({required this.url});

  @override
  State<MjrWebviewExplored> createState() => _MjrWebviewExploredState();
}

class _MjrWebviewExploredState extends State<MjrWebviewExplored> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Expanded(
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 30,),
              color:    AppColors.backgroundColor,
              child: WebView(
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
            Positioned(
              top: 55,
              left: 18,
              child: GestureDetector(
                onTap: ()=> Navigator.pop(context),
                child: Image.asset(
                  "assets/images/back_dark_oldUI.png",
                  height: 3.1.h,
                  width:  3.1.h,
                  // color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
