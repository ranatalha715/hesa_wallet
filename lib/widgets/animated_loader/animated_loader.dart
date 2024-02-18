import 'dart:ui';
// import 'package:app_settings/app_settings.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:app_settings/src/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../screens/signup_signin/wallet.dart';
import '../dialog_button.dart';




class CircularProgressAnimation extends StatefulWidget {

  @override
  _CircularProgressAnimationState createState() =>
      _CircularProgressAnimationState();
}

class _CircularProgressAnimationState extends State<CircularProgressAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCirc, // Use a linear curve for a consistent animation pace
    ));

    _controller.addListener(() {
      setState(() {}); // Redraw the widget when the animation value changes
    });

    _controller.repeat(); // Repeats the animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        Center(
          child: Transform.rotate(
            angle: _animation.value * 4.0 * 3.1415,
            child: Image.asset(
              'assets/images/animated_loader.png',
              // Replace this with your image path
              width: 40.sp, // Set your desired image width
              height: 40.sp, // Set your desired image height
            ),
          ),
        );
  }
}

class LoaderBluredScreen extends StatefulWidget {
  final bool isWifiOn;
   LoaderBluredScreen({this.isWifiOn= true});

  @override
  State<LoaderBluredScreen> createState() => _LoaderBluredScreenState();
}
class _LoaderBluredScreenState extends State<LoaderBluredScreen> {



  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }
  @override
  void didChangeDependencies() {
    print(widget.isWifiOn);
    print("isWifiOn");
    if(!widget.isWifiOn) {
      Future.delayed(Duration(milliseconds: 50), () {
        noInternetDialog(context);
      });
    } else{
      setState(() {

      });
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return  BackdropFilter(
        filter: ImageFilter.blur(
        sigmaX: 7, sigmaY: 7),
    child:
    // widget.isWifiOn ?
    Container(
        height: 100.h,
        width: double.infinity,
        // color: Colors.white.withOpacity(0.7),
        child: widget.isWifiOn
         ? CircularProgressAnimation() : SizedBox(),
    )
    );
  }

  void noInternetDialog (BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.85;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: 35.h,
                width: dialogWidth,
                decoration: BoxDecoration(
                  color: AppColors.showDialogClr,
                  // border: Border.all(
                  //     width: 0.1.h,
                  //     color: AppColors.textColorGrey),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 4.h,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                          "assets/images/no_internethesa.png",
                          height: 7.h,
                          color: AppColors.textColorWhite,
                          // width: 104,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'No internet access'
                              .tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17.5.sp,
                              color:AppColors.textColorWhite),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Lorem ipsum dolor sit amet, consec adipiscing elit ultrices arcu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textColorGreyShade2
                                  .withOpacity(0.4),
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Spacer(),
                      DialogButton(
                          title: 'Reconnect'.tr(),
                          handler: (){
                            AppSettings.openAppSettings(
                                type: AppSettingsType.wifi
                            ).then((value) => Navigator.pop(context));
                          },
                          // isLoading: isLoading,
                          // isGradient: true,
                          color: AppColors.textColorWhite),
                      Spacer(),
                    ],
                  ),
                ),
              )),
        );
      },
    );
  }
}

