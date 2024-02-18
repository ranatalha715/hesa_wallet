// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// class SwipeBackPage extends StatefulWidget {
//   final Widget child;
//
//   SwipeBackPage({ required this.child});
//
//   @override
//   State<SwipeBackPage> createState() => _SwipeBackPageState();
// }
//
// class _SwipeBackPageState extends State<SwipeBackPage> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       // Detect horizontal drag (swipe) gesture
//       onHorizontalDragUpdate: (details) {
//         if (details.delta.dx > 20) {
//           // Customize the threshold value (20 in this case) as needed
//           Navigator.of(context).pop();
//         }
//       },
//       child: widget.child,
//     );
//   }
// }
//
import 'package:flutter/material.dart';

class SwipeBackPage extends StatelessWidget {
  final VoidCallback onSwipeBack;

  SwipeBackPage({required this.onSwipeBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Swipe Back Page'),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 10) {
            // If horizontal swipe towards right is detected, call the onSwipeBack callback.
            onSwipeBack();
          }
        },
        child: Center(
          child: Text('Swipe from left to right to go back'),
        ),
      ),
    );
  }
}
